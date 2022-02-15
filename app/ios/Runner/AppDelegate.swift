import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let aesChannel = FlutterMethodChannel.init(name: "ipfspass.tech", binaryMessenger: controller.binaryMessenger)
    aesChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if let req = call.arguments as? [String: String] {
            if ("encryptData" == call.method) {
                result(Aes.encryptData(masterPassword: req["masterPassword"]!, rawData: req["rawData"]!))
            } else if ("decryptData" == call.method){
                result(Aes.decryptData(masterPassword: req["masterPassword"]!, encryptedData: req["encryptedData"]!))
            } else if ("sha256" == call.method) {
                result(sha256(req["data"]!).map{ String(format: "%02x", $0)}.joined())
            }
        }else{
            result("")
        }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
