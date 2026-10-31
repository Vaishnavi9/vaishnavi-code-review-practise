# Intentionally wrong example — Passing tests can hide missing commit and missing coverage

Teaching fragment only. Do not install this in the application.

```text
@Transactional
@Test void saveWorks() {
    repository.save(entity);
    assertNotNull(entity.getId());
} // ID in memory does not prove database commit.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Test creates Java object and calls save

2. Assertion inspects only the object in memory

3. Test-owned transaction rolls back

4. No evidence establishes commit or concurrent correctness

H2 differs from PostgreSQL, transactional tests roll back, sleep-based concurrency tests do not force overlap, or an empty test suite runs no assertions.
