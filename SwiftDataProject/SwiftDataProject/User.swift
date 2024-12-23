//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import Foundation
import SwiftData

@Model
class User {
  var name: String
  var city: String
  var joinDate: Date
  @Relationship(deleteRule: .cascade) var jobs = [Job]()

  init(name: String, city: String, joinDate: Date) {
    self.name = name
    self.city = city
    self.joinDate = joinDate
  }
}
