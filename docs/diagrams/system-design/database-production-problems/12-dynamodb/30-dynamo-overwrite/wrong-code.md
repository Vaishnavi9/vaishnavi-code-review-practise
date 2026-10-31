# Intentionally wrong example — DynamoDB PutItem replaces an existing item

Teaching fragment only. Do not install this in the application.

```java
client.putItem(r -> r.tableName(table).item(item));
// Existing item with this primary key can be replaced.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Stored item already owns primary key K

2. New request issues unconditional PutItem for K

3. Existing item is replaced, including omitted attributes

4. Previous data or idempotency evidence disappears

An unconditional PutItem is used as create-only or a partial update.
