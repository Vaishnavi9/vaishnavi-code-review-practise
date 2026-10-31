# Intentionally wrong example — Transactional method called through this

Teaching fragment only. Do not install this in the application.

```java
public void createBoth() { this.writeBoth(); }
@Transactional
public void writeBoth() { repo.save(a); repo.save(b); }
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Caller enters unannotated service method

2. this.writeBoth bypasses proxy interception

3. No service transaction is established by that annotation

4. Separate repository commits can leave only the first write

A helper carries @Transactional but an unannotated method in the same object calls it; individual repository transactions can commit separately.
