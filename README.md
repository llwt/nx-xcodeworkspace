# XCode Workspace with Nx

## XCode Project Config

- XCode Preferences -> Locations -> Derived Data -> `Default` to `Relative`
  - This moves the `DerivedData` folder to the root of the workspace
- XCode Preferences -> Locations -> Derived Data -> Advanced -> Build Location -> `Unique` to `Shared Folder: Build`
  - Without this, I ran into issues with the build being unable to resolve the dependencies.
    _Someone more familiar with XCode/swift could probably get this working without this setting._
- Project Schemes -> Build -> Build Options -> Find Implicit Dependencies -> `Yes` to `No`
  - This prevents `xcodebuild` from trying to re-build the already built dependencies
  - For development, a new scheme can be created that re-enables this if you want auto-updates for dependencies
- AppOne Target -> General -> Frameworks, Libraries, and Embedded Content -> Add: `LibOne.framework`

## Nx Config

- AppOne Project.json -> `implicitDependencies` to `["LibOne"]`
- AppOne Project.json -> `targets.build.dependsOn` to `["^build"]`
- LibOne Project.json -> `targets.build.cache` to `true`

## Optional Changes

- Project Target -> Build Settings -> Enable Module Verifier -> from `Yes` to `No`
  - Useful while iterating locally to avoid slow builds in libraries

## Things I tried that didn't work

- Adding a "Run Script" build phase to use `nx` to build the dependencies
  - XCode chokes because it doesn't like multiple `xcodebuild`s happening at once in the same workspace (`xcodebuild -> nx -> xcodebuild`)
- Having a Derived Data folder per project and/or changing build locations to be relative to the project
  - I could not get XCode to find the modules in a different Derived Data folder.
    _Someone more familiar with XCode might be able to figure this out._

## Improvements that can be made

- Create nx plugin to read `xcworkspace` and `xcodeproj` files and generate the targets and dependencies automatically
- Find a way to integrate `nx` into `xcodebuild` or whatever you use for building currently
