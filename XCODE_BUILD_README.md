# OptionAnalyzer V46.5.24 — Xcode Project Package

This package adds a native Xcode project container around the existing Swift source files.

## Windows -> GitHub
Upload this entire folder to a private GitHub repository.

## Xcode
Open `OptionAnalyzer.xcodeproj` in Xcode.

Target: `OptionAnalyzer`
Version: `46.5.24`
Build: `1`
Deployment target: iOS 17.0
Bundle ID: `com.optionanalyzer.mobile` (change if needed)

Set your Apple Developer Team under Signing & Capabilities.

## API
The Swift client is configured for:
`http://192.168.0.117:8788`

The Windows analyzer/API must remain reachable from the iPhone over the same LAN for the local-network build.

## Important
The Xcode project file is generated for the existing source tree; it has not been compiled here because Xcode/macOS is not available in this Windows environment.
