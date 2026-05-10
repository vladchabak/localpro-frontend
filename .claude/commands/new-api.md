---
description: Scaffold a Retrofit method + repository method + Riverpod provider for one endpoint
model: claude-haiku-4-5-20251001
---

Add a new API call for: $ARGUMENTS

Steps:
1. Identify the correct feature folder under `lib/features/` based on the endpoint.
2. In `data/` — add the Retrofit method to the existing `@RestApi` interface (or create one if absent). Use `@GET`/`@POST`/`@PUT`/`@DELETE`, `@Query`, `@Body`, `@Path` as needed. Return type must use `PageResponse<T>` for paginated results.
3. In `data/` — add the corresponding repository method that calls the Retrofit method.
4. In `domain/` — add a `@riverpod` provider that calls the repository method. Use `keepAlive: true` only for rarely-changing data (categories, user profile).
5. Run `/codegen` after adding any `@riverpod` or `@RestApi` annotation.

Follow exactly:
- Riverpod 2 `@riverpod` annotation style from `docs/code-rules.md`
- Paginated response shape from `docs/api.md`
- Auth header is injected automatically by the Dio interceptor — do not add it manually
