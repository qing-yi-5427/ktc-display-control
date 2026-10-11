import SwiftUI
import AppKit
typealias LocalState<Value> = SwiftUI.State<Value>

struct Monitor: Identifiable, Hashable { let id: String; let name: String }
struct Feature: Identifiable, Hashable {
    let code: Int; let name: String; let group: String; let slider: Bool
    var id: Int { code }; var hex: String { String(format:"0x%02X", code) }
}
let features: [Feature] = [
    Feature(code:16,name:"亮度",group:"画面",slider:true),
    Feature(code:18,name:"对比度",group:"画面",slider:true),
    Feature(code:135,name:"锐度",group:"画面",slider:true),
    Feature(code:46,name:"暗部平衡",group:"画面",slider:true),
    Feature(code:244,name:"分区调光",group:"画面",slider:false),
    Feature(code:233,name:"HDR",group:"画面",slider:false),
    Feature(code:219,name:"图像比例",group:"画面",slider:false),
    Feature(code:20,name:"色温预设",group:"色彩",slider:false),
    Feature(code:114,name:"Gamma",group:"色彩",slider:false),
    Feature(code:241,name:"色域",group:"色彩",slider:false),
    Feature(code:251,name:"低蓝光",group:"色彩",slider:true),
    Feature(code:22,name:"红色增益",group:"色彩",slider:true),
    Feature(code:24,name:"绿色增益",group:"色彩",slider:true),
    Feature(code:26,name:"蓝色增益",group:"色彩",slider:true),
    Feature(code:89,name:"红色饱和度",group:"色彩",slider:true),
    Feature(code:155,name:"红色色相",group:"色彩",slider:true),
    Feature(code:90,name:"黄色饱和度",group:"色彩",slider:true),
    Feature(code:156,name:"黄色色相",group:"色彩",slider:true),
    Feature(code:91,name:"绿色饱和度",group:"色彩",slider:true),
    Feature(code:157,name:"绿色色相",group:"色彩",slider:true),
    Feature(code:92,name:"青色饱和度",group:"色彩",slider:true),
    Feature(code:158,name:"青色色相",group:"色彩",slider:true),
    Feature(code:93,name:"蓝色饱和度",group:"色彩",slider:true),
    Feature(code:159,name:"蓝色色相",group:"色彩",slider:true),
    Feature(code:94,name:"品红色饱和度",group:"色彩",slider:true),
    Feature(code:160,name:"品红色色相",group:"色彩",slider:true),
    Feature(code:99,name:"音量",group:"声音",slider:true),
    Feature(code:141,name:"静音",group:"声音",slider:false),
    Feature(code:207,name:"FreeSync / G-Sync",group:"游戏与连接",slider:false),
    Feature(code:224,name:"Overdrive 响应加速",group:"游戏与连接",slider:false),
    Feature(code:227,name:"刷新率超频",group:"游戏与连接",slider:false),
    Feature(code:228,name:"FPS 显示",group:"游戏与连接",slider:false),
    Feature(code:218,name:"DSC 显示流压缩",group:"游戏与连接",slider:false),
    Feature(code:217,name:"KVM 上行连接",group:"游戏与连接",slider:false),
    Feature(code:209,name:"RGB 灯效",group:"游戏与连接",slider:false),
    Feature(code:144,name:"OSD 水平位置",group:"菜单",slider:true),
    Feature(code:173,name:"OSD 垂直位置",group:"菜单",slider:true),
    Feature(code:63,name:"OSD 显示时间（秒）",group:"菜单",slider:false),
    Feature(code:167,name:"OSD 透明度级别",group:"菜单",slider:false),
    Feature(code:203,name:"OSD 语言编码",group:"高级",slider:false),
    Feature(code:216,name:"准星编码",group:"高级",slider:false),
    Feature(code:175,name:"计时器编码",group:"高级",slider:false),
    Feature(code:96,name:"输入源原始值／能力标记",group:"高级",slider:false),
    Feature(code:253,name:"色彩范围编码",group:"高级",slider:false),
    Feature(code:220,name:"场景模式编码",group:"高级",slider:false),
    Feature(code:34,name:"当前像素宽度",group:"设备信息",slider:false),
    Feature(code:50,name:"当前像素高度",group:"设备信息",slider:false),
    Feature(code:124,name:"当前刷新率（Hz）",group:"设备信息",slider:false),
    Feature(code:189,name:"设备标识",group:"设备信息",slider:false),
    Feature(code:192,name:"累计使用时间原始值",group:"设备信息",slider:false),
    Feature(code:223,name:"DDC 协议版本",group:"设备信息",slider:false),
    Feature(code:214,name:"电源模式",group:"电源",slider:false),
]
let choices: [Int: [(Int,String)]] = [
    244:[(0,"自动"),(1,"标准"),(2,"高")],
    233:[(0,"关闭"),(1,"自动")],
    219:[(0,"全屏"),(1,"16:9"),(2,"4:3")],
    20:[(1,"正常"),(2,"暖色"),(3,"冷色"),(4,"用户")],
    114:[(0,"关闭"),(1,"1.8"),(2,"2.0"),(3,"2.2"),(4,"2.4")],
    241:[(0,"原生"),(1,"sRGB"),(2,"Adobe RGB"),(3,"DCI-P3"),(4,"BT.2020")],
    217:[(0,"USB 关闭"),(1,"自动"),(2,"USB UP"),(3,"Type-C")],
    224:[(1,"关闭"),(2,"标准"),(3,"高级"),(4,"极速"),(5,"自动")],
    209:[(0,"关闭"),(1,"呼吸"),(2,"红色"),(3,"绿色"),(4,"蓝色")],
    63:[(15,"15 秒"),(30,"30 秒"),(45,"45 秒"),(60,"60 秒")],
    167:[(1,"级别 1"),(2,"级别 2"),(3,"级别 3"),(4,"级别 4"),(5,"级别 5")],
    207:[(0,"关闭"),(1,"开启")],
    227:[(0,"关闭"),(1,"开启")],
    228:[(0,"关闭"),(1,"开启")],
    218:[(0,"关闭"),(1,"开启")],
    141:[(0,"关闭"),(1,"开启")],
]
let connectionCodes:Set<Int> = [0xDA,0xD9,0xCF,0xE3,0xDB]
let backupCodes:Set<Int> = Set(features.filter{$0.slider || choices[$0.code] != nil}.map{$0.code})
struct Reading { let current: Int; let maximum: Int }
struct RunResult { let code: Int32; let text: String }
final class Runner: @unchecked Sendable {
    func run(_ args:[String]) -> RunResult {
        guard let exe = Bundle.main.url(forResource:"m1ddc",withExtension:nil) else { return .init(code:1,text:"内置控制工具缺失") }
        let p = Process(); p.executableURL = exe; p.arguments = args
        let out = Pipe(); p.standardOutput = out; p.standardError = out
        do { try p.run() } catch { return .init(code:1,text:error.localizedDescription) }
        let deadline = Date().addingTimeInterval(args.last == "caps" ? 8 : 4)
        while p.isRunning && Date() < deadline { Thread.sleep(forTimeInterval:0.03) }
        if p.isRunning {
            p.terminate(); Thread.sleep(forTimeInterval:0.1)
            if p.isRunning { kill(p.processIdentifier, SIGKILL) }
            p.waitUntilExit(); return .init(code:124,text:"通信超时；请检查显示器连接")
        }
        p.waitUntilExit()
        let data = out.fileHandleForReading.readDataToEndOfFile()
        return .init(code:p.terminationStatus,text:String(data:data,encoding:.utf8)?.trimmingCharacters(in:.whitespacesAndNewlines) ?? "")
    }
}
@MainActor final class Model: ObservableObject {
    @Published var monitors:[Monitor] = []
    @Published var selected = UserDefaults.standard.string(forKey:"selectedMonitor") ?? ""
    @Published var rememberedName = UserDefaults.standard.string(forKey:"monitorName") ?? "M27P20P"
    @Published var readings:[Int:Reading] = [:]
    @Published var failures:Set<Int> = []
    @Published var busy = false
    @Published var status = "准备连接显示器"
    @Published var log = ""
    @Published var capabilities = "尚未读取"
    @Published var extraCodes:[Int] = []
    @Published var importPlan:ImportPlan?
    @Published var importing = false
    let runner = Runner()
    private var readingsMonitorID = ""
    func record(_ message:String) {
        log += "[\(Date().formatted(date:.omitted,time:.standard))] \(message)\n"
        if log.count > 100000 { log = String(log.suffix(100000)) }
    }
    func execute(_ args:[String]) async -> RunResult {
        let runner = self.runner
        return await Task.detached { runner.run(args) }.value
    }
    func reading(_ result:RunResult) -> Reading? {
        let nums = result.text.split(whereSeparator:{$0.isWhitespace}).compactMap{Int($0)}
        guard result.code == 0, nums.count == 2 else { return nil }
        return Reading(current:nums[0],maximum:nums[1])
    }
    func refresh(group:String = "画面") async {
        // Page changes cancel the previous refresh; wait for its in-flight DDC request.
        while busy {
            do { try await Task.sleep(nanoseconds:50_000_000) } catch { return }
        }
        guard !Task.isCancelled else { return }
        busy = true; defer { busy = false }
        let started = Date()
        status = "正在检测连接…"
        let result = await execute(["display","list"])
        guard !Task.isCancelled else { return }
        var found:[Monitor] = []
        let regex = try! NSRegularExpression(pattern:"^\\[\\d+\\] (.+) \\(([A-Fa-f0-9-]+)\\)$")
        for line in result.text.components(separatedBy:"\n") {
            let ns = line as NSString
            if let m = regex.firstMatch(in:line,range:NSRange(location:0,length:ns.length)) {
                let n = ns.substring(with:m.range(at:1)); let id = ns.substring(with:m.range(at:2))
                if n != "Unknown Display" && n != "Color LCD" { found.append(Monitor(id:id,name:n)) }
            }
        }
        monitors = found
        if !found.contains(where:{$0.id == selected}), let first = found.first { selected = first.id }
        if let monitor = found.first(where:{$0.id == selected}) {
            rememberedName = monitor.name
            UserDefaults.standard.set(selected,forKey:"selectedMonitor"); UserDefaults.standard.set(rememberedName,forKey:"monitorName")
        }
        if readingsMonitorID != selected { readings = [:]; failures = []; extraCodes = []; capabilities = "尚未读取"; readingsMonitorID = selected }
        record("设备检测：\(result.text)")
        guard found.contains(where:{$0.id == selected}) else { readings = [:]; failures = []; status = "显示器未连接 · 可以尝试唤醒"; capabilities = "设备离线"; return }
        let id = selected
        let pageFeatures = features.filter { $0.group == group }
        for (index,f) in pageFeatures.enumerated() {
            guard !Task.isCancelled else { return }
            status = "正在读取\(group) · \(index+1)/\(pageFeatures.count)…"
            let r = await execute(["display",id,"probe",f.hex])
            guard !Task.isCancelled else { return }
            if let v = reading(r) { readings[f.code] = v; failures.remove(f.code) }
            else { readings.removeValue(forKey:f.code); failures.insert(f.code) }
        }
        let count = pageFeatures.filter { readings[$0.code] != nil }.count
        status = pageFeatures.isEmpty ? "已连接" : "\(group)已更新 · \(count)/\(pageFeatures.count) 项可读取"
        record("\(status)，用时 \(String(format:"%.1f",Date().timeIntervalSince(started))) 秒。")
    }
    func readCapabilities() async {
        guard !busy else { return }; busy = true; defer { busy = false }
        status = "正在读取能力清单…"
        let r = await execute(["display",selected,"caps"])
        capabilities = r.code == 0 ? r.text : "显示器未返回有效能力清单；不影响按已确认的控制码读取设置。"
        status = r.code == 0 ? "能力清单已读取" : "能力清单不可用"
        record(status)
    }
    func write(_ code:Int,_ value:Int) async {
        guard !busy else { return }; busy = true; defer { busy = false }
        let id = selected, hex = String(format:"0x%02X",code)
        status = "正在发送设置…"
        let r = await execute(["display",id,"set",hex,String(value)])
        record("写入 \(hex) = \(value)：\(r.text)")
        guard r.code == 0 else { status = "发送失败：显示器不可访问或通信异常"; return }
        try? await Task.sleep(nanoseconds:250_000_000)
        let check = await execute(["display",id,"probe",hex])
        if let v = reading(check) {
            readings[code] = v
            status = v.current == value ? "显示器已回读确认：\(value)" : "指令已发送，但回读为 \(v.current)，尚未确认生效"
        } else { status = "指令已发送，无法回读确认；请观察显示器"; readings.removeValue(forKey:code) }
        record(status)
    }
    func wake() async { await write(0xD6,1) }
    func scan() async {
        guard !busy else {return}; busy = true; defer {busy = false}
        record("开始完整只读扫描，不发送设置指令。")
        let existing = Set(features.map{$0.code})
        for code in 1...255 where !existing.contains(code) {
            if Task.isCancelled {break}
            status = String(format:"只读扫描 %02X / FF…",code)
            let r = await execute(["display",selected,"probe",String(format:"0x%02X",code)])
            if let v = reading(r) { readings[code] = v; if !extraCodes.contains(code) {extraCodes.append(code)} }
        }
        status = "\(Task.isCancelled ? "扫描已停止" : "扫描完成") · 额外找到 \(extraCodes.count) 项"
        record(status)
    }
    func probe(_ code:Int) async {
        guard !busy else {return}; busy = true; defer {busy = false}
        let r = await execute(["display",selected,"probe",String(format:"0x%02X",code)])
        if let v = reading(r) { readings[code] = v; status = "当前值 \(v.current)，报告最大值 \(v.maximum)" }
        else { status = "读取失败或该控制项不受支持" }
        record(String(format:"读取 %02X：",code)+r.text)
    }
    func export() {
        let panel = NSSavePanel(); panel.nameFieldStringValue = "KTC诊断记录.txt"
        if panel.runModal() == .OK, let url = panel.url {
            var s = "KTC 显示器控制台\n设备：\(rememberedName)\nUUID：\(selected)\n\(capabilities)\n\n"
            for key in readings.keys.sorted() {let v = readings[key]!; s += String(format:"%02X",key)+" current=\(v.current) max=\(v.maximum)\n"}
            do { try (s+"\n"+log).write(to:url,atomically:true,encoding:.utf8); status = "日志已导出" } catch {status = "导出失败：\(error.localizedDescription)"}
        }
    }
}
struct Pending: Identifiable { let id = UUID(); let code:Int; let value:Int; let message:String }
struct SliderRow: View {
    let f:Feature; let r:Reading; let disabled:Bool; let commit:(Int)->Void
    @LocalState<Double> var draft:Double = 0
    var body: some View {
        VStack(alignment:.leading,spacing:10) {
            HStack {Text(f.name).font(.system(size:14,weight:.medium)); Spacer(); Text("\(Int(draft)) / \(r.maximum)").monospacedDigit().foregroundStyle(.secondary)}
            Slider(value:$draft,in:0...Double(max(1,r.maximum)),step:1,onEditingChanged:{editing in if !editing {commit(Int(draft))}}).disabled(disabled)
        }.padding(16).background(.background,in:RoundedRectangle(cornerRadius:12))
        .onAppear {draft=Double(r.current)}.onChange(of:r.current) {draft=Double(r.current)}
    }
}
struct ContentView: View {
    @StateObject var model = Model()
    @LocalState<String> var page = "画面"
    @LocalState<Pending?> var pending:Pending?
    @LocalState<String> var rawCode = "D6"
    @LocalState<String> var rawValue = "1"
    @LocalState<Bool> var showUnavailable = false
    @LocalState<Task<Void,Never>?> var scanTask:Task<Void,Never>?
    let pages = ["画面","色彩","声音","游戏与连接","菜单","电源","配置备份","高级","设备信息","日志"]
    var body: some View {
        HStack(spacing:0) {
            VStack(alignment:.leading,spacing:8) {
                Image(systemName:"display").font(.system(size:30)).foregroundStyle(.teal).padding(.bottom,10)
                Text("KTC 控制台").font(.title2.bold())
                Text("让屏幕听你的").foregroundStyle(.secondary).font(.caption).padding(.bottom,22)
                ForEach(pages,id:\.self) {p in
                    Button {page=p} label:{HStack{Image(systemName:icon(p)).frame(width:20);Text(p);Spacer()}.padding(11).background(page == p ? Color.teal.opacity(0.15) : Color.clear,in:RoundedRectangle(cornerRadius:9))}.buttonStyle(.plain)
                }
                Spacer()
                Text("本地运行 · 无后台常驻").font(.caption).foregroundStyle(.secondary)
                Text("Apple Silicon · DDC/CI").font(.caption2).foregroundStyle(.tertiary)
            }.padding(22).frame(width:205).background(Color(nsColor:.windowBackgroundColor))
            Divider()
            VStack(alignment:.leading,spacing:0) {
                HStack {
                    VStack(alignment:.leading,spacing:5) { Text(model.rememberedName).font(.title.bold()); Text("\(model.monitors.contains(where:{$0.id == model.selected}) ? "USB-C / DisplayPort" : "上次连接的显示器")").font(.caption).foregroundStyle(.secondary) }
                    Spacer()
                    if model.monitors.count > 1 {
                        Picker("显示器",selection:$model.selected){ForEach(model.monitors){m in Text(m.name).tag(m.id)}}.labelsHidden().frame(width:150).disabled(model.busy).onChange(of:model.selected){Task{await model.refresh(group:page)}}
                    }
                    Button {Task{await model.refresh(group:page)}} label:{Image(systemName:"arrow.clockwise")}.disabled(model.busy).help("重新检测连接并读取当前页面")
                    Button {Task{await model.wake()}} label:{Label("唤醒显示器",systemImage:"power")}.buttonStyle(.borderedProminent).tint(.teal).disabled(model.busy)
                }.padding(24)
                Divider()
                ScrollView {
                    VStack(alignment:.leading,spacing:16) {
                        Text(page).font(.title2.bold())
                        if ["画面","色彩","声音","游戏与连接","菜单"].contains(page) {
                            Text("设置来自本型号官方控制程序。修改后回读确认；部分项目在 HDR 或场景模式下可能被锁定。").font(.callout).foregroundStyle(.secondary)
                            let list = features.filter{$0.group == page && model.readings[$0.code] != nil}
                            if list.isEmpty {emptyState}
                            LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:12) {
                                ForEach(list){f in if let r = model.readings[f.code] {
                                    if f.slider && r.maximum > 0 && r.current <= r.maximum {
                                        SliderRow(f:f,r:r,disabled:model.busy){v in Task{await model.write(f.code,v)}}
                                    } else if let options=choices[f.code] {
                                        VStack(alignment:.leading,spacing:10) {
                                            Text(f.name).font(.headline)
                                            Picker(f.name,selection:Binding(get:{r.current},set:{v in
                                                if connectionCodes.contains(f.code) {pending=Pending(code:f.code,value:v,message:"修改\(f.name)可能使画面或 USB 外设暂时断开；恢复可能需要显示器实体菜单。")}
                                                else {Task{await model.write(f.code,v)}}
                                            })) {
                                                if !options.contains(where:{$0.0 == r.current}) {Text("当前未知值 \(r.current)").tag(r.current)}
                                                ForEach(options,id:\.0){v in Text(v.1).tag(v.0)}
                                            }.labelsHidden().disabled(model.busy)
                                        }.padding(16).frame(maxWidth:.infinity,alignment:.leading).background(.background,in:RoundedRectangle(cornerRadius:12))
                                    }
                                }}
                            }
                            DisclosureGroup("未读取成功的项目",isExpanded:$showUnavailable) {
                                ForEach(features.filter{$0.group == page && model.readings[$0.code] == nil}){f in Text("\(f.name) · 当前模式不可读取或不受支持").font(.caption).foregroundStyle(.secondary).padding(3)}
                            }
                        } else if page == "配置备份" {backupPage}
                        else if page == "电源" {powerPage}
                        else if page == "高级" {advancedPage}
                        else if page == "设备信息" {
                            Text("这里是显示器通过 DDC 返回的原始信息，固件字段不一定等于菜单里的版本号。").foregroundStyle(.secondary)
                            ForEach(features.filter{$0.group == "设备信息"}) {f in valueRow(f)}
                            Button("读取能力清单"){Task{await model.readCapabilities()}}.disabled(model.busy)
                            GroupBox("能力清单") {Text(model.capabilities).font(.system(.caption,design:.monospaced)).textSelection(.enabled).frame(maxWidth:.infinity,alignment:.leading)}
                        } else {
                            HStack {Text("记录保存在本次会话中，可导出用于排查。").foregroundStyle(.secondary);Spacer();Button("导出日志"){model.export()}}
                            Text(model.log.isEmpty ? "尚无记录" : model.log).font(.system(.caption,design:.monospaced)).textSelection(.enabled).frame(maxWidth:.infinity,alignment:.leading).padding().background(.background,in:RoundedRectangle(cornerRadius:12))
                        }
                    }.padding(24).frame(maxWidth:.infinity,alignment:.leading)
                }.background(Color(nsColor:.underPageBackgroundColor))
                Divider()
                HStack(spacing:10) {if model.busy {ProgressView().controlSize(.small)} else {Image(systemName:"info.circle").foregroundStyle(.teal)};Text(model.status).font(.caption).lineLimit(2);Spacer()}.padding(14)
            }
        }.frame(minWidth:860,minHeight:620)
        .task(id:page){await model.refresh(group:page)}
        .sheet(item:$model.importPlan){plan in ImportPreview(model:model,plan:plan)}
        .alert(item:$pending) {p in Alert(title:Text("确认修改显示器设置"),message:Text(p.message),primaryButton:.default(Text("发送指令")){Task{await model.write(p.code,p.value)}},secondaryButton:.cancel(Text("取消")))}
    }
    var emptyState: some View {VStack(alignment:.leading,spacing:8){Text("当前没有可调项目").font(.headline);Text("显示器可能离线、关闭了 DDC/CI，或在当前画面模式下不开放这些设置。").foregroundStyle(.secondary)}.padding(20).frame(maxWidth:.infinity,alignment:.leading).background(.background,in:RoundedRectangle(cornerRadius:12))}
    func valueRow(_ f:Feature) -> some View {
        HStack {Text(f.name);Text(f.hex).font(.caption.monospaced()).foregroundStyle(.tertiary);Spacer();if let r=model.readings[f.code]{Text("\(r.current)").monospacedDigit();Text("/ \(r.maximum)").foregroundStyle(.secondary)}else{Text("不可读取").foregroundStyle(.secondary)}}.padding(12).background(.background,in:RoundedRectangle(cornerRadius:9))
    }
    var powerPage: some View {
        VStack(alignment:.leading,spacing:16){
            Text("唤醒指令只有在显示器仍可接收 DDC 时才有效。发送成功不等于物理屏幕已经亮起。").foregroundStyle(.secondary)
            if let r=model.readings[0xD6] {Text("当前电源状态：\(r.current == 1 ? "开启" : "代码 \(r.current)")").font(.headline)}
            HStack {Button("发送开启指令"){Task{await model.wake()}}.buttonStyle(.borderedProminent).tint(.teal)
                Button("待机…"){pending=Pending(code:0xD6,value:2,message:"显示器可能不支持此待机值，或待机后不再接收 DDC。可能需要按实体电源键恢复。")}
                Button("关闭显示器…"){pending=Pending(code:0xD6,value:5,message:"显示器将收到关闭指令。你通过显示器给 Mac 供电，这也可能影响供电与合盖连接；恢复可能需要实体电源键。")}
            }.disabled(model.busy)
            Text("建议在唤醒故障发生时先尝试开启，再到日志页导出结果。").font(.callout)
        }.padding(20).background(.background,in:RoundedRectangle(cornerRadius:12))
    }
    var advancedPage: some View {
        VStack(alignment:.leading,spacing:16) {
            Text("已按 M27P20P 官方 Windows 程序修正私有编码。这里保留尚未确认枚举或有额外逻辑的项目，正常调节请使用左侧分类。").foregroundStyle(.secondary)
            ForEach(features.filter{$0.group == "高级" && model.readings[$0.code] != nil}) {f in
                HStack {valueRow(f);Button("编辑"){rawCode=String(format:"%02X",f.code);rawValue=String(model.readings[f.code]!.current)}}
            }
            GroupBox("原始控制") {
                VStack(alignment:.leading,spacing:12){
                    HStack {Text("VCP（十六进制）");TextField("D6",text:$rawCode).frame(width:75);Text("值（十进制）");TextField("1",text:$rawValue).frame(width:90);Spacer()}
                    HStack {
                        Button("读取"){if let c=parsedCode {Task{await model.probe(c)}}}.disabled(model.busy || parsedCode == nil)
                        Button("写入…") {if let c=parsedCode,let v=Int(rawValue), (0...65535).contains(v){pending=Pending(code:c,value:v,message:String(format:"向 VCP %02X 写入 %d。",c,v)+"请仅使用厂商确认过的代码和值。输入源、按键锁、电源或复位指令可能改变连接或清除显示器设置。")}}.disabled(model.busy || parsedCode == nil || Int(rawValue).map{!(0...65535).contains($0)} != false)
                        if let c=parsedCode,let r=model.readings[c]{Text("当前 \(r.current) · 报告最大值 \(r.maximum)").foregroundStyle(.secondary)}
                    }
                    Text("复位、固件升级以及未识别的控制项不参与配置导入。不要按其他显示器的编码含义操作本机。").font(.caption).foregroundStyle(.secondary)
                }.padding(8)
            }
            HStack {Button("扫描全部控制码（只读）"){scanTask=Task{await model.scan();scanTask=nil}}.disabled(model.busy); if scanTask != nil {Button("停止扫描"){scanTask?.cancel()}}; Text("约 30 秒起，用于寻找未公开项目").font(.caption).foregroundStyle(.secondary)}
            ForEach(model.extraCodes,id:\.self){c in
                HStack {Text(String(format:"未解释的控制项 %02X",c));Spacer();Text("\(model.readings[c]?.current ?? 0)");Button("查看"){rawCode=String(format:"%02X",c);rawValue=String(model.readings[c]?.current ?? 0)}}.padding(10)
            }
        }
    }
    var backupPage: some View {
        VStack(alignment:.leading,spacing:18) {
            Text("保存画面、色彩、声音、菜单与游戏设置，在导入前查看差异。").foregroundStyle(.secondary)
            HStack {
                Button("备份当前配置…"){Task{await model.saveBackup()}}.buttonStyle(.borderedProminent).tint(.teal)
                Button("导入配置…"){Task{await model.prepareImport()}}
                Button("查看恢复副本"){model.showBackupFolder()}
            }.disabled(model.busy)
            Text("备份包含已确认编码且可读取的设置。电源、输入源、复位、固件升级和未知私有指令不自动恢复。DSC、KVM 等可能影响连接的项目，需要在预览中额外勾选。").font(.callout)
            Text("导入会核对本显示器身份、逐项校验取值、回读验证，并在应用前保存恢复副本。失败时停止后续写入，详情见日志。").font(.callout).foregroundStyle(.secondary)
        }.padding(20).background(.background,in:RoundedRectangle(cornerRadius:12))
    }
    var parsedCode:Int? { let s=rawCode.trimmingCharacters(in:.whitespaces).lowercased().replacingOccurrences(of:"0x",with:"");guard let v=Int(s,radix:16),(1...255).contains(v) else{return nil};return v }
    func icon(_ p:String)->String {switch p{case "画面":return "sun.max";case "色彩":return "slider.horizontal.3";case "配置备份":return "externaldrive";case "游戏与连接":return "gamecontroller";case "菜单":return "list.bullet.rectangle";case "声音":return "speaker.wave.2";case "电源":return "power";case "高级":return "switch.2";case "日志":return "doc.text";default:return "info.circle"}}
}
@main struct KTCApp: App {
    var body:some Scene {WindowGroup("KTC 显示器控制台"){ContentView()}.defaultSize(width:980,height:720).commands{CommandGroup(replacing:.newItem){}}}
}
