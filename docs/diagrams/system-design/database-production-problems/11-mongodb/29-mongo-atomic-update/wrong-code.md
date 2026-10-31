# Intentionally wrong example — MongoDB stale read–modify–write

Teaching fragment only. Do not install this in the application.

```javascript
const p = db.wallets.findOne({_id: id});
db.wallets.updateOne({_id: id}, {$set: {availableMinor: p.availableMinor - amount}});
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Two callers read available=100

2. Each computes a replacement value

3. Both write without an expected-state predicate

4. One change is lost or funds are over-reserved

A read followed by $set writes a balance computed from stale data.
