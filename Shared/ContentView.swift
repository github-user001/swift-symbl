//
//  ContentView.swift
//  Shared
//
//  Created by laptop on 5/2/22.
//
//

import Foundation
import SwiftUI

// Create an ObservableObject to authenticate with the symbol API
class Symbl: ObservableObject {
  @Published
  var session: String = ""
  @Published
  var token: String = ""
  @Published
  var isAuthenticated: Bool = false
  @Published
  var error: String = ""

  @Published
  var appId: String = ""

  @Published
  var appSecret: String = ""

  func authenticate() {
//    // Get the appId from the environment
//    appId = ProcessInfo.processInfo.environment["SYMBL_APP_ID"] ?? "not found"
//    appSecret = ProcessInfo.processInfo.environment["SYMBL_APP_SECRET"] ?? "not found"

    appId = SymblApiKeys.appId
    appSecret = SymblApiKeys.appSecret

    // Get token and expiresIn from UserDefaults
    let defaults = UserDefaults.standard
    let token = defaults.string(forKey: "accessToken")
    let expiresIn = defaults.string(forKey: "expiresIn")

    // If we don't have a token or if the token is expired, get a new one
    if token == nil || expiresIn == nil || expiresIn! < Date().timeIntervalSince1970.description {
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
            defaults.set(token, forKey: "accessToken")
            defaults.set(expiresIn, forKey: "expiresIn")
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

struct ContentView: View {
  @ObservedObject var symbl = Symbl()
  var body: some View {
    VStack {
      Text("Hello, world!")
        .padding()
        .onAppear {
          symbl.authenticate()
        }
      Text(symbl.isAuthenticated ? "Authenticated" : "Not Authenticated")
      Text(symbl.token)
      Text("App Id")
      Text(symbl.appId)
      Text("App Secret")
      Text(symbl.appSecret)
      Text(symbl.error)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
