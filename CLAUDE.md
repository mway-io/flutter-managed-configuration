# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`managed_configurations` is a Flutter plugin that reads managed app configuration from MDM (Mobile Device Management) providers. It supports Android, iOS, and macOS. The plugin provides both a one-shot getter and a stream for listening to configuration changes.

## Commands

```bash
# Analyze Dart code
fvm flutter analyze

# Run the example app (from example/ directory)
cd example && fvm flutter run

# Dry-run publish check
fvm flutter pub publish --dry-run
```

There are no unit tests in this project.

## Architecture

This is a federated Flutter plugin using **method channels** and **event channels** for native communication.

### Dart layer (`lib/`)

- `managed_configurations.dart` — Public API: `ManagedConfigurations` class and `Severity` enum. Entry point for consumers.
- `managed_configurations_platform_interface.dart` — Abstract platform interface extending `PlatformInterface`.
- `managed_configurations_method_channel.dart` — Default implementation using `MethodChannel` (`managed_configurations_method`) and `EventChannel` (`managed_configurations_event`). Decodes JSON strings from native into `Map<String, dynamic>`.

### Android (`android/src/main/kotlin/`)

- Single file: `ManagedConfigurationsPlugin.kt`
- Uses `RestrictionsManager` to read app restrictions (runs I/O on background thread via `Executors`)
- Listens for `ACTION_APPLICATION_RESTRICTIONS_CHANGED` broadcasts and pushes updates through EventChannel
- Supports `KeyedAppStatesReporter` for reporting state back to EMM (Android-only feature)
- Uses Gson with a custom `BundleTypeAdapterFactory` for serializing `Bundle` to JSON

### iOS/macOS (`darwin/Classes/`)

- Single file: `ManagedConfigurationsPlugin.swift` — shared between iOS and macOS via `sharedDarwinSource`
- Reads from `UserDefaults` key `com.apple.configuration.managed`
- `SwiftStreamHandler` observes `UserDefaults.didChangeNotification` for live updates, deduplicating via last-known JSON string

### Channel names

| Channel | Type | Purpose |
|---|---|---|
| `managed_configurations_method` | MethodChannel | One-shot config reads + `reportKeyedAppState` |
| `managed_configurations_event` | EventChannel | Stream of config change notifications |

## Lint Configuration

Uses `flutter_lints` with `camel_case_types` and `non_constant_identifier_names` rules disabled (see `analysis_options.yaml`).

## Known Quirk

The stream getter is misspelled as `mangedConfigurationsStream` (missing 'a' in "managed") — this is part of the public API and must remain for backwards compatibility.
