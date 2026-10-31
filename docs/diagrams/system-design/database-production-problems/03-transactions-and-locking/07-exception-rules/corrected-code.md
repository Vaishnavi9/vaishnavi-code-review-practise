# Correction — Checked exceptions and swallowed failures

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// ReviewRejected extends Exception; call through the proxy.
@Transactional(rollbackFor = ReviewRejected.class)
public void approve() throws ReviewRejected {
    repo.save(a);
    throw new ReviewRejected();
}
```

Default Spring rules request rollback for RuntimeException and Error. Use specific rollbackFor classes for checked failures. Global configuration can change defaults; inspect it before diagnosing.

**Still required:** noRollbackFor does not revive a transaction already aborted by PostgreSQL. Catching a persistence failure and continuing is not a repair. Programmatic rollback-only is another option when an explicit rejected result is intended.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
