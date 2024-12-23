# SwiftDataProject

This repository contains an example project using SwiftData to explore and understand how its features work in practice. The project itself serves as a sandbox for moving code around and experimenting with SwiftData functionalities.

## Key Learnings

### Editing SwiftData Objects

Editing SwiftData objects is remarkably straightforward using `@Bindable`. With this approach:

- You can edit objects directly as bindings.
- Changes persist automatically, giving you a persistent binding-like behavior without additional boilerplate code.

### Filtering with `#Predicate`

Filtering in SwiftData is done using `#Predicate`, which is a macro. Although it looks like regular Swift code, the macro transforms it into something else at compile time. Below are some examples and observations:

#### Example 1: Shorthand Conditional Filtering

```swift
@Query(
    filter: #Predicate<User> { user in
      user.name.localizedStandardContains("R") && user.city == "London"
    },
    sort: \User.name
) var users: [User]
```

This example demonstrates how a simple predicate can be used to filter users whose names contain "R" and are located in "London."

#### Example 2: Expanded Conditional Filtering

```swift
@Query(
    filter: #Predicate<User> { user in
      if user.name.localizedStandardContains("R") {
        if user.city == "London" {
          return true
        } else {
          return false
        }
      } else {
        return false
      }
    },
    sort: \User.name
) var users: [User]
```

This longer version achieves the same result as Example 1 but explicitly writes out the conditional logic. It compiles and works correctly.

#### Example 3: Invalid Predicate

```swift
@Query(
    filter: #Predicate<User> { user in
      if user.name.localizedStandardContains("R") {
        if user.city == "London" {
          return true
        }
      }
      return false
    },
    sort: \User.name
) var users: [User]
```

This example appears to be valid Swift code but results in a compilation error:

```
Predicate body may only contain one expression
```

### Insights on Macro Expansion

When the `#Predicate` macro is expanded, it transforms the code into a series of `PredicateExpressions`. Below is the expanded macro of the Example 2 code that compiles correctly:

```swift
Foundation.Predicate<User>({ user in
    PredicateExpressions.build_Conditional(
        PredicateExpressions.build_localizedStandardContains(
            PredicateExpressions.build_KeyPath(
                root: PredicateExpressions.build_Arg(user),
                keyPath: \name
            ),
            PredicateExpressions.build_Arg("R")
        ),
        PredicateExpressions.build_Conditional(
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_KeyPath(
                    root: PredicateExpressions.build_Arg(user),
                    keyPath: \city
                ),
                rhs: PredicateExpressions.build_Arg("London")
            ),
            PredicateExpressions.build_Arg(
                true
            ),
            PredicateExpressions.build_Arg(
                false
            )
        ),
        PredicateExpressions.build_Arg(
            false
        )
    )
})
```

### Notes on Writing Valid `#Predicate`

- Keep in mind that the body of a predicate must consist of a single expression.
- Expanding the macro can provide insights into how SwiftData translates your code, helping you write valid and optimized predicates.

### Dynamic Filtering and Sorting

#### Constructor Injection for Filtering

You can dynamically change the filtering by using constructor injection:

```swift
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
```

Usage:

```swift
UsersView(minimumJoinDate: showingUpcomingOnly ? .now : .distantPast)
```

#### Adding Sort Descriptors

You can also inject sort descriptors:

```swift
init(minimumJoinDate: Date, sortOrder: [SortDescriptor<User>]) {
    _users = Query(
      filter: #Predicate<User> { user in
        user.joinDate >= minimumJoinDate
      },
      sort: sortOrder
    )
}
```

Usage:

```swift
@State private var sortOrder = [
    SortDescriptor(\User.name),
    SortDescriptor(\User.joinDate)
]

UsersView(
        minimumJoinDate: showingUpcomingOnly ? .now : .distantPast,
        sortOrder: sortOrder
)
```

#### Dynamic Sorting with Picker

```swift
Picker("Sort", selection: $sortOrder) {
    Text("Sort by Name")
        .tag([
            SortDescriptor(\User.name),
            SortDescriptor(\User.joinDate)
        ])
    Text("Sort by Join Date")
        .tag([
            SortDescriptor(\User.joinDate),
            SortDescriptor(\User.name)
        ])
}
```

For better UX when using many buttons, consider a `Menu`:

```swift
Menu("Sort", systemImage: "arrow.up.arrow.down") {
    Picker("Sort", selection: $sortOrder) {
        Text("Sort by Name")
            .tag([
                SortDescriptor(\User.name),
                SortDescriptor(\User.joinDate)
            ])
        Text("Sort by Join Date")
            .tag([
                SortDescriptor(\User.joinDate),
                SortDescriptor(\User.name)
            ])
    }
}
```

### Working with Relationships

Relationships in SwiftData are intuitive. Consider the following `User` model:

```swift
@Model
class User {
  var name: String
  var city: String
  var joinDate: Date

  init(name: String, city: String, joinDate: Date) {
    self.name = name
    self.city = city
    self.joinDate = joinDate
  }
}
```

We can create a `Job` model and link it to a `User`:

```swift
@Model
class Job {
  var name: String
  var priority: Int
  var owner: User?

  init(name: String, priority: Int, owner: User? = nil) {
    self.name = name
    self.priority = priority
    self.owner = owner
  }
}
```

Update `User` to support multiple jobs:

```swift
var jobs = [Job]()
```

#### Handling Migrations

Adding relationships is seamless. SwiftData performs migrations under the hood, but custom migrations can be created for complex scenarios.

Example:

```swift
@main
struct SwiftDataProjectApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(for: User.self)
  }
}
```

Adding users and jobs:

```swift
func addSample() {
    let user1 = User(name: "Piper Chapman", city: "New York", joinDate: .now)
    let job1 = Job(name: "Organize sock drawer", priority: 3)
    let job2 = Job(name: "Make plans with Alex", priority: 4)

    modelContext.insert(user1)

    user1.jobs.append(job1)
    user1.jobs.append(job2)
}
```

#### Cascade Deletion

By default, deleting a `User` does not delete associated jobs. To enable cascading deletions:

```swift
@Relationship(deleteRule: .cascade) var jobs = [Job]()
```

## Summary

This project illustrates the ease and power of SwiftData, especially when working with persistence, filtering, and relationships. With features like `@Bindable`, `#Predicate`, dynamic filtering, and seamless relationship management, SwiftData simplifies complex workflows and enhances code maintainability.
