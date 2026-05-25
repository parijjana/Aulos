# Aulos: Lean Engineering Strategy

## Core Mandates

### Engineering Standards
- **Surgical TDD:** Every feature or bug fix MUST be preceded by a failing test. The passing test is the definitive proof of implementation.
- **Relaxed DI:** Use defaulting constructors for services and plugins to prevent cascading breaks.
- **OOP & Clean Code:** Maintain modular, role-agnostic logic (Host/Client symmetry).

### Documentation Standards
- **Daily Progress Logs:** Maintain date-stamped logs in the `progress_logs/` directory (e.g., `progress_logs/YYYY-MM-DD.md`). Always check the previous day's log at session start.
- **Design Philosophy:** Maintain high-level UX and aesthetic guiding principles in the `design_philosophy/` directory. This captures the "how and why" behind interface and behavioral decisions (e.g., Responsive Tabbing).
- **Design Features:** Maintain functional feature and service definitions in the `design_features/` directory. Each file should contain the summary, rationale, and expected behavior.
- **Architecture Map:** Maintain `ARCHITECTURE.md` as the source of truth for structural mapping and system rules.
- **Lean Context:** Do NOT maintain a detailed "Development Matrix" or "Files Touched" lists in Markdown.

### Verification
- **100% Green Mandate:** `flutter test` must be 100% green before any executable build (Windows/Android).
- **Health Checks:** Run the full test suite upon explicit request or before session handoff.

## Project Mandates (2026-05-08)
1. **Daily Progress Logs:** Maintain granular, date-stamped logs in the `progress_logs/` directory.
2. **Arch Map:** Maintain `ARCHITECTURE.md`.
3. **TDD Mandate:** TDD is the primary source of truth for feature completion.
4. **OOP Preference:** Prefer clean OOP for core logic.
5. **Platform Preference:** Flutter (Mobile + Desktop).
6. **Ignore Files:** Automatically maintain `.geminiignore` and `.gitignore` for build artifacts.
## Architectural Mandates: Context Density & File Management

### 1. General Principles
- **The 200-Line Threshold:** Aim to keep all source files under 200 lines. If a file exceeds 300 lines, it MUST be audited for decomposition.
- **Single Responsibility:** Each file should export exactly one primary class, function, or logical grouping.
- **Import Hygiene:** Avoid "barrel files" (export * from everything) as they confuse agents during symbol resolution.

### 2. Flutter/Dart Mandates
- **Widget Extraction:**
  - Never use private helper methods that return a widget (`Widget _buildHeader()`).
  - Extract any sub-widget tree exceeding 50 lines into a separate file in a `widgets/` subdirectory within the feature folder.
- **Logic Separation:**
  - Move complex validation, formatting, or business logic into `extension` files or `mixins`.
  - Keep `build()` methods declarative. Any calculation or complex state logic must be moved to a Controller/ViewModel.
- **Feature-First Structure:**
  - Organize by feature (e.g., `lib/features/profile/`), not by layer (`lib/models/`).
  - Each feature folder should have its own `screens/`, `widgets/`, and `providers/` subfolders.
- **Theming:** Use `Theme.of(context)` strictly. Do not hardcode styling in widget files.

### 3. Python Mandates
- **Function Length:** Any function exceeding 25 lines must be evaluated for splitting into helper functions or utility classes.
- **Module Decomposition:**
  - Use FastAPI `APIRouter` to split large API definitions into domain-specific modules.
  - Avoid "God Modules" (e.g., a single `utils.py`). Use directory-based modules with an `__init__.py`.
- **Type Density:** Mandate strict type hinting (Python 3.10+ syntax).
- **Data Containers:** Prefer `dataclasses` or Pydantic models over raw dictionaries.

### 4. Vite & React (TypeScript) Mandates
- **Component Line Limits:**
  - Components should not exceed 100 lines (JSX + Logic).
  - If a `return` block (JSX) is more than 40 lines, sub-components MUST be extracted into a `components/` subfolder.
- **Hook Extraction (Logic Separation):**
  - Any component using more than 3 `useState` hooks or any `useEffect` longer than 10 lines MUST move that logic into a Custom Hook.
- **TypeScript Interface Hygiene:**
  - Do not define large interfaces or types inside the component file. Move them to a sibling `.types.ts` file.
- **Feature-First Structure:**
  - Follow the `src/features/[feature-name]/` pattern with its own `components/`, `hooks/`, etc.

### 5. Agent Operational Mandates (Proactive Refactoring)
- **Surgical Refactoring:** When an agent is asked to modify a file that violates the size thresholds, the agent should first propose a "Decomposition Plan" before applying the requested feature/fix.
- **Documentation Over implementation:** Prioritize reading `ARCHITECTURE.md` or `GEMINI.md` before doing wide-scale `read_file` calls.
