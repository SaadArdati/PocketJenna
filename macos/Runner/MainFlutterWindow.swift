import Cocoa
import FlutterMacOS
import bitsdojo_window_macos
import LaunchAtLogin

class MainFlutterWindow: BitsdojoWindow {

    override func bitsdojo_window_configure() -> UInt {
      return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
    }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

      if #available(macOS 10.13, *) {
          var localStyle = self.styleMask;
          localStyle.insert(.fullSizeContentView)
          self.styleMask = localStyle;
          self.titlebarAppearsTransparent = true
      }

      self.collectionBehavior = .canJoinAllSpaces

      let controller = self.contentViewController as! FlutterViewController
      let channel = FlutterMethodChannel(name: "dev.saadardati.pocketjenna/launchAtStartup", binaryMessenger: controller.engine.binaryMessenger)
      channel.setMethodCallHandler(handleMessage)
      
      RegisterGeneratedPlugins(registry: flutterViewController)
      
      super.awakeFromNib()
  }
    
    private func handleMessage(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "toggleLaunchAtStartup":
            LaunchAtLogin.Toggle()
            result(LaunchAtLogin.isEnabled)
        case "isLaunchAtStartupEnabled":
            result(LaunchAtLogin.isEnabled)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func isLaunchAtStartupEnabled() -> Bool {
        return LaunchAtLogin.isEnabled
    }
}
