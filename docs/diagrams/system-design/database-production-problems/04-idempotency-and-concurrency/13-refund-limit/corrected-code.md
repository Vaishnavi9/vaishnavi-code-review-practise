# Correction — Concurrent refunds exceed the captured amount

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Hypothetical fixture: captured>=0 and 0<=reserved<=captured.
UPDATE refund_budget SET reserved = reserved + :amount
WHERE payment_id = :id AND :amount > 0
  AND reserved <= captured - :amount
RETURNING reserved;
-- Require one result. Insert a uniquely keyed refund operation in the same TX.
```

The predicate and increment are one database operation. Pair it with a unique operation key in the same transaction: guarded increments are not themselves idempotent if the same request is retried.

**Still required:** A provider refund is a separate external effect; failed/unknown submission needs its own state machine and reconciliation. Currency and capture identity must match. Signed bigint overflow and input bounds still require validation.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
