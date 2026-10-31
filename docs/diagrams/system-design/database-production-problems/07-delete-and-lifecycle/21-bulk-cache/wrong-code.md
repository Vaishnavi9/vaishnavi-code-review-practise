# Intentionally wrong example — Bulk updates leave managed objects stale

Teaching fragment only. Do not install this in the application.

```java
Merchant m = em.find(Merchant.class, id);
em.createQuery("update Merchant m set m.enabled = false where m.id = :id")
  .setParameter("id", id).executeUpdate();
return m.isEnabled(); // may still be true in memory
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Load enabled=true into persistence context

2. Bulk UPDATE sets database row to false

3. Existing managed object still says true

4. Later logic makes a stale decision

A JPQL/native bulk update changes rows while the persistence context still contains old entity values.
