//
//  ContentView.swift
//  Shared
//
//  Created by laptop on 5/2/22.
//
//

import Foundation
import Speech
import SwiftUI

struct ContentView: View {
  @ObservedObject var symbl = Symbl()
  var body: some View {
    VStack {
      Text(symbl.isAuthenticated ? "Authenticated" : "Not Authenticated")
      Text(symbl.token)
      Text(symbl.error)
      Button(action: {
        symbl.connect()
      }) {
        Text("Connect")
      }
    }.onAppear {
      symbl.authenticate()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
