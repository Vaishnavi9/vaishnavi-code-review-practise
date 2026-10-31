# Correction — N+1: a separate query for each row

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Jakarta Persistence EntityManager em, active read transaction.
// A to-one fetch does not multiply each root by a collection.
List<Payment> rows = em.createQuery(
    "select p from Payment p join fetch p.merchant order by p.id", Payment.class)
    .setMaxResults(3).getResultList();
for (Payment p : rows) render(p.getMerchant().getName());
```

The loop accesses an unloaded relationship. The changed query loads that specific relationship with the roots. The four-query count assumes three distinct uncached merchants, no second-level/query cache and a cold persistence context.

**Still required:** A DTO projection avoids entity materialisation; batch fetching reduces round trips but is not necessarily one query. Do not globally make every association eager. Other relationships and serializers can still introduce N+1. Current Transaction has no associations.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
