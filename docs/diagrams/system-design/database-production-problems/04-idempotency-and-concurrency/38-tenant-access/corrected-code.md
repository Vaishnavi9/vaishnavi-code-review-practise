# Correction — Finding an ID is not authorization

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Fragment; authenticatedMerchantId is resolved and authorized server-side.
return repository.findByIdAndMerchantId(paymentId, authenticatedMerchantId)
    .orElseThrow(() -> new IllegalArgumentException("Not found"));
// Apply equivalent ownership predicates to updates, deletes and related queries.
```

Transaction isolation concerns concurrent visibility, not tenant permissions. The current repository has a scoped finder, but existence of that method does not prove every endpoint uses it correctly.

**Still required:** Row-level security can provide additional enforcement with carefully managed roles/session context; it is disabled on the captured schema. Schema-per-tenant or database-per-tenant trades cost and operational complexity for stronger physical separation.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
