# Intentionally wrong example — Java mapping and SQL column disagree

Teaching fragment only. Do not install this in the application.

```java
@Column(name = "merchant_id")
Long merchantId; // wrong for the current varchar(100) merchant_id
// JPA and Mongo annotations are not interchangeable.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Java entity supplies a value under its mapping metadata

2. Hibernate selects JDBC binding and column name/type

3. JDBC transports values; PostgreSQL checks target type and constraints

4. Mismatch fails at mapping, binding, SQL execution or result extraction

Wrong schema/name/import, UUID versus numeric column, excessive string length, invalid JSON or a converter error causes persistence failure.
