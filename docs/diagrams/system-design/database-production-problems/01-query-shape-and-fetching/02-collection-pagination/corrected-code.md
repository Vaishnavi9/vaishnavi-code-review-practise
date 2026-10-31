# Correction — Collection fetch join and pagination

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Two-query algorithm, not a drop-in method.
ids = queryPaymentIdsWithTenantFilterOrderByCreatedAtThenId(limit20);
if (ids.isEmpty()) return emptyList();
rows = fetchPaymentsAndOperationsWhereIdIn(ids);
return restoreOrderOfIds(rows, ids);
```

Separate selecting the page from loading its graph. Retain tenant predicates. Use one suitable snapshot if the contract requires both reads to see an identical point in time.

**Still required:** Two reads allow intervening changes under Read Committed. A DTO query or separate bounded children query may be simpler. Count totals separately only when required. Joining two collections can multiply rows severely.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
