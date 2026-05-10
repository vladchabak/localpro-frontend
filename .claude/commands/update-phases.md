---
description: Read the codebase and sync docs/phases.md checkboxes to actual code state
model: claude-haiku-4-5-20251001
---

Audit the codebase and update `docs/phases.md` to reflect what is actually implemented.

For each phase:
- Phase 0: check `pubspec.yaml`, `lib/core/`, theme, router, Dio client exist
- Phase 1: check auth screens — login, splash, register completion — exist under `lib/features/auth/presentation/`
- Phase 2: check map screen with flutter_map, markers, bottom sheet, filters under `lib/features/map/`
- Phase 3: check ServiceCard widget and ListingDetail screen under `lib/features/listing/`
- Phase 4: check WebSocket (stomp) + FCM setup under `lib/features/chat/`
- Phase 5: check provider dashboard + CreateListing under `lib/features/provider_dashboard/`
- Phase 6: check profile screen and app icon

Mark `[x]` only when the feature is genuinely present and wired up (not just a stub file).
Mark `[ ]` if absent or only a placeholder.

Write the updated checklist back to `docs/phases.md`. Report what changed.
