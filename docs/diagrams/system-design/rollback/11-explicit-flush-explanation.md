# EXPLICIT FLUSH: ask for synchronization now

[Open the large diagram](11-explicit-flush.svg)

JpaRepository.flush synchronizes pending changes; saveAndFlush saves then flushes; saveAllAndFlush saves the collection then flushes. Your narrow TransactionRepository does not expose these methods. You would need an intentional interface/API choice before calling them. An explicit flush can expose immediate constraints earlier. Flushing after every save can reduce batching opportunities. Without an outer transaction, a transactional repository method can also commit when it returns; the commit comes from that boundary, not from flush itself.

**Rule:** Flush is not limited to just the entity named in saveAndFlush.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```java
// Fragment, only for a repository extending JpaRepository.
// Not currently available on our TransactionRepository.
Transaction saved = repository.saveAndFlush(transaction);
// If an outer transaction exists, it still has to finish.
```

## Evidence to obtain

Under an explicit outer transaction, save-and-flush then roll back. Verify the new row is absent afterward. Compare SQL batches before and after adding frequent flushes.

## Explain without looking

Does the word Flush in a method name mean the record is committed?

## Source notes

- [Repository](https://docs.spring.io/spring-data/jpa/docs/3.5.x/api/org/springframework/data/jpa/repository/JpaRepository.html)
- [Hibernate](https://docs.hibernate.org/orm/6.6/userguide/html_single/#flushing)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
