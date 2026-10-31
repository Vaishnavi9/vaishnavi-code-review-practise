# FLUSH POLICIES: when synchronization happens

[Open the large diagram](10-flush-policies.svg)

JPA exposes AUTO and COMMIT; Hibernate also exposes ALWAYS and MANUAL. An explicit flush call and MANUAL flush mode are different things: you may call flush while using AUTO. Do not change the policy merely to avoid a constraint error. Keep the default until a measured need justifies a different policy.

**Rule:** A flush policy controls synchronization, not the business commit boundary.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```java
// Illustrative only; not a recommendation to change this project.
// Imports: jakarta.persistence.FlushModeType and EntityManager.
entityManager.setFlushMode(FlushModeType.AUTO);
```

## Evidence to obtain

In separate controlled tests, modify an entity, issue a relevant query, and inspect SQL plus returned data under each policy. Roll back fixtures afterward.

## Explain without looking

Is calling flush() once the same as choosing MANUAL flush mode?

## Source notes

- [Modes](https://docs.hibernate.org/orm/6.6/javadocs/org/hibernate/FlushMode.html)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
