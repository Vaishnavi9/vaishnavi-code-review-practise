# Intentionally wrong example — Check then insert is not atomic

Teaching fragment only. Do not install this in the application.

```sql
if (repo.findByMerchantIdAndRequestKey(merchant, key).isEmpty()) {
    repo.save(new Transaction(merchant, key, amount, currency));
}
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Request A reads key K: absent

2. Request B reads key K: absent

3. Both try INSERT; Java checks did not serialize them

4. Unique constraint allows one; loser needs deliberate handling

Two requests both see an absent key and attempt insertion.
