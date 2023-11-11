# Swizz-Knife

A collection of shared Swift utilities. And no wheels reinvented. Nor knives.

## Terminology

This section contains Swift-specific terms like "framework", and ambiguous terms like "consumer". Other business terms like "module", and technical terms like "repo" (repository) are not included in this section.

- Framework: on a high level it means an isolate software unit that can be used by consumers. A "library", "package", or "SDK" means similar things.
  - We prefer the term "framework" here because in Swift's world, a module is usually built to a `MyLibrary.framework` file.
  - Technical terms in `SPM` is `package` and `target`, and in `Cocoapods` they are `pod` or `spec`, and `subspec`.
- Consumer: an application that references a framework by its interfaces (`@interface` or `protocol`), and they statically or dynamically linked ("embed" or not).

## Modules

Please read the next section for the guideline of creating different frameworks inside this repo.

[Package.swift](./Package.swift) contains the source of truth of our frameworks and their dependencies. The following documents should always reflect the implementation.

### Core

- Business: common features can be used by any Swift applications.
- Dependency: Swift only. Due to limited development resources, we only support a specific `Swift` version (and above).
  - A better approach is to create `CoreSwift51`, `CoreSwift55`, `CoreSwift57` etc.
  - `Core` is available on all platforms that `Swift` can compile, just make sure you have the right `Swift` version.
  - Please note that `Foundation` is *NOT* part of Swift itself! Types like `Date` are platform specific. We'll see it in other modules.

## Building modular frameworks

It is preferred to segregate your framework codebase into different modules. It could be `targets` in `SPM`, or `subspec` in `Cocoapods`.

A common practice is to divide your codebase by business goals, and dependencies.

Because dependencies are nested by nature, our modularized frameworks are also nested.

### Why not build different frameworks?

It is actually recommended to create different frameworks. However, practically, some package management tools like `SPM` does not support multiple framework definition files (`Package.swift` for `SPM`, at least in 2023) in the same repo, and we are using `SPM` here. So we use a single repo to minimize management cost.

This practice is *NOT* recommended for enterprises that have millions to burn; always do things properly, if you can afford it.

### Analyzing business requirements

What goal(s) are you trying to achieve? If you have a framework that contains a Logger and an Obfuscater, while they both deal with `Strings`, it's a bad idea to put them in the same framework.

Why? Because the consumer may or may not use both modules, and it's a waste of compile time, binary size, and runtime resource (if a module contains global instances) to include unused source files. By dividing your modules into different frameworks, you may also gain other benefits, for example making your dependencies more flexible (see the `Moya` example below).

### Analyzing dependencies

When building a module of a framework, it is crucial to understand what it depends on. This is because the consumer always wants minimized dependencies.

We should always try to minimize our dependencies, and segregate our codebase based on dependencies possible (usually it is). This is to avoid introducing unnecessary dependencies of dependencies to consumers.

### An example

Take a look at [Moya](https://github.com/Moya/Moya#moya-version-vs-swift-version), a networking middleware. It's core `Moya` depends on `Alamofire`, so it always comes with its own dependencies.

Other than that, a separated target `CombineMoya` has the same dependencies, but it's segregated because a consumer may not use `Combine`. The segregation results fewer files to compile, and lowers the `Swift` version requirement, and so on.

And for different dependencies like `RxSwift` and `ReactiveSwift`, different targets `RxMoya` and `ReactiveMoya` were created.
