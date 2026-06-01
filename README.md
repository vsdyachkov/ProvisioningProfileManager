# ProfileManager

ProfileManager is a small macOS app for viewing, searching, sorting, and deleting local Xcode provisioning profiles.

This project is inspired by Hippo's original Provisioning Profile Manager, but it is not a direct fork of the old codebase. The app was rewritten from scratch in Swift/SwiftUI, built with Xcode 26, and targets macOS 15 and newer.

macOS 15 is macOS Sequoia, Apple's 2024 macOS release. Older macOS versions are intentionally not supported so the code can stay small and use modern system APIs.

## Features

- Native Apple Silicon macOS app.
- SwiftUI interface with searchable and sortable profile list.
- Reads both modern and legacy Xcode provisioning profile folders.
- Deletes selected local `.mobileprovision` files.
- Uses a single AppIcon asset for Finder, Dock, and the app bundle.
