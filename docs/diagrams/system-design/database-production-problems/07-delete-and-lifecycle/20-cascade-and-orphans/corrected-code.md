# Correction — Cascade delete, orphan removal and shared children

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Hypothetical mapping; no REMOVE cascade for shared methods.
@ManyToMany
Set<PaymentMethod> sharedMethods;
// Remove the association row, not the shared PaymentMethod entity.
// For exclusively owned children, consider orphanRemoval with both sides maintained.
```

ORM cascade propagates entity operations; database ON DELETE CASCADE is a separate FK rule. orphanRemoval applies to supported owned associations when removed from the relationship. Maintain the owning side and in-memory inverse side consistently.

**Still required:** Financial history usually needs explicit retention policy, not blanket cascading. Soft delete adds filtering and uniqueness concerns. JPA bulk deletion bypasses individual entity callbacks and ORM cascades; database constraints still apply.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
