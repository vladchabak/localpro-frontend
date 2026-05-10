---
description: Run build_runner and surface code generation errors
model: claude-haiku-4-5-20251001
---

Run Flutter code generation for this project.

1. Execute: `flutter pub run build_runner build --delete-conflicting-outputs`
2. If it succeeds: list every `.g.dart` file that was generated or updated.
3. If it fails: read the full error, identify the root cause (missing import, wrong annotation, conflicting output, type mismatch), fix it in the source file, then re-run. Repeat until clean.

Never run `flutter pub get` unless packages are actually missing.
