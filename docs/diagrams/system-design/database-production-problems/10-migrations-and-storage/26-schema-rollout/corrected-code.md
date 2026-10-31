# Correction — Schema changes break mixed application versions

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
-- Expand / migrate / contract algorithm, not one migration.
1. Add the new compatible representation.
2. Deploy compatible readers/writers; define authoritative field during transition.
3. Backfill in bounded, resumable batches; validate completeness.
4. Switch reads and verify no old writers remain.
5. Remove old representation in a later controlled migration.
```

Measure lock requirements and migration duration on representative data. PostgreSQL CREATE INDEX CONCURRENTLY is a separate tool with restrictions: it cannot run inside a normal transaction block and failed builds may leave invalid indexes.

**Still required:** Rollback of application code must remain compatible with the expanded schema. Dual writes need a defined consistency rule. Flyway presence alone does not mean the migration ran or the PostgreSQL database module/configuration is correct.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
