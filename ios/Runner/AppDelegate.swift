import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let keyPath = Bundle.main.path(forResource: "google_maps_api_key", ofType: "txt")
    let googleMapKey: String
    do {
       googleMapKey = try String(contentsOfFile: keyPath!, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
      print("Error reading Google Maps API key: \(error)")
      return false
    }
      
    GMSServices.provideAPIKey(googleMapKey)// specify your API key in the application delegate
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
