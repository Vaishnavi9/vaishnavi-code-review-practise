# Vaishnavi code-review practise

A separate blank learning project based on the recruiter's transaction-service skeleton. The interview repository is not modified. This is a scaffold created with assistance, not an independently demonstrated application.

## Starting point

- Java Development Kit (JDK) 25; Spring Boot 3.5.11; Gradle Wrapper 9.5.1.
- Assessment dependencies, plus the PostgreSQL runtime driver for the optional `db` profile: web, security, Java Persistence API (JPA), Flyway, JSON mapping, Kafka, H2 and the Spring Boot test starter.
- Application entry point, a Transaction entity and a small TransactionRepository interface. No controller, service, event listener or learner-written test yet.
- The learning table paymesh.transactions has been created manually in local PostgreSQL; its script is in sql/001_create_transactions.sql. Kafka remains a dependency only, with no integration implemented.

## Run and build

Open this folder in IntelliJ as a Gradle project. The project and Gradle settings select the existing `ms-25` Java installation. In a terminal, select Java 25 first if a different version is your default:

```sh
export JAVA_HOME=$(/usr/libexec/java_home -v 25)
./gradlew build
./gradlew bootRun
```

The Wrapper (`./gradlew`) uses the project's Gradle version; no Maven installation or Maven home is required. `build` compiles, packages and invokes test tasks. At the blank stage, `test NO-SOURCE` means there are no tests, not that tests passed. `bootRun` starts the application; stop it with Control-C when finished.

The local server is configured for `http://127.0.0.1:18095`. The security dependency supplies default authentication, so a plain request can return 401. No business endpoint exists yet. A running server or a 401 is only startup evidence, not a completed transaction feature. Do not share generated development passwords.

## Same database setup, separate process

The default H2 profile retains the six database settings from the recruiter skeleton. The optional `db` profile described below overrides them for PostgreSQL. No original settings file or credentials were copied wholesale.

- H2 is an embedded database: it runs inside this Java application.
- The `jdbc:h2:mem:...` URL makes it an in-memory database. Its lifecycle options match the skeleton. A separate Java process has a separate database, even if the logical database name is the same.
- Driver: `org.h2.Driver`.
- The built-in local H2 username and empty development password match the blank skeleton. These are not production credentials.
- `spring.jpa.hibernate.ddl-auto=none`: Hibernate does not create our tables.
- `spring.flyway.enabled=false`: Flyway does not apply migrations yet.

Adding an entity does not create a table with these settings. In the schema lesson, we will explicitly choose a schema script or a migration, explain the trade-off and write it ourselves. In-memory data is lost when the Java process exits. H2 is useful for learning; PostgreSQL-specific SQL, locking and isolation need their own real-database tests later.

Application properties, local IDE settings and build output are ignored by Git. No repository has been initialized and nothing is committed or pushed.

## Optional PayMesh PostgreSQL connection

Use the IntelliJ run configuration **Transaction service - PayMesh DB**, or:

```sh
export JAVA_HOME=$(/usr/libexec/java_home -v 25)
./gradlew bootRun --args='--spring.profiles.active=db'
```

Spring combines `application.properties` with `application-db.properties`; the active profile overrides matching keys. Without `db`, the original H2 settings remain active. The PostgreSQL driver is provided by Gradle and its version is managed by Spring Boot.

The default target is the existing local `paymesh` database on port 5432, with schema `paymesh`. A schema groups tables inside a database; `currentSchema` selects the search path and does not create anything. `PAYMESH_DB_URL` and `PAYMESH_DB_USER` may override the saved defaults. The required private file at `~/.config/paymesh-lab/database.properties` supplies `PAYMESH_DB_PASSWORD`. Do not copy its value into project files or screenshots.

The first exercise uses read-only connections, a maximum of three pooled connections, and no automatic table creation, migrations or seed scripts. `readOnlyMode=always` makes the PostgreSQL driver's read-only setting cover auto-commit too. This is a client-controlled default, not restricted database-role authorization. The learner chose the existing paymesh schema; paymesh.transactions is our learning table. Application pool defaults remain read-only. Decide on a scoped write transaction and role before the first persistence exercise; do not change unrelated PayMesh tables.

Timeout units matter: the URL's `connectTimeout=3` and `socketTimeout=5` are seconds; Hikari's `connection-timeout=3000` and `validation-timeout=2000` are milliseconds. Pool timeout means waiting for a connection, not a SQL execution deadline. These small limits are for a local introductory exercise, not production sizing.

`spring.jpa.open-in-view=false` avoids keeping a JPA persistence context open for the whole web request. It is not a thread-safety setting. Keep database work within deliberate service/transaction boundaries when we implement them.

Our first learner-written query will inspect the connection identity, not payment records:

```sql
SELECT current_database(), current_schema(),
       current_setting('transaction_read_only');
```

The next step is to explain database versus schema, connection versus pool, and profile activation before implementing a repository.

## Our learning sequence — one exercise at a time

For every step: predict the result, write a small change yourself, run it, explain the result and review one failure case. These are planned exercises, not completed features.

1. **Java entry point:** package, class, method, variables, arguments and the order of execution. Start in `TransactionServiceApplication.java`.
2. **Transaction as a Java object:** fields, constructor, methods, encapsulation, an enum for status, and amount plus currency. Explain why floating-point values are unsuitable for exact amounts.
3. **First unit test:** normal input, invalid amount and missing currency. A unit test checks one small piece without starting the whole application.
4. **Spring objects:** constructor dependency injection, a service and singleton scope. Identify shared fields versus request-local variables.
5. **Request and response:** create a transaction and read it by identifier; request objects, validation, response codes and safe errors.
6. **Database mapping:** explicit table creation, primary keys, null/unique constraints, entity, repository and a database integration test.
7. **Atomic changes and duplicate requests:** rollback, merchant-scoped request identity and concurrent updates. Coordinate race tests rather than using sleeps.
8. **Review and extension:** streams and collection choices, pagination, logging, authorization; then a small outbox and Kafka exercise only after persistence is understood.

Possible later transaction-service stories include listing/filtering transactions, allowed status transitions, duplicate-safe creation, balance or refund reservation, and audit history. Each needs its own business rule and failure evidence. We will not generate all implementations in advance.

## First tiny task

Before changing anything, locate `main` and the call to `SpringApplication.run`. Explain which statement Java will execute first if you add a print statement immediately before that call. We will discuss the answer, then you will write and run the change.

## Official references

- [Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
- [Spring Boot application annotation](https://docs.spring.io/spring-boot/reference/using/using-the-springbootapplication-annotation.html)

Versions intentionally match the assessment rather than the newest releases shown in these general reference pages.

## Basic package structure

Under `src/main/java/com/vaishnavi/transaction`:

```text
TransactionServiceApplication.java
controller/     HTTP requests and responses
service/        Business rules and use cases
model/          Transaction data objects
repository/     Database access
```

Each package contains a package-info.java explanation. The model now contains Transaction and the repository package contains TransactionRepository. Controller and service remain unimplemented. Matching test folders are under src/test/java/com/vaishnavi/transaction; no business tests exist yet.

The first flow will be controller → service → repository, using model objects. We will add request/response types, error handling and other packages only when the exercise needs them.


## Active story: record a transaction exactly once per merchant request key

This is an assisted learning implementation, not a production payment system or an independently demonstrated solution. Recording CREATED does not authorize, capture, settle or move funds. Finish this slice before adding refunds or messaging.

Customer need: a merchant must safely retry after losing our response without creating a second transaction. For the first exercise, EUR 19.99 is represented by amountMinor=1999 and currency=EUR. Assume the merchant identity has been authenticated; authentication implementation is still pending.

An invariant is a rule that must always remain true: at most one stored transaction per (merchant_id, request_key). The key identifies one intended operation, not every payment by the merchant. A retry repeats it; a genuinely new operation gets a new key.

### Acceptance scenarios and evidence

| Scenario | Required behavior | Current evidence / remaining work |
|---|---|---|
| Valid creation | Save a UUID, merchant/key, positive amount, currency, CREATED and time | Table and entity exist; end-to-end Java save not verified |
| Zero/negative amount, missing/blank identifiers, unsupported currency | Reject before persistence with a safe explanation | Database checks exist; only zero amount and missing currency were directly checked earlier. Java validation and supported-currency rule are missing |
| Same merchant/key and identical amount/currency | Return the original ID, amount and currency; no new row | Unique constraint checked; service replay behavior missing |
| Same merchant/key but changed amount or currency | Conflict; preserve original row | Service comparison and response missing |
| Same key for another merchant | Independent transaction is allowed | SQL check succeeded |
| Concurrent identical requests | One durable row and same original ID returned to both callers | Uniqueness exists; coordinated service/concurrency test missing |
| Merchant A requests merchant B's ID | Reveal no B data | Scoped repository lookup exists; trusted merchant identity and API handling still missing |
| Database error or rollback | No success response for uncommitted work | Service transaction/response tests missing |
| Response lost after commit | Retry resolves to the original stored transaction | Failure-injection exercise pending |

Do not treat an exists-then-insert check as protection against races. A database uniqueness violation can leave the transaction unusable: let the losing transaction roll back before looking up the winner in a fresh transaction. Catch only the expected named uniqueness conflict, not every persistence failure. The actual implementation is a later small exercise. Do not hold a database transaction open during a provider call.

### Review the current entity

- UUID primary key and integer minor units are appropriate for this exercise. Amount must always be interpreted with currency. Add explicit overflow and rounding handling when arithmetic/conversion is introduced.
- The protected no-argument constructor is for JPA; the public constructor describes a new transaction. Getters expose values without general-purpose setters. This is encapsulation, not proof of immutability or thread safety.
- Constructor validation is missing. NOT NULL and CHECK constraints protect stored data; annotations do not validate every new Java object. Add small tests before choosing where invariant checks belong.
- Only CREATED exists. A String is adequate for this first state; introduce an enum stored as a string when a real transition is needed. Do not add speculative statuses.
- Instant.now() uses the application clock. It is not commit order. Later inject a Clock into a creation service/factory if reproducible timestamp tests are needed; avoid injecting application services into JPA entities.
- UUID is assigned before save and there is no version field. Spring Data's default detection therefore selects merge rather than persist; this can cause a lookup before insert. Use the entity returned by save. Measure the SQL before deciding whether generated identifiers, Persistable or an explicit persist operation is justified.
- The previous merchant_Id spelling generally folds to lower case in unquoted PostgreSQL identifiers; it was normalized for clarity, not reported as a demonstrated failure. The unused SnakeYAML Event import was removed.
- Avoid logging whole entities or requests. Add safe correlation IDs, timings and error categories when the service is implemented.

### Repository responsibilities and boundaries

TransactionRepository exposes only save and two merchant-scoped lookups. Repository is a generic Spring Data interface: Transaction is the stored type and UUID is its identifier type. Optional represents either one result or no result. Spring creates a proxy (an object implementing the interface) and derives queries from Java property names.

The narrow interface avoids offering delete-all/unbounded-list operations accidentally. JpaRepository would be a simpler standard choice when its broader CRUD and pagination surface is actually needed. Neither interface is an authorization boundary: caller-supplied merchant IDs are not proof of merchant identity.

The read methods have read-only transaction hints; save has a write transaction boundary. A future service will own the whole use-case boundary. Configuration defaults alone do not prove write authorization. Do not share a JPA entity or a raw EntityManager between threads; use operation-local entities and Spring's managed persistence context. Do not put request fields or a mutable HashMap in a singleton service. Java synchronized protects one process only and cannot replace database uniqueness across instances.

### Review loop for each small change

1. State customer need and the invariant.
2. Predict a normal result and one failure/interleaving.
3. Implement one responsibility; keep HTTP mapping in the controller, use-case decisions in the service, and persistence in the repository.
4. Produce evidence with a focused test; explain what it cannot prove.
5. Review correction, alternative and cost. Refactor only after behavior is covered.

A method should have one coherent responsibility, not necessarily one statement. Extract a method when its name explains a business step (validateRequest, compareRetry, mapReceipt). Share code only when it represents the same rule, not merely similar-looking lines. A constructor-injected repository is dependency injection; the repository pattern separates storage access from decisions. Add more patterns only for a concrete problem.

Performance follows measurement: count queries, inspect query plans on representative data, observe request latency, connection-pool wait, lock waits and expected-conflict rates. The unique constraint already creates an index: do not add an identical index. Bound future list queries with pagination and avoid loading all rows to filter in Java. More threads do not increase database capacity; parallel streams over JPA entities/one persistence context are not a safe speed-up. Run EXPLAIN ANALYZE for writes only on isolated test data because it executes the statement.

### Learning order for this story

1. Explain the entity: object, constructor, access control, field types and annotations.
2. Explain the repository: interface, generics, Optional and generated query.
3. Write validation tests and one validation rule.
4. Implement service with constructor injection and a deliberate transaction boundary.
5. Verify save/read against PostgreSQL, then implement duplicate/replay handling.
6. Reproduce a concurrent retry using two workers and a latch/barrier, bounded waits, propagated worker errors and separate transactions; do not rely on sleep.
7. Add controller, request/response objects, trusted merchant identity and safe errors.
8. Review SQL/latency before any optimization. Later: stable pagination, versioned updates, refund reservation, outbox/recovery, each as a separate story.

We can aim to complete and explain this slice today; completing all Java, Spring and concurrency concepts is not a realistic completion criterion. Current understanding remains to be independently explained and demonstrated.

### Official reference notes

- Spring Data save/new detection: https://docs.spring.io/spring-data/jpa/reference/jpa/entity-persistence.html
- Spring Data query derivation: https://docs.spring.io/spring-data/jpa/reference/jpa/query-methods.html
- PostgreSQL constraints and unique indexes: https://www.postgresql.org/docs/current/ddl-constraints.html

These reference pages were consulted on 31 October 2026; the Spring current pages show a newer major than this project's 3.5 line. No dependency upgrades were made. Compile checks establish compatibility of the interface, not execution of its database queries or correctness of the future service.


## System design diagrams

[System design diagrams](docs/diagrams/system-design/README.md) — business responsibilities and a separate proposed AWS mapping.
