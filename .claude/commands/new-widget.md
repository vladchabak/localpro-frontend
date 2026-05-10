---
description: Create a shared widget in core/widgets/ following the design system
model: claude-haiku-4-5-20251001
---

Create a shared widget named: $ARGUMENTS

Place it in `lib/core/widgets/`.

Rules:
- Use `ConsumerWidget` if it needs Riverpod state, otherwise plain `StatelessWidget` with `const` constructor
- Colors only from `AppColors`, text styles only from `AppTheme`
- Card style: white background, `borderRadius: 12`, subtle `boxShadow`
- No hardcoded hex values, no inline TextStyle with hardcoded colors
- Export it from `lib/core/widgets/` if an index file exists there

Design reference: `docs/design.md`
