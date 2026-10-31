# Intentionally wrong example — save can merge and return a different managed object

Teaching fragment only. Do not install this in the application.

```java
Transaction saved = repository.save(detached);
// Later change detached and assume every change is tracked automatically.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Detached object has an existing identifier

2. save may use EntityManager.merge based on newness detection

3. Merge returns managed state; input is not made managed

4. Changes to the detached input can be lost or overwrite data on another merge

Code ignores the object returned by merge/save or constructs a partial entity with an existing ID.
