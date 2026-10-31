# Correction — Bulk updates leave managed objects stale

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Within an active transaction; flush pending changes before clearing.
em.flush();
em.createQuery("update Merchant m set m.enabled = false where m.id = :id")
  .setParameter("id", id).executeUpdate();
em.clear();
return em.find(Merchant.class, id).isEnabled();
```

clear detaches all managed entities and can discard unflushed changes. Spring Data @Modifying offers flushAutomatically/clearAutomatically; both default false. Configure deliberately, not as a substitute for understanding the context.

**Still required:** Bulk updates also need explicit tenant, version and state predicates. Clearing does not automatically repair external caches. Large deletes need bounded batches and retention checks.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
