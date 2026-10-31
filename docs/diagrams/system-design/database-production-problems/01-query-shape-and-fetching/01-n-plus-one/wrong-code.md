# Intentionally wrong example — N+1: a separate query for each row

Teaching fragment only. Do not install this in the application.

```java
// Fragment: hypothetical Payment -> Merchant lazy to-one relation.
List<Payment> rows = em.createQuery("select p from Payment p", Payment.class)
    .setMaxResults(3).getResultList();
for (Payment p : rows) render(p.getMerchant().getName());
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Query payments P1, P2, P3; distinct merchants M1, M2, M3

2. Access P1.merchant.name: SELECT merchant M1

3. Access P2.merchant.name: SELECT merchant M2

4. Access P3.merchant.name: SELECT merchant M3; four SELECTs total

A page is fast with one payment but slows with many distinct merchants; SQL count grows with returned rows.
