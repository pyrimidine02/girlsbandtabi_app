## ADR-20260302: Auth Retry Error Propagation for Refreshed Requests

### Status
- Accepted

### Context
- In the auth interceptor, a 401/403 response triggers token refresh and then
  retries the original request.
- When refresh succeeded but the retried request failed (for example 500), the
  interceptor catch block logged `Token refresh failed` and propagated the
  original 401 error, masking the real backend failure.
- This made production debugging misleading and showed incorrect failure causes
  in UI/snackbar flows.

### Decision
- Separate retried-request error handling from refresh handling:
  - If refresh succeeds and retried request fails, propagate the retried
    `DioException` directly (`handler.next(retryError)`).
  - Keep refresh-flow failure logging separate (`Token refresh flow failed`).
- Keep `_authRetried` guard to prevent infinite retry loops.

### Consequences
- Users and logs now see the actual post-refresh API failure (e.g. 500), not a
  stale 401 from the original request.
- Backend incidents on retried requests are diagnosable without auth noise.
- No behavioral change for valid refresh success path or invalid-session path.

### References
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/network/api_client.dart`
