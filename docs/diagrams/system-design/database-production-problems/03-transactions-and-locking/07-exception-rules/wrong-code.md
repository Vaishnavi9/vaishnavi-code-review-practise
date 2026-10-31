# Intentionally wrong example — Checked exceptions and swallowed failures

Teaching fragment only. Do not install this in the application.

```java
@Transactional
public void approve() throws ReviewRejected {
    repo.save(a);
    throw new ReviewRejected(); // hypothetical checked exception
}
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Method starts a transaction and writes A

2. A checked exception escapes

3. Default rule does not request rollback for that type

4. Commit can be attempted if transaction remains viable

A checked business exception escapes with default rules; or a catch block converts a failure to a success response.
