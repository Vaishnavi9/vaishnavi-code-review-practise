# Intentionally wrong example — Soft delete does not automatically change visibility or uniqueness

Teaching fragment only. Do not install this in the application.

```sql
UPDATE contacts SET deleted_at = now() WHERE id = :id;
SELECT * FROM contacts WHERE merchant_id = :merchant; -- still includes retired rows
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Record is marked deleted

2. An unfiltered read still returns it

3. Old uniqueness rules and new reuse expectations conflict

4. Leaked retired data or unintended identity reuse results

Queries forget deleted_at; a unique constraint blocks intended reuse or a partial index wrongly permits reuse of a permanent idempotency key.
