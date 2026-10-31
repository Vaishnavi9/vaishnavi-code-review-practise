# EXPLICIT ROLLBACK-ONLY

[Open the large diagram](04-explicit-rollback-only.svg)

TransactionTemplate lets code request rollback via its status object. This is useful when returning a rejection is deliberate, but it ties the code to transaction control. Prefer clear exception-based rules when they express the business outcome better. With joined transactions, rollback-only affects the shared physical transaction; an outer caller may receive UnexpectedRollbackException when it attempts commit.

**Rule:** Do not report success merely because the callback returned normally.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```java
// Fragment; template is an injected TransactionTemplate.
// Import org.springframework.transaction.support.TransactionTemplate.
boolean accepted = template.execute(status -> {
    // perform participating database work
    status.setRollbackOnly();
    return false;
});
```

## Evidence to obtain

Write a record in a template callback, mark rollback-only, then check that a fresh transaction cannot find the record.

## Explain without looking

Is rollback-only a request to commit just the earlier writes?

## Source notes

- [Programmatic](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/programmatic.html)
- [Propagation](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/tx-propagation.html)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
