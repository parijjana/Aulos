# Aulos: Architecture Map (ARCH_MAP)

## Core Rules
- **R1 (DI):** Manual constructor injection only; no singletons.
- **R2 (Gatekeeper):** Centralized `RateLimitDispatcher` for all external APIs.
- **R3 (Symmetry):** Host/Client logic must be role-agnostic.
- R4 (TDD): Every feature must be verified by a corresponding test in the `test/` directory.
- R5 (Quality): Maintain a minimum 85% test coverage floor. Health Checks must verify this before major releases.


## System Overview
- **Domain Layer:** Pure Dart logic and interfaces.
- **Data Layer:** Implementation of domain interfaces (e.g., `JustAudioPlaybackEngine`).
- **Presentation Layer:** Flutter widgets and ViewModels.
- **Core Layer:** Utilities and shared components like `RateLimitDispatcher`.
