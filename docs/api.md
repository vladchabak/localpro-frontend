## Base URLs

- Android emulator: `http://10.0.2.2:8080`
- Chrome/web: `http://localhost:8080`
- Production: `https://localpro-api.railway.app`

Auth header: `Authorization: Bearer dev-token` (dev mode)

## Paginated Response

```json
{ "content": [...], "totalElements": 150, "totalPages": 8, "number": 0, "size": 20 }
```

## Error Response

```json
{ "code": "NOT_FOUND", "message": "...", "fieldErrors": [], "timestamp": "..." }
```

## Endpoints

```
GET  /api/categories
GET  /api/listings/nearby?lat=&lng=&radiusKm=&categoryId=&page=&size=
GET  /api/listings/{id}
POST /api/listings           (auth)
PUT  /api/listings/{id}      (auth, owner)
GET  /api/listings/my        (auth)
POST /api/auth/register
GET  /api/users/me           (auth)
PUT  /api/users/me           (auth)
GET  /api/users/{id}
POST /api/chats              (auth)
GET  /api/chats              (auth)
GET  /api/chats/{id}/messages (auth)
POST /api/listings/{id}/reviews (auth)
GET  /api/listings/{id}/reviews
```
