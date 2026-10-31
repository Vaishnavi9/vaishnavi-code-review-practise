# Intentionally wrong example — Cascade delete, orphan removal and shared children

Teaching fragment only. Do not install this in the application.

```java
@ManyToMany(cascade = CascadeType.ALL)
Set<PaymentMethod> sharedMethods;
// Deleting one merchant may cascade REMOVE to shared methods.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Two merchants refer to the same shared method

2. One merchant is removed with REMOVE cascade

3. ORM tries to remove the shared method too

4. FK failure or unintended shared-data deletion follows

CascadeType.REMOVE propagates through shared relationships; changing the inverse side alone leaves the owning foreign key unchanged.
