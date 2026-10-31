# Intentionally wrong example — Schema changes break mixed application versions

Teaching fragment only. Do not install this in the application.

```text
ALTER TABLE payments DROP COLUMN old_reference;
-- Old application instances are still serving traffic.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Old and new application instances coexist

2. Destructive migration removes a required column

3. Old SQL fails or dual-write fields diverge

4. Rolling deployment becomes an outage

A column is renamed/dropped or tightened to NOT NULL before old writers and historical rows are compatible.
