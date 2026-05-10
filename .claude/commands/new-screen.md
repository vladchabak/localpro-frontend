---
description: Generate a full feature folder (data + domain + presentation) wired to GoRouter
model: claude-sonnet-4-6
---

Create a complete feature screen for: $ARGUMENTS

The argument format is: `<feature-name> <route-path>` (e.g. `listing /listings/:id`)

Steps:
1. Read `lib/core/router/app_router.dart` to understand the current route structure.
2. Read `docs/code-rules.md` and `docs/design.md` before writing any code.
3. Create the feature folder `lib/features/<feature>/` with three layers:

   **data/**
   - `<feature>_repository.dart` — repository class with methods for each API call this screen needs
   - `<feature>_api.dart` — `@RestApi` Retrofit interface (if API calls are needed)

   **domain/**
   - `<feature>_providers.dart` — `@riverpod` providers: one for the repository, one per async data need

   **presentation/**
   - `<feature>_screen.dart` — `ConsumerWidget` implementing all three `AsyncValue` states: loading → skeleton widget, error → `AppErrorWidget(onRetry:)`, data → content

4. Add the new route to `app_router.dart` using GoRouter `GoRoute`. Use `context.go()` / `context.push()` for navigation — never `Navigator.push()`.
5. Run codegen: `flutter pub run build_runner build --delete-conflicting-outputs`
6. Run `flutter analyze` and fix any issues before finishing.

Constraints:
- `ConsumerWidget` everywhere — no plain `StatefulWidget` unless a `TextEditingController` or animation controller is strictly required (use `ConsumerStatefulWidget` then)
- Colors from `AppColors` only, text styles from `AppTheme` only
- Skeleton widgets use `Container` with `AppColors.border` fill — no third-party shimmer packages
