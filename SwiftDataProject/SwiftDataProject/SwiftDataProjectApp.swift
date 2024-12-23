//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import SwiftData
import SwiftUI

@main
struct SwiftDataProjectApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(for: User.self)
  }
}
