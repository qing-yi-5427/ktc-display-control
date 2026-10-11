import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct BackupSetting:Codable {let code:Int;let value:Int;let name:String}
struct MonitorBackup:Codable {
    let format:String;let version:Int;let model:String;let monitorID:String;let created:Date;let settings:[BackupSetting]
}
struct RestoreItem:Identifiable {
    let feature:Feature;let old:Int;let target:Int
    var id:Int{feature.code}
}
struct ImportPlan:Identifiable {let id=UUID();let monitorID:String;let items:[RestoreItem];let notes:[String]}
enum BackupError:LocalizedError {
    case invalid(String)
    var errorDescription:String? {if case let .invalid(s)=self{return s};return nil}
}
func validateBackup(_ b:MonitorBackup,model:String,id:String) throws {
    guard b.format == "KTCControl.Configuration",b.version == 1 else {throw BackupError.invalid("不是受支持的控制台配置文件")}
    guard b.model == model,b.monitorID == id else {throw BackupError.invalid("配置所属显示器与当前显示器不一致，未执行导入")}
    guard !b.settings.isEmpty,b.settings.count <= 128 else {throw BackupError.invalid("配置项目数量异常")}
    guard Set(b.settings.map{$0.code}).count == b.settings.count else {throw BackupError.invalid("配置包含重复控制码")}
    for x in b.settings {
        guard backupCodes.contains(x.code),(0...65535).contains(x.value) else {throw BackupError.invalid("配置包含不允许自动恢复的代码或数值")}
        if let options=choices[x.code],!options.contains(where:{$0.0 == x.value}) {throw BackupError.invalid("配置包含未经确认的选项值")}
    }
}
@MainActor extension Model {
    func snapshot() async -> MonitorBackup {
        var settings:[BackupSetting]=[]
        for f in features where backupCodes.contains(f.code) {
            let r=await execute(["display",selected,"probe",f.hex])
            if let v=reading(r) {
                readings[f.code]=v
                let valid = f.slider ? v.current >= 0 && v.current <= v.maximum && v.maximum > 0 : (choices[f.code]?.contains(where:{$0.0 == v.current}) ?? false)
                if valid {settings.append(.init(code:f.code,value:v.current,name:f.name))}
            }
        }
        return .init(format:"KTCControl.Configuration",version:1,model:rememberedName,monitorID:selected,created:Date(),settings:settings)
    }
    func encodeBackup(_ backup:MonitorBackup) throws -> Data {
        let enc=JSONEncoder();enc.outputFormatting=[.prettyPrinted,.sortedKeys];enc.dateEncodingStrategy = .iso8601
        return try enc.encode(backup)
    }
    func saveBackup() async {
        guard !busy else{return};busy=true;defer{busy=false}
        status="正在读取最新配置…"
        let backup=await snapshot()
        guard !backup.settings.isEmpty else {status="无法备份：没有读取到可恢复设置";return}
        let panel=NSSavePanel();panel.allowedContentTypes=[.json];panel.nameFieldStringValue="KTC-配置-\(Date().formatted(.iso8601.year().month().day().dateSeparator(.dash))).json"
        if panel.runModal() == .OK,let url=panel.url {
            do {try encodeBackup(backup).write(to:url,options:.atomic);status="已备份 \(backup.settings.count) 项设置";record(status)}
            catch {status="备份失败：\(error.localizedDescription)";record(status)}
        } else {status="已取消备份"}
    }
    func prepareImport() async {
        guard !busy else{return}
        let panel=NSOpenPanel();panel.allowedContentTypes=[.json];panel.allowsMultipleSelection=false
        guard panel.runModal() == .OK,let url=panel.url else{return}
        busy=true;defer{busy=false}
        do {
            let attrs=try url.resourceValues(forKeys:[.fileSizeKey]);guard (attrs.fileSize ?? 999999) < 262144 else{throw BackupError.invalid("配置文件过大")}
            let dec=JSONDecoder();dec.dateDecodingStrategy = .iso8601
            let b=try dec.decode(MonitorBackup.self,from:Data(contentsOf:url))
            try validateBackup(b,model:rememberedName,id:selected)
            var items:[RestoreItem]=[],notes:[String]=[]
            for saved in b.settings {
                guard let f=features.first(where:{$0.code == saved.code}) else{continue}
                let r=await execute(["display",selected,"probe",f.hex])
                guard let v=reading(r) else {notes.append("\(f.name)：当前无法读取，将跳过");continue}
                if f.slider && (saved.value > v.maximum || v.maximum == 0) {throw BackupError.invalid("\(f.name)的值超出当前设备范围")}
                items.append(.init(feature:f,old:v.current,target:saved.value))
            }
            guard !items.isEmpty else{throw BackupError.invalid("当前没有可导入的设置")}
            importPlan=ImportPlan(monitorID:selected,items:items,notes:notes);status="请检查导入预览"
        } catch {status="导入失败：\(error.localizedDescription)";record(status)}
    }
    func restore(_ plan:ImportPlan,includeConnection:Bool) async {
        guard !busy else{return};guard selected == plan.monitorID else{status="显示器已改变，请重新导入配置";return};busy=true;importing=true;defer{busy=false;importing=false}
        let items=plan.items.filter{includeConnection || !connectionCodes.contains($0.id)}.sorted{a,b in
            func rank(_ c:Int)->Int { if c == 0xF1{return -3};if c == 0x14{return -2};if c == 0x72{return -1};if connectionCodes.contains(c){return 1000+c};return c }
            return rank(a.id)<rank(b.id)
        }
        do {
            status="正在保存导入前恢复副本…"
            let before=await snapshot()
            guard !before.settings.isEmpty, Set(items.map{$0.id}).isSubset(of:Set(before.settings.map{$0.code})) else{throw BackupError.invalid("无法完整读取待修改项目的原值，未写入任何设置")}
            let dir=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("KTCControl/Backups")
            try FileManager.default.createDirectory(at:dir,withIntermediateDirectories:true)
            let url=dir.appendingPathComponent("before-import-\(UUID().uuidString).json")
            try encodeBackup(before).write(to:url,options:.atomic);record("恢复副本：\(url.path)")
            for x in items {
                status="正在应用\(x.feature.name)…"
                let current=await execute(["display",selected,"probe",x.feature.hex])
                guard let v=reading(current) else{throw BackupError.invalid("\(x.feature.name)读取失败，停止后续写入")}
                if v.current == x.target{continue}
                if x.feature.slider && x.target > v.maximum{throw BackupError.invalid("\(x.feature.name)可用范围已变化")}
                let r=await execute(["display",selected,"set",x.feature.hex,String(x.target)])
                record("导入 \(x.feature.name)=\(x.target)：\(r.text)")
                guard r.code == 0 else{throw BackupError.invalid("\(x.feature.name)写入失败")}
                try? await Task.sleep(nanoseconds:connectionCodes.contains(x.id) ? 3_000_000_000 : 200_000_000)
                let confirm=await execute(["display",selected,"probe",x.feature.hex])
                guard let v=reading(confirm),v.current == x.target else{throw BackupError.invalid("\(x.feature.name)回读不一致或无法连接；之前已应用的项目保留")}
                readings[x.id]=v
            }
            var mismatch:[String]=[]
            for x in items {
                let r=await execute(["display",selected,"probe",x.feature.hex])
                if let v=reading(r){readings[x.id]=v;if v.current != x.target{mismatch.append(x.feature.name)}}else{mismatch.append(x.feature.name)}
            }
            status=mismatch.isEmpty ? "导入完成，\(items.count) 项回读一致" : "导入后仍有不一致：\(mismatch.joined(separator:"、"))"
            record(status)
        } catch {status="导入停止：\(error.localizedDescription)";record(status)}
    }
    func showBackupFolder() {
        let dir=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("KTCControl/Backups")
        try? FileManager.default.createDirectory(at:dir,withIntermediateDirectories:true)
        NSWorkspace.shared.open(dir)
    }
}
struct ImportPreview:View {
    @ObservedObject var model:Model;let plan:ImportPlan
    @LocalState<Bool> var includeConnection=false
    @Environment(\.dismiss) var dismiss
    var body:some View {
        VStack(alignment:.leading,spacing:16) {
            Text("导入配置预览").font(.title2.bold())
            Text("左侧为当前值，右侧为备份值。未变化项目也会在导入后验证。").foregroundStyle(.secondary)
            Toggle("包含 DSC、KVM、同步、超频与图像比例（可能断开连接）",isOn:$includeConnection)
            ScrollView {
                VStack(spacing:8) {
                    ForEach(plan.items){x in
                        HStack{Text(x.feature.name);Spacer();Text("\(x.old) → \(x.target)").monospacedDigit();if connectionCodes.contains(x.id) && !includeConnection {Text("跳过").foregroundStyle(.secondary)}}.padding(8).background(Color.secondary.opacity(0.06),in:RoundedRectangle(cornerRadius:7))
                    }
                    ForEach(plan.notes,id:\.self){Text($0).foregroundStyle(.secondary)}
                }
            }
            HStack{Spacer();Button("取消"){dismiss()};Button("应用并验证"){dismiss();Task{await model.restore(plan,includeConnection:includeConnection)}}}.buttonStyle(.borderedProminent)
        }.padding(24).frame(width:620,height:520)
    }
}
