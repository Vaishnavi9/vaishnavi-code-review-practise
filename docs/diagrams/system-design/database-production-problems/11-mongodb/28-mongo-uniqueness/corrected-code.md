# Correction — MongoDB unique identity needs an actual index

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```javascript
// mongosh fixture, not Java or an installed project integration.
db.payments.createIndex({merchantId: 1, requestKey: 1}, {unique: true});
// Validate required non-null fields, attempt insert, classify duplicate key,
// then read and compare immutable payload before replaying.
```

MongoDB single-document atomicity does not enforce uniqueness across different documents by itself. Sharded-collection unique-index restrictions and shard-key design must be considered separately.

**Still required:** Existing duplicates prevent index creation. Missing/null values and partial indexes alter uniqueness semantics. This project has no MongoDB connection or dependency; no Mongo examples were executed.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
