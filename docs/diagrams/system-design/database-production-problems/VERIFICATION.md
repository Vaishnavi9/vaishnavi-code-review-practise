# Verification and publication limits

Verified on 31 October 2026. No claim of absolute or universal correctness is made: every correction has explicit assumptions and remaining failure cases.

## Executed checks

- **17 synthetic PostgreSQL checks passed** in a separate local PostgreSQL instance. Coordinated two-connection tests deliberately reproduced lost updates and write skew, then checked optimistic version predicates and parent locking. Duplicate insertion and refund-budget races were also exercised.
- Commit, full rollback, savepoint recovery, failed-transaction state, deferred constraints, SQLSTATE classification, decimal scale, NULL/default rules and time-zone handling were exercised.
- The restored `transactions` table rejected a duplicate merchant/request key and a status other than CREATED.
- **4 standalone Java/Hibernate check groups passed** using the project's resolved Hibernate 6.6.42.Final and H2 2.3.232: a cold-context N+1 fixture produced 4 SELECTs versus 1 with a to-one fetch join and identical results; flush retained managed objects and could still be rolled back; merge returned a managed copy; BigDecimal conversion rejected excess precision and overflow.
- H2 was used only for ORM mechanism checks, not as proof of PostgreSQL locking or SQL behaviour. PostgreSQL checks used PostgreSQL itself.
- The project compiled after the two DynamoDB dependencies were added; the existing BOM resolves dynamodb-enhanced 2.57.7. Compilation does not establish authentication, connectivity or application test coverage.

[PostgreSQL source](verification/check_postgresql.py) · [PostgreSQL results](verification/postgresql-results.json) · [Hibernate source](verification/HibernateQueryCheck.java) · [Hibernate results](verification/hibernate-results.txt)

## What has not been executed

The 41 explanatory chapters contain focused fragments and algorithms. They are not 41 complete runnable applications or verified production integrations. No MongoDB/DynamoDB calls, provider charges, event-broker recovery, load tests, production migrations or live backup restores were run. The current TransactionPersistenceTest remains empty. Most chapter-specific verification instructions are exercises still to perform.

The current model has no mapped relationships, so the N+1 fixture is explicitly hypothetical. The small service only maps transactions; the other existing schema tables do not prove corresponding Java services are implemented.

## Version alignment

Resolved project libraries: Spring Data JPA 3.5.9, Spring transaction library 6.2.16, Hibernate 6.6.42.Final, PostgreSQL JDBC 42.7.10, H2 2.3.232 and AWS SDK v2 2.57.7; Java toolchain 25. Official reference links use the matching major/minor line where available, but online patch documentation can be newer. No new-version-only feature is required by these examples.

## Safe reproduction

The PostgreSQL harness connects ONLY to the isolated socket directory, port and role named in its source. It does not use project application properties. Start an empty local scratch instance, restore the schema snapshot there, install/use psycopg 3 in an external environment, then run the script. It creates and removes an atlas_check schema and inserts/deletes synthetic rows in the restored transactions table. Do not point it at an existing data-bearing database.

The standalone Java source requires the project's runtime classpath plus javac/java 25. Compile it outside src/main and src/test, then run its main method. It creates an in-memory H2 fixture and closes the SessionFactory, using no application credentials. The built-in Hibernate pool warning is expected for this isolated fixture and is not a production recommendation.

## Review findings addressed

- Parent-row locking example explicitly uses Read Committed; a stale Repeatable Read snapshot is not silently assumed safe.
- Collection pagination is separated from the to-one N+1 fix.
- Duplicate-key recovery occurs after ending a failed transaction; no same-transaction catch-and-continue fix is proposed.
- Database rollback, flush, commit and external compensation remain distinct.
- Idempotency includes tenant scope, immutable intent and retention assumptions.
- Schema CHECK/NOT NULL distinctions and current CREATED-only status limitation are explicit.

Examples should be independently explained, adapted and tested before being used in a real system. Source-reviewed, locally exercised and independently demonstrated are different evidence levels.

## Diagram and file checks

All 110 newly generated SVG files parsed successfully and their text fit within their SVG viewports in a local browser. Representative foreign-key and N+1 diagrams were visually inspected. Local Markdown links are checked after installation in the project.
