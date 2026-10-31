# Correction — Soft delete does not automatically change visibility or uniqueness

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Hypothetical contacts, where the product explicitly permits reuse after retirement.
SELECT * FROM contacts WHERE merchant_id = :merchant AND deleted_at IS NULL;
CREATE UNIQUE INDEX contacts_active_name
ON contacts(merchant_id, name) WHERE deleted_at IS NULL;
-- Do NOT apply this reuse rule blindly to payment/idempotency/audit identities.
```

Soft deletion is an application/database contract, not one magic annotation. Partial uniqueness is one option for reusable active names, not a universal solution.

**Still required:** Restoring a retired row can conflict with a new active one. Cleanup must be bounded and must not delete evidence needed for payment recovery. Cascades and native queries can bypass ORM filtering.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
