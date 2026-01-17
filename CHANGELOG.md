# Changelog

All notable changes to this project will be documented in this file.

## [0.0.4] - 2026-01-17

### Changed
- **BREAKING**: Changed default value of `embedInNavigationStack` to `false` in `router.sheet()`, `router.fullScreenCover()`, and `presentation.present()`. You must now explicitly set `embedInNavigationStack: true` if you need a NavigationStack inside a modal.
- **API**: Simplified `ScopedRouter` usage with new initializer `ScopedRouter(Route.self) { ... }` to improve type inference.
- **Refactor**: Removed deprecated `ModernNavigationStack` (use `RouterNavigationStack` instead).
- **Refactor**: Removed unused `DeepLink` module and `NavigationPath` extensions to simplify the library core.

### Documentation
- Updated `README.md` and `SwiftUI_Nested_NavigationStack_Issue.md` to reflect the new default behavior and API changes.

## [0.0.3] - 2026-01-17

### Added
- **Component**: Introduced `ScopedRouter` component to provide a standardized way to create isolated navigation environments for modal views. This solves the "Nested NavigationStack" issue by ensuring sheets have their own independent `Router` instance.
- **Documentation**: Updated `README.md` and `docs/SwiftUI_Nested_NavigationStack_Issue.md` with comprehensive guidelines on "Push vs Sheet" navigation patterns and the correct usage of `ScopedRouter`.
- **Documentation**: Clarified the usage of `dismiss` vs `router.dismiss` in modal contexts.

### Changed
- **Refactor**: Replaced ad-hoc `ScopedRouterView` implementations in the Example app with the new library-provided `ScopedRouter`.

## [0.0.2] - 2026-01-17

### Changed
- **Refactor**: Reorganized library source code into functional subdirectories (`Core`, `Navigation`, `Presentation`, `Router`) for better maintainability.
- **Example**: Refactored `TGNavigationDemo` into a modular architecture using local Swift Packages (`HomeFeature`, `NavigationFeature`, `SettingsFeature`, `AppCore`, `UIComponents`).
- **Example**: Implemented `RouteHandler` protocol for decoupled route registration across modules.
- **Example**: Centralized reusable UI components in `UIComponents` and core logic in `AppCore`.

## [0.0.1] - 2026-01-16

### Fixed
- **Navigation**: Resolved critical nested `NavigationStack` issue where pushing routes (e.g., `.settings`) caused path binding loss and immediate `popToRoot`.
- **Navigation**: Fixed inconsistent UI in `LoginView`, `SettingsView`, and `ProfileView` when accessed via Push vs. Sheet/Modal.
- **Navigation Guard**: Corrected behavior where `LoginView` displayed a "Cancel" button instead of a "Back" button when redirected via Push navigation.

### Added
- **Architecture**: Introduced explicit separation of Push and Sheet routes in `AppRoute` (e.g., `.settings` vs `.settingsSheet`) to enforce correct `NavigationStack` hierarchy.
- **UI**: Added `isModal` property to core views to dynamically adjust toolbar buttons (Back vs. Cancel/Close) based on presentation context.
- **Documentation**: Added `docs/SwiftUI_Nested_NavigationStack_Issue.md` detailing the analysis and solution for the nested navigation stack problem.
