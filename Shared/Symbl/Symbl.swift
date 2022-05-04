//
// Created by laptop on 5/4/22.
//
import Foundation
import SwiftUI

class Symbl: ObservableObject {
  @Published
  var session: String = ""
  @Published
  var token: String = ""
  @Published
  var isAuthenticated: Bool = false
  @Published
  var error: String = ""

  func authenticate() {
    let appId = SymblApiKeys.appId
    let appSecret = SymblApiKeys.appSecret

    // Get token and expiresIn from UserDefaults
    let defaults = UserDefaults.standard
    let token = defaults.string(forKey: "accessToken")
    let expiresAt = defaults.string(forKey: "expiresAt")

    // If we don't have a token or if the token is expired, get a new one
    if token == nil || expiresAt == nil || expiresAt! < Date().timeIntervalSince1970.description {
      let authOptions: [String: Any] = [
        "type": "application",
        "appId": appId,
        "appSecret": appSecret,
      ]

      let url = "https://api.symbl.ai/oauth2/token:generate"

      let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try? JSONSerialization.data(withJSONObject: authOptions, options: [])

      let session = URLSession.shared
      session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
        if let data = data {
          do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let token = json["accessToken"] as! String
            let expiresIn = json["expiresIn"] as! Double
            // Add expires in to the current time
            let expiresAt = Date().timeIntervalSince1970 + expiresIn
            // Save expiresAt and token to UserDefaults
            defaults.set(token, forKey: "accessToken")
            defaults.set(expiresAt, forKey: "expiresAt")

            DispatchQueue.main.async {
              self.token = token
              self.isAuthenticated = true
            }
          } catch {
            DispatchQueue.main.async {
              self.error = error.localizedDescription
            }
          }
        }
      }).resume()

    } else {
      DispatchQueue.main.async {
        self.token = token!
        self.isAuthenticated = true
      }
    }
  }
}
