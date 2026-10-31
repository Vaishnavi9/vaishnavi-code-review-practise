# Correction — Connections are not returned to the pool

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Standalone non-Spring-transaction JDBC ownership example.
try (Connection c = dataSource.getConnection();
     PreparedStatement s = c.prepareStatement("select 1");
     ResultSet r = s.executeQuery()) {
    if (r.next()) consume(r.getInt(1));
}
// In Spring-managed transactions, prefer JdbcTemplate / transaction-aware access.
```

AutoCloseable allows try-with-resources. JdbcTemplate manages JDBC resources and participates in Spring transactions. Direct getConnection can bypass the transaction-bound connection depending on the DataSource wrapper; do not mix access styles casually.

**Still required:** A pool timeout is not proof of a leak: slow queries, blocked locks or too much concurrency also occupy connections. Increasing pool size can worsen database overload.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
