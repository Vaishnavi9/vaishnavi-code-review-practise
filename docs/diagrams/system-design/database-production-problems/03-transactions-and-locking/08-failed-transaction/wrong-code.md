# Intentionally wrong example — Catching a constraint error does not repair a transaction

Teaching fragment only. Do not install this in the application.

```text
@Transactional
public void saveOrFind() {
    try { repo.saveAndFlush(newRow); }
    catch (DataIntegrityViolationException e) { repo.findById(id); }
}
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Transaction T1 tries a write

2. Immediate constraint fails; T1 is aborted

3. Java catch block runs, but T1 remains failed

4. Further SQL or eventual commit fails

Code catches a duplicate-key exception then performs another query in the same aborted transaction; or inner REQUIRED marks rollback-only.
