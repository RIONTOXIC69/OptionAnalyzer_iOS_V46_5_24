# OptionAnalyzer iOS — V46.5.24 API Client

This package is the iOS API-client implementation for the existing Option Trading Analyzer.

## Architecture

iOS app -> HTTP API -> existing 9-stage engine/state files

The iOS app does NOT recreate or modify the trading engine.

## Current API

Default LAN API:

http://192.168.0.117:8788

Endpoints used:

- GET /api/v1/status?index=NIFTY%2050
- GET /api/v1/execution?index=NIFTY%2050
- GET /api/v1/stages?index=NIFTY%2050

Supported indexes:

- NIFTY 50
- BANK NIFTY
- SENSEX

## Polling

The client refreshes automatically every 10 seconds and also supports pull-to-refresh.

## Important

The Windows API must be running and reachable from the iPhone.

If the Windows PC IP changes, edit:

API/OptionAnalyzerAPIClient.swift

and change:

var baseURL = "http://192.168.0.117:8788"

## Xcode

Open/create an iOS SwiftUI project and add:

- OptionAnalyzerApp.swift
- API/Models.swift
- API/OptionAnalyzerAPIClient.swift
- Views/ContentView.swift
- Views/StageCard.swift
- Views/MTFRow.swift

Use the supplied Info.plist settings for local HTTP/LAN access.

The app requires a Mac/Xcode to compile and install as a native iOS application. The source can be prepared on Windows now.
