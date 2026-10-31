# FLUSH: send the pending database work

[Open the large diagram](09-flush-internals.svg)

The persistence context tracks managed objects; Hibernate's ActionQueue stores pending data-modification actions. Dirty checking and action ordering turn changes into SQL executed through JDBC. This is not a durable message broker or a global work queue. SQL order can differ from Java call order. Some operations, such as identity-generated inserts, can execute earlier. A rollback does not restore your Java objects to their old field values.

**Rule:** A flush affects this persistence context, not all application instances.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```java
// Fragment inside an active JPA transaction.
// entityManager is an injected jakarta.persistence.EntityManager.
entityManager.flush();
// Transaction is still active; this call is not COMMIT.
```

## Evidence to obtain

Observe SQL execution at flush, then deliberately roll back. A separate transaction must not find the rolled-back new row. SQL logs alone prove execution, not commit.

## Explain without looking

If instance A flushes, does it flush instance B's managed objects?

## Source notes

- [Queue](https://docs.hibernate.org/orm/6.6/javadocs/org/hibernate/engine/spi/ActionQueue.html)
- [Hibernate](https://docs.hibernate.org/orm/6.6/userguide/html_single/#flushing)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
