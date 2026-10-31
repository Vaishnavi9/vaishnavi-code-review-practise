# Correction — Annotations do not guarantee installed constraints

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Actual current business identity is a pair, not global request_key.
ALTER TABLE paymesh.transactions
ADD CONSTRAINT transactions_merchant_request_unique
UNIQUE (merchant_id, request_key);
-- Illustration only: this constraint ALREADY EXISTS; do not run this twice.
```

The live snapshot confirms the current composite unique key, required columns and checks. SQLSTATE distinguishes 23505 unique, 23502 not-null, 23503 foreign-key and 23514 check errors. Do not treat all as the same business conflict.

**Still required:** CHECK expressions evaluating NULL do not substitute for NOT NULL. PostgreSQL foreign keys do not automatically create a child-column index. Deferrable constraints may fail at commit; validation of ORM mappings is not validation of every business invariant.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
