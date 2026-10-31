# Correction — Nullable columns and unstable enum storage

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Imports: jakarta.persistence.Enumerated, jakarta.persistence.EnumType.
Long optionalFee; // only when NULL is a valid domain state
@Enumerated(EnumType.STRING)
PaymentStatus status;
// Database migration and allowed values must match the deployed enum names.
```

A wrapper represents null; it does not validate business rules. STRING avoids ordinal reordering, but renaming constants still requires a data/compatibility migration. Never silently change ordinal mapping over existing rows.

**Still required:** Stable external codes plus AttributeConverter can decouple names. Unknown future values need a defined policy. The current status field is String and the table only allows CREATED; neither bad mapping is present here.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
