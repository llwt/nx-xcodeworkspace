# XCode Workspace with Nx

This is a proof of concept for using [Nx](https://nx.dev/) with [XCode](https://developer.apple.com/xcode/) to incrementally build iOS apps

To build (and cache) the app using nx, you can run `./nx build AppTwo` (or `AppOne`, `LibOne`, `LibTwo`).

If the app or lib has already been built in CI, you will get a cache hit rather than rebuilding.

XCode is set up to use the outputs of the Nx cached directories (`DerivedData/Build/...`) rather than detecting dependencies and rebuilding them. This means if you clone the repo and try to build an app directly, you will get an error about not being able to find the dependency. This is expected and can be fixed by either:

- running `nx build <app or lib>` from the command line
  - NOTE: since Nx is aware of the dependencies, this will also build the dependencies (or pull from cache) if building an app
- manually building the scheme for the corresponding app or lib in XCode

## CI

This workspace is also setup to run the tests for the apps and libs in CI using GitHub Actions on mac agents.

You can see the recent CI runs in [the workspace for this repo in Nx Cloud](https://cloud.nx.app/orgs/672b7c701d009dbc0d79b3fd/workspaces/672b7caf1d009dbc0d79b3ff/overview).

This roughly follows the [Custom Distributed Task Execution on Github Actions](https://nx.dev/ci/recipes/enterprise/dte/github-dte#custom-distributed-task-execution-on-github-actions) guide.

There are four jobs in the workflow that run in parallel:

- One "Host" job that runs [the `nx affected` command](https://nx.dev/ci/features/affected) to calculate which apps and libs need to be built.
- And three "Agent" jobs that call `nx cloud start-agent` to execute the tasks distributed from Nx cloud.

Some more details on Distributed Task Execution (DTE) with Nx can be found in our docs:

- [Distribute Task Execution](https://nx.dev/ci/features/distribute-task-execution)
- [Custom Distributed Task Execution on Jenkins](https://nx.dev/ci/recipes/enterprise/dte/jenkins-dte)

## XCode Project Config

- XCode Preferences -> Locations -> Derived Data -> `Default` to `Relative`
  - This moves the `DerivedData` folder to the root of the workspace
  - The build commands added to nx use `-derivedDataPath ./DerivedData` to ensure CI and local builds use the same location
- XCode Preferences -> Locations -> Derived Data -> Advanced -> Build Location -> `Unique` to `Shared Folder: Build`
  - Without this, I ran into issues with the build being unable to resolve the dependencies.
    _Someone more familiar with XCode/swift could probably get this working without this setting._
  - This puts all build outputs into `DerivedData/Build/...`
- Project Schemes -> Build -> Build Options -> Find Implicit Dependencies -> `Yes` to `No`
  - This prevents `xcodebuild` from trying to re-build the already built dependencies
  - For development, a new scheme can be created that re-enables this if you want auto-updates for dependencies
  - _Ideally, this would not be needed. But some more work needs to be done to ensure an Nx cache hit results in an `xcodebuild` cache hit._ (see note on this below)

## XCode Target Config -- establish dependencies

- AppOne Target -> General -> Frameworks, Libraries, and Embedded Content -> Add: `LibOne.framework`
- LibTwo Target -> General -> Frameworks, Libraries, and Embedded Content -> Add: `LibOne.framework`
- AppTwo Target -> General -> Frameworks, Libraries, and Embedded Content -> Add: `LibTwo.framework`

## Nx Config

_We should be able to automate this with an Nx plugin that reads the `xcworkspace` and `xcodeproj` files and generates the targets and dependencies automatically. We do this for Gradle in java projects for example_

- AppOne Project.json -> `implicitDependencies` to `["LibOne"]`
- LibTwo Project.json -> `implicitDependencies` to `["LibOne"]`
- AppTwo Project.json -> `implicitDependencies` to `["LibTwo"]`

---

- Nx.json -> `targetDefaults.build.dependsOn` to `["^build"]`
- Nx.json -> `targetDefaults.build.cache` to `true`
- Nx.json -> `targetDefaults.build.outputs` to `[ "{workspaceRoot}/DerivedData/**/{projectName}.*/**/*" ]`

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
- Re-enable the Find Implicit Dependencies option in schemes
  - I wasn't able to pin down exactly xcode determines a project needs to be rebuilt
  - XCode seems to be looking for more than just `DerivedData/Build/Intermediates/...` and `DerivedData/Build/Products/...` (what we're currently caching)
  - It seems like we may need to restore the `mtime` for DerivedData files. See this [post from CircleCi](https://michalzaborowski.medium.com/circleci-60-faster-builds-use-xcode-deriveddata-for-caching-96fb9a58930) for more details.
  - The `Legacy` option in `Xcode Settings -> Location -> Derived Data -> Advanced` seemed like it may also be worth further exploration. It creates a `build` directory in the individual projects that contains more than just the intermediates and products. However, I ran into issues getting xcode to resolve the compiled products (e.g. AppOne could not find LibOne when building). Configuring the "Framework Search Paths" seems to be the answer, but I wasn't able to get it to work correctly in my limited time.
- Find a way to integrate `nx` into `xcodebuild` or whatever you use for building currently
  - NOTE: if nx cache hits also result in xcode cache hits, this is probably not necessary
- Make Nx aware of `test` targets and run them + cache as part of the CI run
- the `package.json` and `npm install` in CI should not be necessary
  - there is a bug when auto-installing nx-cloud in non-js workspaces right now, once resolved this can be removed
