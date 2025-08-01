import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            sendToFlutter(url.path)
        }
    }
    
    override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        sendToFlutter(filename)
        return true
    }
    
    override func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for url in filenames {
            sendToFlutter(url)
        }
    }
    
    func sendToFlutter(_ filename: String) {
        if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "quiz.file", binaryMessenger: controller.engine.binaryMessenger)
            channel.invokeMethod("openFile", arguments: filename)
        }
    }
    
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
