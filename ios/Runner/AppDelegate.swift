import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.pathExtension == "quiz" else {
            print("File is not a QUIZ file, ignoring...")
            return false
        }

        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "quiz.file", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("openFile", arguments: url.path) { result in
            if let error = result as? FlutterError {
                print("Failed to open file: \(error.message ?? "Unknown error")")
            }
        }
        return true
    }
}
