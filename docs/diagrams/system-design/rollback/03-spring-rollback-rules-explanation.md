# SPRING: choose the rollback rule

[Open the large diagram](03-spring-rollback-rules.svg)

Use rollbackFor with an exception type when a checked failure must undo database work. noRollbackFor prevents that exception from itself requesting rollback; it cannot make an aborted database transaction committable. The ClassName variants match name patterns and can match more than intended. Defaults can be changed globally. In ordinary proxy mode, self-invocation does not activate the annotation on the called method.

**Rule:** A rollback rule is a decision; the database can still make commit impossible.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```java
// Fragment on a Spring-managed service method.
// Import org.springframework.transaction.annotation.Transactional.
@Transactional(rollbackFor = Exception.class)
// method declaration and body go here
```

## Evidence to obtain

Compare a controlled checked exception under default rules and rollbackFor. Invoke through the proxy and inspect committed rows in a new transaction. A test-owned outer transaction can hide the real commit boundary.

## Explain without looking

Does catching an exception automatically roll back the transaction?

## Source notes

- [Rules](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/rolling-back.html)
- [Annotation](https://docs.spring.io/spring-framework/docs/6.2.x/javadoc-api/org/springframework/transaction/annotation/Transactional.html)
- [Proxy](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/annotations.html)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
