# iOS App (XcodeGen)

Generate the Xcode project and build without using the GUI.

## Install

```
brew install xcodegen
```

## Generate

```
cd ios/IBKRWatchApp
./scripts/generate.sh
```

## Build (Simulator)

```
cd ios/IBKRWatchApp
./scripts/build_sim.sh
```

Notes:

- Build only (no Simulator UI).
- If you want to run on a device, set a valid team in Xcode.
