# Correction — MongoDB stale read–modify–write

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```javascript
// Validate amount is a positive safe value and operation identity is deduplicated.
const result = db.wallets.updateOne(
    {_id: id, availableMinor: {$gte: amount}},
    {$inc: {availableMinor: -amount}});
if (result.matchedCount !== 1) throw new Error("Reservation rejected");
```

The conditional update protects this single document. $inc alone does not deduplicate repeated requests. Multi-document operations need an explicit atomicity design, potentially a supported multi-document transaction.

**Still required:** JavaScript numeric examples require safe integer bounds; monetary BSON Long/Decimal128 needs compatible mapping. Different read/write concerns affect durability and visibility. No live Mongo tests have run.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
