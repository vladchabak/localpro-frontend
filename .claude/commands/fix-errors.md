---
description: Run flutter analyze, read each error in context, fix all in one pass
model: claude-sonnet-4-6
---

Fix all Dart analysis errors in the project.

1. Run `flutter analyze --no-fatal-infos` and capture the full output.
2. If there are no errors or warnings, report clean and stop.
3. Group errors by file. For each file with errors:
   - Read the file to understand the full context around each error
   - Fix all errors in that file in one Edit call (don't fix one at a time and re-analyze between)
4. After fixing all files, re-run `flutter analyze --no-fatal-infos` to confirm clean.
5. If new errors appear (introduced by fixes), fix those too. Repeat until clean.

Common error patterns in this project:
- Missing `if (context.mounted)` before `context.go()` after an `await`
- `CardTheme` → should be `CardThemeData` in `ThemeData`
- Generated `.g.dart` file missing → run `flutter pub run build_runner build --delete-conflicting-outputs` first
- Wrong `Ref` type in `@riverpod` function signature

Do not suppress errors with `// ignore:` unless the suppression is genuinely correct (e.g. `// ignore: deprecated_member_use` with a comment explaining why).
