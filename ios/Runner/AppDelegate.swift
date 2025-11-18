import UIKit
import Flutter
import GoogleMaps
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Set window background color to match app theme (blue #0057E7)
    if let window = self.window {
      window.backgroundColor = UIColor(red: 0.0, green: 0.341, blue: 0.906, alpha: 1.0)
    }
    
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyD3qNO8dnfJc6sxGR68q6dDkUPe7V1x_Hs")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
