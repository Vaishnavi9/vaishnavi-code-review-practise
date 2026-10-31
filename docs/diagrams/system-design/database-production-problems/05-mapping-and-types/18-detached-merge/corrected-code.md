# Correction — save can merge and return a different managed object

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Conceptual update pattern for a mutable hypothetical entity.
@Transactional
public void changeName(UUID id, String name) {
    Merchant managed = em.find(Merchant.class, id);
    if (managed == null) throw new IllegalArgumentException("Not found");
    managed.setName(name); // tracked within this persistence context
}
```

Spring Data newness detection considers version/ID and optional Persistable rules. An assigned UUID alone does not guarantee persist is selected. Use the returned save result when applicable. A load-and-update avoids treating a partial payload as a complete entity.

**Still required:** Current Transaction has constructor-assigned UUID, no @Version, and no setters. The example uses a hypothetical mutable Merchant; do not paste it into the current model. Merge can still issue an INSERT for a new assigned-ID object.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
