import Cocoa
import FlutterMacOS
import bitsdojo_window_macos

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

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
