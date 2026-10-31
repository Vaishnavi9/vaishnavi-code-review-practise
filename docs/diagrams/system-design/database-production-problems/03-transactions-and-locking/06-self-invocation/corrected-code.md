# Correction — Transactional method called through this

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Import org.springframework.transaction.annotation.Transactional.
// Method must be invoked through the Spring-managed service proxy.
@Transactional
public void createBoth() {
    repo.save(a);
    repo.save(b);
}
```

Move the transaction boundary to the actual external service entry point, or call a separate injected transactional bean. This describes proxy mode, not AspectJ weaving.

**Still required:** An existing outer transaction can change the outcome. Self-invocation does not erase an already active transaction. External network calls are not undone, and readOnly is not an authorization control.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
