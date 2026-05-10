```
lib/
  main.dart                   — ProviderScope entry point
  app.dart                    — MaterialApp.router + GoRouter
  core/
    api/
      api_client.dart         — Dio instance + JWT interceptor
      api_endpoints.dart      — all URL constants
    theme/
      app_theme.dart
      app_colors.dart
    router/
      app_router.dart
    widgets/                  — shared widgets
    models/                   — PageResponse, etc.
  features/
    auth/data|domain|presentation
    map/data|domain|presentation
    catalog/data|domain|presentation
    listing/data|domain|presentation
    chat/data|domain|presentation
    provider_dashboard/data|domain|presentation
    profile/data|domain|presentation
```
