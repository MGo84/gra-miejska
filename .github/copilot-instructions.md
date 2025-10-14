# Copilot Instructions for gra-miejska

## Project Overview
This monorepo contains three main components:
- **Flutter Mobile App** (`app/gra_miejska`): Main user-facing app, with modular structure (core, theme, localization, fonts).
- **Admin Panel** (`panel-admina`): Next.js React app for admin operations.
- **Backend** (`backend`): FastAPI Python backend serving REST endpoints.

## Developer Workflows
- **Unified Dev Startup:** Use `start_dev.ps1` from the repo root to launch backend (FastAPI, port 8000) and admin panel (Next.js, port 3000) in separate terminals.
- **Flutter App:**
  - Run with `flutter run` inside `app/gra_miejska`.
  - Tests: `flutter test` (see `test/widget_test.dart` for example).
  - Hot reload is supported for rapid UI iteration.
- **Admin Panel:**
  - Dev: `npm run dev` in `panel-admina`.
  - Build: `npm run build`.
- **Backend:**
  - Dev: `python -m uvicorn main:app --reload` in `backend`.

## Key Architectural Patterns
- **Flutter App:**
  - Modularized under `lib/core/` (e.g., `theme/`, `localization/`).
  - Localization: JSON files in `lib/core/localization/translation/` (pl.json, en.json, de.json).
  - Fonts: Custom fonts in `lib/fonts/`, referenced in `pubspec.yaml`.
- **Backend:**
  - Simple FastAPI app, endpoints in `main.py`.
  - No database integration by default; endpoints return static data.
- **Admin Panel:**
  - Standard Next.js 15+ with React 19, Tailwind CSS, ESLint.

## Conventions & Integration
- **No custom codegen or build scripts** beyond standard framework tools.
- **No monorepo-level package management**; each app manages its own deps.
- **Cross-component communication** is via REST (see backend endpoints in `main.py`).
- **Polish/English/German localization**: Add new keys to all JSONs in `lib/core/localization/translation/`.

## Examples
- To add a new backend endpoint: edit `backend/main.py` and restart backend.
- To add a new localization string: update all JSONs in `lib/core/localization/translation/`.
- To add a new font: place TTF in `lib/fonts/` and reference in `pubspec.yaml`.

## References
- `start_dev.ps1`: Unified dev startup script
- `app/gra_miejska/lib/core/`: App modularization (theme, localization)
- `backend/main.py`: REST API endpoints
- `panel-admina/package.json`: Admin panel scripts

---
For questions or unclear patterns, check the respective README files or ask for clarification.