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

## Summary

This project illustrates the ease and power of SwiftData, especially when working with persistence and filtering. By understanding how `@Bindable` and `#Predicate` work, developers can harness these tools to build more efficient and maintainable codebases.
