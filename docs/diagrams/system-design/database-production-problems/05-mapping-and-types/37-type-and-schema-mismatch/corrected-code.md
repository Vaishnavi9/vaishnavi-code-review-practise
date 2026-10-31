# Correction — Java mapping and SQL column disagree

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Current PostgreSQL/JPA model uses jakarta.persistence.Column.
@Column(name = "merchant_id", nullable = false, length = 100)
String merchantId;
// Align this with an actual varchar(100) column and validate before persistence.
```

JDBC transports SQL values; it does not independently infer JPA entities. Hibernate maps entities to SQL. Mongo’s mapper/driver uses BSON, while DynamoDB Enhanced Client maps to AttributeValue. These are distinct pipelines.

**Still required:** Length metadata is not input validation. Silent casts can hurt index use or obscure bugs. SQLSTATE 22001 is string truncation, 22003 numeric range, 22P02 invalid textual representation; actual exceptions depend on the failing layer.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
