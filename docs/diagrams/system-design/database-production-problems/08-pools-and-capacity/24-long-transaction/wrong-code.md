# Intentionally wrong example — Network calls hold database transactions open

Teaching fragment only. Do not install this in the application.

```text
@Transactional
public void submit() {
    reserveFunds();
    provider.charge(); // potentially slow and cannot be rolled back by the DB
    markSuccessful();
}
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Begin transaction and acquire locks

2. Call remote provider while transaction stays open

3. Slow provider holds local resources for a long time

4. Timeout may roll back local data after provider already charged

A provider slows down while a service transaction holds row locks and a database connection.
