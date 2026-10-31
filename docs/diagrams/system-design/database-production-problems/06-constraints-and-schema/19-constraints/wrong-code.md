# Intentionally wrong example — Annotations do not guarantee installed constraints

Teaching fragment only. Do not install this in the application.

```sql
@Column(unique = true, nullable = false)
String requestKey;
// Assume this enforces merchant-scoped uniqueness in every database.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Code declares mapping metadata

2. Environment does not generate or migrate that constraint

3. Another writer inserts invalid data

4. Application assumption is violated in stored rows

A schema migration is missing, dirty rows prevent adding a constraint, or code assumes @Column creates constraints in every environment.
