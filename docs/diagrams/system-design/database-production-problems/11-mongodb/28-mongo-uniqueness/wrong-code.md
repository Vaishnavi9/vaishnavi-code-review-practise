# Intentionally wrong example — MongoDB unique identity needs an actual index

Teaching fragment only. Do not install this in the application.

```javascript
if (!db.payments.findOne({merchantId: m, requestKey: k})) {
    db.payments.insertOne({merchantId: m, requestKey: k, amountMinor: 100});
}
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Two clients read missing key

2. Both attempt document insertion

3. Without a unique index, both can exist

4. Application has two records for the same request

Two find-then-insert callers race; an annotation is assumed to have created a production index.
