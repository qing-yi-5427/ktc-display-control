import Foundation
@main struct Tests {
 static func main() throws {
  func sample(_ settings:[BackupSetting], version:Int=1, id:String="test")->MonitorBackup {.init(format:"KTCControl.Configuration",version:version,model:"M27P20P",monitorID:id,created:Date(),settings:settings)}
  let good=sample([.init(code:16,value:50,name:"亮度"),.init(code:244,value:2,name:"分区调光")])
  try validateBackup(good,model:"M27P20P",id:"test")
  let enc=JSONEncoder();enc.dateEncodingStrategy = .iso8601
  let dec=JSONDecoder();dec.dateDecodingStrategy = .iso8601
  let round=try dec.decode(MonitorBackup.self,from:enc.encode(good))
  assert(round.settings.count == 2 && round.settings[1].value == 2)
  let bad:[MonitorBackup]=[
   sample([],version:1),sample(good.settings,version:2),sample(good.settings,id:"another"),
   sample([good.settings[0],good.settings[0]]),sample([.init(code:214,value:1,name:"power")]),
   sample([.init(code:244,value:99,name:"invalid enum")]),sample([.init(code:16,value:-1,name:"negative")]),
   sample([.init(code:16,value:65536,name:"overflow")]),sample([.init(code:4,value:1,name:"reset")])]
  for b in bad {do {try validateBackup(b,model:"M27P20P",id:"test");fatalError("Invalid backup accepted")}catch{}}
  assert(!backupCodes.contains(0xD6) && !backupCodes.contains(0x60) && !backupCodes.contains(4))
  print("PASS: valid configuration, JSON roundtrip, 9 invalid cases, excluded power/input/reset")
 }
}
