# Correction — Time zones and database defaults

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Global event instant in Java; import java.time.Instant.
Instant occurredAt = Instant.now();
// PostgreSQL column: timestamp with time zone (timestamptz).
// A DB default applies when column is omitted or SQL DEFAULT is used, not NULL.
```

PostgreSQL timestamptz stores an instant, not the original zone ID. Store the zone separately if the business needs it. ORM-generated INSERT columns decide whether database defaults are used.

**Still required:** Clock skew means timestamps alone are not a causal ordering guarantee. PostgreSQL timestamp precision and Java nanoseconds may differ. Local appointments may require LocalDateTime plus a named zone instead.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
