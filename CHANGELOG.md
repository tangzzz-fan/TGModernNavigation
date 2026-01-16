# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2026-01-16

### Fixed
- **Navigation**: Resolved critical nested `NavigationStack` issue where pushing routes (e.g., `.settings`) caused path binding loss and immediate `popToRoot`.
- **Navigation**: Fixed inconsistent UI in `LoginView`, `SettingsView`, and `ProfileView` when accessed via Push vs. Sheet/Modal.
- **Navigation Guard**: Corrected behavior where `LoginView` displayed a "Cancel" button instead of a "Back" button when redirected via Push navigation.

### Added
- **Architecture**: Introduced explicit separation of Push and Sheet routes in `AppRoute` (e.g., `.settings` vs `.settingsSheet`) to enforce correct `NavigationStack` hierarchy.
- **UI**: Added `isModal` property to core views to dynamically adjust toolbar buttons (Back vs. Cancel/Close) based on presentation context.
- **Documentation**: Added `docs/SwiftUI_Nested_NavigationStack_Issue.md` detailing the analysis and solution for the nested navigation stack problem.
