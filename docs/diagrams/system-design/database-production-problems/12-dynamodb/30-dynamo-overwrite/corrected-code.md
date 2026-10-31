# Correction — DynamoDB PutItem replaces an existing item

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Imports include java.util.Map; AWS SDK v2 DynamoDbClient. Table partition key: pk.
client.putItem(r -> r.tableName(table).item(item)
    .conditionExpression("attribute_not_exists(#pk)")
    .expressionAttributeNames(Map.of("#pk", "pk")));
// ConditionalCheckFailedException means resolve conflict, not blindly retry overwrite.
```

The condition and write are evaluated atomically for the item. With a composite key, it protects that exact key pair, not every item sharing the partition key. Use UpdateItem for deliberate partial changes, with expected-state/version conditions.

**Still required:** Conditions do not enforce global uniqueness across unrelated keys. Enhanced Client bean annotations map attributes; they do not automatically impose the business uniqueness contract. SDK dependencies are installed, but this project is not connected to DynamoDB.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
