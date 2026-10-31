# Correction — Same idempotency key, different intent

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Fragment: merchant comes from authenticated authorization context.
Transaction existing = repo.findByMerchantIdAndRequestKey(merchant, key)
    .orElseThrow();
if (existing.getAmountMinor() != amount || !existing.getCurrency().equals(currency)) {
    throw new IllegalArgumentException("Request key reused for different payment");
}
return existing;
```

For the current four-input constructor, amount and currency distinguish intent once merchant/key identify the row. A richer API must also include recipient, operation type and other semantic fields. Do not trust a client-supplied merchant claim alone.

**Still required:** Canonical payload hashing is useful for richer payloads but requires stable normalization and field definitions. A random request key does not authorize access. Retention/expiry must be part of the API contract.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
