//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import SwiftData
import SwiftUI

struct UsersView: View {
  @Query var users: [User]

  var body: some View {
    List(users) { user in
      Text(user.name)
    }
  }

  init(minimumJoinDate: Date) {
    _users = Query(
      filter: #Predicate<User> { user in
        user.joinDate >= minimumJoinDate
      },
      sort: \User.name
    )
  }
}

#Preview {
  UsersView(minimumJoinDate: .now)
    .modelContainer(for: User.self)
}
