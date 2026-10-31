# Correction — DynamoDB index lag and TTL are not correctness gates

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Algorithm: stable primary key plus conditional writes.
createOrTransitionWithCondition(authoritativeKey, expectedState)
// For exact primary-key reads needing it: GetItem with consistentRead(true).
// GSI reads remain eventually consistent.
// Evaluate expiresAt against the application’s documented clock/expiry policy.
```

A strong read does not lock the row for a later write; use conditions for races. TTL cleanup is asynchronous. Retaining or deleting an idempotency record changes retry behaviour and must be intentional.

**Still required:** Hot partition keys, scans and oversized items are separate access-pattern/capacity problems. Shard only with a plan for queries, uniqueness and aggregation. Do not promise exact timing for TTL deletion.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
