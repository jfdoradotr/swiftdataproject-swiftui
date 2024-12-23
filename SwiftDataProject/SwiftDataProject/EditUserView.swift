//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import SwiftData
import SwiftUI

struct EditUserView: View {
  @Bindable var user: User

  var body: some View {
    Form {
      TextField("Name", text: $user.name)
      TextField("City", text: $user.city)
      DatePicker("Join Date", selection: $user.joinDate)
    }
    .navigationTitle("Edit User")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  do {
    let config = ModelConfiguration.init(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: User.self, configurations: config)
    let user = User(name: "James Hetfield", city: "Downey", joinDate: .now)
    return EditUserView(user: user)
      .modelContainer(container)
  } catch {
    return Text("Error: \(error)")
  }
}
