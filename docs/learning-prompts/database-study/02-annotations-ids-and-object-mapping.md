# Master prompt: complete application annotation and persistence mapping atlas

Create a version-aware reference and hands-on curriculum for the generic practice application at `/Users/vaishnavidhanwade/Desktop/vaishnavi-code-review-practise`. Cover PostgreSQL/JPA/Hibernate/JDBC, MongoDB/Spring Data, and DynamoDB/AWS SDK v2. Cover the surrounding Spring application too: the scope is not limited to @Id or database annotations.

Use generic payment examples. Do not mention a real payment company, copy course diagrams, infer a company's internal architecture, or claim that installing a library connects to a database. Preserve existing application behaviour. The learner writes application code; supply examples in documentation unless implementation is explicitly requested.

## Define completeness honestly

Inventory exact libraries and versions from the Gradle build and resolved dependency graph. Use official API package indexes to enumerate available annotations for those versions. Build a manifest of fully qualified annotation names, owning library, applicability, current usage, relevant attributes and coverage status. For every discovered annotation mark: explained, grouped with a related annotation, advanced/optional, deprecated, irrelevant with reason, or planned. Cross-check the manifest against the official indexes; report missing entries instead of claiming universal completeness.

Separate annotations already present in this project from additional options. Do not silently enable preview Java features, upgrade framework versions, add multiple database starters or change runtime auto-configuration. Verify compatibility before dependency changes. Use the existing AWS SDK BOM for approved DynamoDB and Enhanced Client dependencies. Never copy access keys or connection secrets from another project.

## Organise output

Use `docs/diagrams/system-design/database-mapping/` with `java-foundations/`, `jpa-postgresql/`, `jdbc/`, `mongodb/`, `dynamodb/`, `id-generation/`, `spring-application/`, `conversions/` and `connection-guides/`. Keep diagrams separate from prose. Add a version matrix, a searchable annotation catalogue, a snippet index, a learning order and remaining gaps. Reuse related existing material.

For each annotation or tightly related family, include:

- Its fully qualified import, owner, supported versions and exact legal target: type, field, getter, method, constructor or parameter.
- Its everyday purpose, the requirement it supports and when not to use it.
- Every relevant attribute and variation, default values, alias relationships, allowed combinations and conflicting settings. Distinguish JPA-standard from Hibernate-specific features.
- Who reads it and when: compiler, Spring bean scanner, proxy infrastructure, ORM metadata processing, converter or Enhanced Client schema generation.
- Its effect on Java objects, SQL/DDL, BSON, or DynamoDB AttributeValue; distinguish schema-generation metadata from constraints actually installed in storage.
- One minimal good example and a realistic wrong example, both explicitly labelled, plus the smallest correction and the reason.
- One original readable diagram showing the responsible layer, not a vague chain of interchangeable boxes.
- Required setup and imports; complete/fragment/pseudocode labels; compile/run status; guarantees, non-guarantees, test evidence, alternative and trade-off.
- One prediction question and one variation for independent implementation.

## Java foundations needed to read the code

Cover interfaces, marker and functional interfaces, abstract/concrete classes, implementations and proxies; generics including <S extends Transaction>, type inference and erasure; the distinction between a Java entity named Transaction and a database transaction. Explain that a generic type variable does not construct an object. Cover annotation declarations and @Target, @Retention, @Documented, @Inherited, repeatable annotations, reflection and framework-specific metadata such as @AliasFor. Explain constructor versus field access, primitive versus wrapper/nullability, equals/hashCode and mutable identity, records/immutability where supported, AutoCloseable and resource ownership. Introduce only the Java concepts needed by each current example.

## PostgreSQL / JPA / Hibernate families

Enumerate the official version-specific catalogue, including these families and their variations:

- Identity and mapping: @Entity, @Table, @Column, @Id, @GeneratedValue, @SequenceGenerator, @TableGenerator, @IdClass, @EmbeddedId, @Basic, @Access, @Transient, @Embeddable, @Embedded, @AttributeOverride(s), @AssociationOverride(s), @SecondaryTable(s), @PrimaryKeyJoinColumn(s), @UniqueConstraint and @Index.
- Field characteristics: column name, nullability, uniqueness, insertable/updatable, length, precision/scale, definition, generated/default values, enum/string representation, large objects, UUIDs and date/time types. Explain why updatable=false is not database immutability and why unique=true is not a runtime duplicate check.
- Converters and mapping extensions: @Convert, @Converter, autoApply, custom Hibernate JDBC/Java type mappings, JSON support, generated timestamps and database-generated values. Verify provider-specific names and version support from official sources.
- Relationships: @OneToOne, @OneToMany, @ManyToOne, @ManyToMany, @JoinColumn(s), @JoinTable, @MapsId, @ElementCollection, @CollectionTable, @OrderBy, @OrderColumn, map-key variants, owning/inverse sides and mappedBy. Cover each cascade operation, orphanRemoval, fetch choices and defaults.
- Concurrency: @Version and optimistic locking; Spring Data @Lock; database constraints and conditional SQL as distinct mechanisms.
- Inheritance: @MappedSuperclass, @Inheritance, discriminator annotations, single-table/joined/table-per-class trade-offs and polymorphic queries.
- Lifecycle and auditing: pre/post persist/update/remove/load callbacks, listeners, Spring Data auditing annotations, actor/time provenance and callback limitations.
- Queries and results: derived methods, @Query, @Param, @Modifying, named JPQL/native queries, result-set mappings, constructor/projection mappings, @EntityGraph and named graph families, @QueryHints, stored procedures and @Procedure where supported.
- Hibernate-specific fetch, batching, immutability, soft-delete/filter, caching and dynamic SQL annotations: distinguish supported features from obsolete examples. Enumerate against the resolved Hibernate API; do not present an illustrative list as exhaustive.

## IDs: generation is separate from uniqueness and idempotency

Explain application-assigned IDs and all five JPA GenerationType choices: UUID, SEQUENCE, IDENTITY, TABLE and AUTO. Include database UUID generation, sequence allocation/optimizers and allocation-size alignment, identity insertion timing and batching, concurrency, rollback gaps, portability and migration. Compare composite versus surrogate keys, business uniqueness, distributed allocation, predictability, index locality and key size. UUID variants and time-ordered alternatives require explicit version/library verification; do not label all UUIDs equivalent or absolutely collision-proof.

For the current model, trace UUID.randomUUID in the constructor, assigned-ID newness detection, persist versus merge, why a new object may follow a merge path, and why the returned managed instance matters. Keep the primary key distinct from the merchant-scoped request key.

## JDBC path and object-to-storage conversion

Explain that JDBC has no JPA annotation-mapping engine. Trace object field -> ORM/basic/custom converter -> JDBC parameter binding -> PostgreSQL wire encoding -> stored column, and reverse through ResultSet and entity hydration. Plain JDBC/JdbcTemplate/JdbcClient require explicit SQL and row mapping; compare without adding them gratuitously.

Use conversion examples for long/BIGINT, int/INTEGER overflow, BigDecimal/NUMERIC precision and scale, money in minor units, UUID, boolean, char/text/varchar limits, enum name versus ordinal, LocalDate, LocalDateTime, Instant and OffsetDateTime, timestamptz semantics, timestamp precision, nulls versus primitives, binary/LOB, JSON and arrays. Determine actual driver support rather than inventing direct mappings.

Explain constructor hydration, protected no-argument constructors, access mode, lazy proxies, database defaults versus Java defaults, generated values and refresh, missing columns, reserved identifiers, casing/naming strategies, schema/search_path, collation and encoding. Do not call all of this Java serialization: ORM mapping, JDBC encoding, JSON serialization and Java Serializable are different mechanisms.

## MongoDB path

Inventory Spring Data MongoDB annotations and dependencies for a compatible version. Cover @Document, Spring Data @Id, @MongoId and FieldType, @Field, @Transient, @Version, @Indexed, @CompoundIndex(es), text/geospatial/hash index annotations, reference annotations and auditing options that exist in the selected version. Explain why the JPA annotations do not configure this mapper.

Trace Java object -> MappingMongoConverter -> Document/BSON -> MongoDB Java driver -> server, and reverse. Compare native-driver codecs/POJO codecs with Spring mapping. Cover ObjectId versus String versus UUID identity, BSON types, Decimal128 and explicit conversion choices, dates/precision, absent versus null fields, nested documents and arrays, embedding versus references, index creation disabled unless deliberately configured, unique compound indexes, single-document atomicity, optimistic concurrency and transactions requiring compatible server topology. Do not promise JPA cascades or joins in MongoDB.

## DynamoDB path

Use AWS SDK v2 DynamoDbClient and DynamoDbEnhancedClient, not the obsolete SDK v1 mapper model. Enumerate the selected Enhanced Client's annotation package and extension annotations: bean/immutable mapping, partition/sort keys, attribute names, ignored fields, converters/providers, secondary-index keys, flattening/update behaviour, version attributes, generated UUID/timestamp extensions where supported, and their actual targets and prerequisites. Include static TableSchema as an annotation-free alternative.

Trace Java bean -> TableSchema/AttributeConverter -> AttributeValue map -> SDK marshalling/signing/HTTP -> managed DynamoDB service, and reverse. Explain String/Number/Binary/Boolean/Null/List/Map/Set representations, numerical precision, absent values and null update semantics, empty-value restrictions where applicable and attribute-size limits verified against current docs.

Cover application key assignment, optional client extensions, composite primary-key uniqueness, PutItem replacement risk, conditional writes, version conditions, atomic counters and transactions. Mapping annotations do not create tables or provision indexes by themselves. Separate key design, access patterns, secondary indexes, eventual/strong reads, hot partitions, throttling and retries from Java annotation mechanics.

DynamoDB Local is a development emulator with limitations; it is not an in-house production replacement for the AWS managed service. SDK presence does not establish authentication, permissions, endpoint availability or connectivity.

## Surrounding Spring application annotations

Inventory applicable annotations across the selected dependencies, not just persistence:

- Boot/configuration: @SpringBootApplication and composed annotations, @Configuration, @Bean, @ComponentScan, @Import, @Profile, conditional configuration and @ConfigurationProperties. Explain bean creation versus dependency injection.
- Components/injection: @Component, @Service, @Repository, @Controller, @RestController, @Autowired, @Qualifier, @Primary, @Value, scopes, lifecycle callbacks and constructor versus field injection.
- Transactions: Spring versus Jakarta @Transactional, attribute defaults/aliases, propagation, isolation, timeouts, read-only and rollback rules. Separate annotation meta-annotations from transaction options.
- HTTP and validation: mapping annotations, body/path/query/header binding, exception handlers/advice, @Valid, @Validated, validation constraints and groups. Validation is not a substitute for database constraints under concurrency.
- Security: request authorization and method-security annotations available in the chosen setup, enabling configuration, authenticated tenant context and defense in depth. An annotation alone does not secure all access paths.
- Caching, scheduling, async and events: applicable annotations, required enabling configuration, proxy boundaries, executors, context propagation and transactional-event timing. Explain where adding them changes correctness.
- Testing: JUnit Jupiter, SpringBootTest, DataJpaTest, ActiveProfiles, transactional test behaviour, rollback/commit controls, mocks and version-specific replacement/deprecation. Do not mix incompatible test bootstrap annotations.

## Connection examples and verification

Provide separate minimal connection guides for each datastore: dependency, endpoint, database/table/collection, identity, credentials source, TLS, pooling/timeout concerns, permissions and an explicit opt-in read-only connectivity check. Use placeholders or existing named profiles; never include secrets. No cloud provisioning, new IAM grants, live writes or migrations without separate explicit scope. Avoid automatically starting application contexts that connect to external systems.

Compile isolated examples where authorised and label outcomes precisely. Do not infer a database connection from compile success. Keep MongoDB examples as documentation unless its dependency/setup is explicitly approved. Test conversion round trips and boundary values against the actual datastore when available; report unavailable environments as gaps. Every expected error needs a provider/driver-specific explanation and a verified source or a clear hypothesis label.
