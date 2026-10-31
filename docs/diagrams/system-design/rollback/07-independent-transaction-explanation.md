# REQUIRES_NEW: an independent transaction

[Open the large diagram](07-independent-transaction.svg)

REQUIRES_NEW can deliberately preserve an independent record, but its meaning must be valid if the outer operation fails. It consumes additional connection capacity and can contend with locks retained by the suspended transaction. Use it deliberately, not as a generic fix for failed payment writes.

**Rule:** Do not split two writes that must be atomic across independent transactions.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```java
// Fragment on a method called through another Spring proxy.
// Imports: Transactional and Propagation from Spring transaction.annotation.
@Transactional(propagation = Propagation.REQUIRES_NEW)
// method declaration and body go here
```

## Evidence to obtain

Make T2 commit, then force T1 to roll back. A fresh transaction should find only T2's work. Also test connection-pool pressure before considering this at scale.

## Explain without looking

Can rolling back T1 undo the commit of T2?

## Source notes

- [Propagation](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/tx-propagation.html)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
