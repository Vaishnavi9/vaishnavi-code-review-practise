# Master prompt: production database problems, diagnosis and corrected code

Build a comprehensive, version-aware failure atlas for a generic Java/Spring payment learning project. The goal is to recognise production symptoms, trace them through the application and database, identify a supported root cause and defend the smallest correction. Do not reduce this to N+1 or two examples. Do not claim every possible production incident can be enumerated.

Inspect `/Users/vaishnavidhanwade/Desktop/vaishnavi-code-review-practise`, its Gradle versions, entity/repository/service, SQL and existing docs first. Preserve all learner code, settings, credentials and existing diagrams. Use a generic system name. No commits, pushes, live database changes or cloud deployments are implied by this documentation task.

## Beginner-first teaching contract

For every problem, begin with a two-sentence everyday analogy and map each part of the analogy to the real application. Define unfamiliar terms before using them. Start from one visible symptom, such as a slow page, two conflicting reservations or a missing record. Explain the exact code pattern that creates it, not merely the name of the problem.

Provide two separate large diagrams: HOW THE BUG HAPPENS and HOW THE CORRECTION WORKS. Use numbered steps, plain labels, black text on white and explicit before/after state. Show every additional query for N+1, separate threads for races, transaction boundaries for rollbacks, and ownership checks for tenant access. If a comparison has no execution order, label it as a comparison rather than drawing misleading sequential arrows.

Walk the learner through the wrong code line by line; connect each relevant line to its diagram step. Then show the smallest corrected code and explain what each changed line does. Explain how the defect becomes visible in production and why a small local example might hide it. State what the correction does not fix. Include immediate containment separately from the durable correction, plus an evidence-based check that distinguishes them. Do not claim an analogy or animation proves correctness.

Deliver a usable indexed atlas, then stop teaching until the learner chooses one problem. Report completed work after each major task. Keep proposed relationship models and new infrastructure clearly labelled; do not imply that they already exist in the practice application.

## Folder and document contract

Create `docs/diagrams/system-design/database-production-problems/` with numbered folders:

01-query-shape-and-fetching; 02-indexes-and-plans; 03-transactions-and-locking; 04-idempotency-and-concurrency; 05-mapping-and-types; 06-constraints-and-schema; 07-delete-and-lifecycle; 08-pools-and-capacity; 09-consistency-and-caches; 10-migrations-and-storage; 11-mongodb; 12-dynamodb; 13-recovery-and-observability.

Each issue gets its own directory with README.md, diagram.svg, diagram.md, wrong-code.md, corrected-code.md, and verification.md. Small closely coupled issues can share a directory if clearly indexed. Keep a root coverage matrix listing every requested issue, prerequisites, whether it actually applies to the current model, status and links. Do not imply that hypothetical defects currently exist in the application.

Every issue must contain:

- The requirement and invariant; a concrete symptom visible to an operator or customer.
- A minimal synthetic fixture and deterministic reproducer, with versions, imports and setup. Mark fragments and pseudocode clearly.
- WRONG code, the exact flaw, and a numbered sequence showing the thread, connection, transaction, SQL and state involved.
- A large, original black-and-white diagram. For N+1 show each extra query, not just a single arrow labelled slow. For concurrency show both interleavings. For mapping show the responsible converter/driver boundary.
- A corrected fragment that changes only what is necessary; remaining limitations and failure modes.
- An alternative correction, costs, and when requirements would change the choice.
- Evidence: query counts, representative plans, rows examined/returned, measured latency percentiles, lock waits, pool usage, actual exceptions, committed-state assertions or duplicate effects. Use hypothetical numbers only when explicitly labelled.
- Expected result versus observed test output. List unsupported or unexecuted cases honestly.
- A closed-book review question, independent variation and production observability signal.
- Official sources matched to actual versions. Do not copy tutorial artwork or course transcripts.

## Required issue inventory

### Query shape and fetching

N+1 from lazy navigation; N+1 from eager loading; serialization-triggered queries; Open Session in View hiding data-access work in HTTP rendering; LazyInitializationException; detached proxies; accidental full-table reads; cartesian products from multiple joins; fetch-joining multiple collections; collection fetch plus pagination; incorrect total counts; duplicate root entities; offset pagination drift and cost; keyset pagination with nonunique ordering; missing tenant predicates; unbounded result materialisation; stream/cursor resource leaks; correlated subqueries and repeated per-row calls; projection versus entity loading; overfetching and underfetching.

Explain fetch join, entity graphs, batch fetching, explicit secondary queries and DTO projections as choices, not universal fixes. In the current project there are no mapped relationships: create an explicitly hypothetical relationship fixture rather than claiming it already suffers N+1.

### Indexes, plans and SQL

Missing index; composite-column order mismatch; low selectivity; non-sargable predicates; functions/casts on indexed columns; implicit type conversion; leading-wildcard search; incorrect join conditions; row multiplication; stale planner statistics; skewed values; parameter-sensitive plans; sort/hash spills; expensive DISTINCT/GROUP BY; excessive count queries; redundant indexes and write amplification; index bloat; unused indexes; uniqueness assumptions without constraints; query timeout versus pool timeout; the risks of EXPLAIN ANALYZE executing a modifying statement. Show how to inspect evidence safely.

### Transactions, locking and concurrency

Too-wide and too-small transaction boundaries; network calls while holding database locks; unexpected autocommit; separate connections outside the intended transaction; self-invocation bypassing a proxy; checked-exception commit; swallowed failures; rollback-only and UnexpectedRollbackException; failed transaction reused; long-running/idle-in-transaction sessions; lost update; read-modify-write race; check-then-insert race; write skew; nonrepeatable reads; phantoms; deadlock; lock timeout; optimistic version conflict; serialization retry; mismatched isolation assumptions; SELECT FOR UPDATE limitations, including absent rows; missing update-count checks; lock ordering; unsafe retrying of non-idempotent work; pool starvation from REQUIRES_NEW.

### Idempotency and distributed effects

Duplicate request; simultaneous duplicates; same key with different payload; tenant-scope collision; key expiry and retention; original receipt replay; provider identity differing between retries; crash before commit, after commit and before response; outbox publication failure; publish succeeded but acknowledgement lost; duplicate or stale consumer event; inbox effect/ack boundary; version ordering; provider timeout/unknown outcome; webhook races; cancellation versus success; duplicate compensation; double refund reservation; reconciliation mismatch; deleting evidence needed for recovery.

### Object mapping and data types

Column/field naming mismatch; wrong schema/search_path; missing/misapplied imports; JPA annotations on Mongo models and vice versa; access mode mismatch; missing constructors; detached merge misuse; null into primitive; numeric overflow; precision/scale truncation or rounding; floating-point money; UUID text/binary representation mismatch; enum ordinal drift; invalid enum values; timezone/offset loss; timestamp precision; VARCHAR length violations; Unicode/collation differences; invalid JSON; arrays/LOB materialisation; custom converter exceptions; Java defaults overriding database defaults; generated fields not refreshed; mapper null-removal behaviour; equality/hashCode changing after persistence; mutable IDs; Lombok-generated entity methods triggering recursion or lazy queries where applicable.

### Constraints and schema

Primary-key violation; composite unique violation; foreign-key violation; NOT NULL; CHECK; exclusion constraints where applicable; immediate versus deferred checks; SQLSTATE and Spring exception translation; primary-key uniqueness versus business idempotency; constraints missing despite annotation metadata; ddl-auto differences and dangerous automatic schema changes; constraint added to dirty data; schema drift; schema validation not testing business correctness; migration ordering or checksum mismatch; database defaults, triggers and generated columns whose effects surprise ORM state.

### Deletion, ownership and lifecycle

Hard versus soft delete; ORM CascadeType.REMOVE versus database ON DELETE CASCADE; orphanRemoval versus a collection update; relationship owning side not updated; accidental cascade on shared many-to-many data; foreign-key RESTRICT/NO ACTION; bulk deletes bypassing entity callbacks and leaving cached state stale; tenant predicate missing in a delete; unbounded retention cleanup; large transactions and lock duration; deleting a parent required by audit/history; soft-deleted rows still visible or blocking uniqueness; deletion racing another update; audit callbacks performing unsafe extra work; retention and historical snapshots. Do not invent legal retention requirements.

### Connections, capacity and resources

Connection leaks; slow query monopolising a pool; too many instances multiplying pool connections; database max_connections reached; wrong pool sizing; acquisition timeout versus query timeout; thread exhaustion; queue backlog; unbounded executors; oversized batches; persistence-context memory growth; frequent flush defeating batching; identity generation affecting batching; abandoned transactions; long snapshots delaying cleanup; database CPU/IO/memory/storage exhaustion; transaction log growth; too much logging; health checks competing with real traffic; retry storms; serverless/concurrent client fan-out; provider quotas unaffected by adding application threads.

### Consistency, replicas and caches

Read-after-write sent to lagging replica; stale first-level or second-level cache; query cache assumptions; cache invalidation race; cache stampede; negative caching hiding newly created data; TTL used as a correctness guarantee; bulk SQL bypassing managed state; read-your-write requirements; replica promotion and lost acknowledged writes under weaker configurations; clock-based ordering mistakes; reconciliation of divergent views. Separate authoritative data from searchable/reporting projections.

### Migrations, storage and recovery

Blocking DDL; index build contention; changing column type with old application instances running; expand/contract migration; nullable-to-required migration and backfill; dual-write inconsistency; sequence misalignment; nontransactional sequence gaps; hot partitions; uneven sharding; bad partition key; tenant relocation; backups never restored; point-in-time recovery gaps; recovery point/time objectives; destructive cleanup; restore to an incompatible schema; schema version mismatch across rolling deployments.

### MongoDB-specific issues

_id type mismatch and implicit conversion; missing unique indexes; auto-index assumptions; duplicate-key conflicts; embedded document growth; unbounded arrays; large document limits; reference loading overhead; null versus missing; Decimal128 conversion; UUID representation; absent shard-key targeting; scatter/gather queries; hot shards; write concern/read concern mismatch; transactions on unsupported topology; transaction retry handling; stale reads; version conflicts; Spring and native-driver codec configuration differences. Verify limits and behaviour from current official documentation.

### DynamoDB-specific issues

PutItem unintentionally replacing an item; unconditional overwrites; omitted conditional version check; condition conflict mistaken for transient throttling; hot partition; skewed keys; scan instead of targeted query; inefficient filter expressions; missing pagination; eventual GSI visibility; unsupported strong reads on a GSI; item-size limits; number precision; missing/empty/null conversions; optimistic-lock extension prerequisites; batch partial failures; transaction cancellation reasons; TTL deletion delay; SDK timeout/retry uncertainty; wrong region, endpoint, profile or table; IAM denial; client leaks; DynamoDB Local differences. Explain per-item atomic operations versus multi-item transactions and separate SDK mapping from service behaviour.

### Diagnostics and tests that mislead

Tests that roll back automatically and never prove commit; H2 passing while PostgreSQL fails; single-thread tests for races; sleeps instead of coordination; generated tests that simply mirror code; logs counted as proof of durable state; success responses hiding duplicate external effects; missing database metrics; sensitive payloads or credentials in logs; high-cardinality metric labels; unrealistic load generators; closed-loop load hiding overload; failure to count continuing arrivals while recovering a backlog.

## Required outputs and teaching plan

First deliver an inventory and prioritise: correctness/security risks, common performance defects, then advanced cases. Define terms, but do not attempt all exercises in one sitting. Pick one issue, ask the learner to predict the outcome, show the bad code and timeline, and wait before revealing the correction. Recommend a small independent variation.

For testing, isolate fixtures and use actual PostgreSQL where dialect/locking behaviour matters. MongoDB and DynamoDB tests require explicitly available environments. Do not start services, install additional libraries, write production data or provision AWS just to claim coverage. Mark unavailable scenarios planned. Produce no mastery or production-readiness claim from a passing toy example.

Report the inventory size by category, the number fully documented, examples compiled, examples executed, and gaps. "All requested scenarios indexed" is different from "all scenarios implemented and tested." Keep that distinction visible.
