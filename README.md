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

## XCode Target Config -- establish dependencies

- AppOne Target -> General -> Frameworks, Libraries, and Embedded Content -> Add: `LibOne.framework`
- LibTwo Target -> General -> Frameworks, Libraries, and Embedded Content -> Add: `LibOne.framework`
- AppTwo Target -> General -> Frameworks, Libraries, and Embedded Content -> Add: `LibTwo.framework`

## Nx Config

- AppOne Project.json -> `implicitDependencies` to `["LibOne"]`
- LibTwo Project.json -> `implicitDependencies` to `["LibOne"]`
- AppTwo Project.json -> `implicitDependencies` to `["LibTwo"]`

---

- Nx.json -> `targetDefaults.build.dependsOn` to `["^build"]`
- Nx.json -> `targetDefaults.build.cache` to `true`
- Nx.json -> `targetDefaults.build.outputs` to `"{workspaceRoot}/DerivedData/**/{projectName}.*/**/*"`

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
- Configure re-enables the Find Implicit Dependencies option in schemes and uses nx cache when present rather than re-building
   - I wasn't able to pin down exactly how to prevent xcode from rebuilding
   - Just caching the intermediates and products did not seem to be enough
   - The `Legacy` option in `Xcode Settings -> Location -> Derived Data -> Advanced` seemed like it may work, however I ran into issues getting xcode to resolve the compiled products. Configuring the "Framework Search Paths" seems to be the answer, but I wasn't able to get it to work.
   - Also, it seems like we may need to restore the `mtime` for DerivedData files. See this [post from CircleCi](https://michalzaborowski.medium.com/circleci-60-faster-builds-use-xcode-deriveddata-for-caching-96fb9a58930) for more details.
- An Nx cache hit for a lib or app should be equivalent to one from XCode
   - Right now, we're only caching the build outputs
- Nx can distribute test tasks in addition to build tasks
- the `package.json` should not be necessary -- there is a bug in nx-cloud that requires in in CI for now