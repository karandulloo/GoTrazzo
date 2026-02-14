import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API Key - loaded from GoogleMaps-Key.xcconfig (gitignored)
    // Copy GoogleMaps-Key.xcconfig.example to GoogleMaps-Key.xcconfig and add your key
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String,
       !apiKey.isEmpty,
       apiKey != "YOUR_GOOGLE_MAPS_API_KEY" {
      GMSServices.provideAPIKey(apiKey)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
