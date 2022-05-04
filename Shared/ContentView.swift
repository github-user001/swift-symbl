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
//      Text(symbl.appId)
      Text("App Secret")
//      Text(symbl.appSecret)
      Text(symbl.error)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
