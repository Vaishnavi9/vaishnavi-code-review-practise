# Who converts the Java object?

## PostgreSQL with JPA

Java entity → Hibernate reads JPA mapping → persistence context tracks changes → flush creates SQL and binds values → JDBC driver transports SQL parameters → PostgreSQL checks types/constraints and stores row versions. Results return as JDBC values; Hibernate hydrates entities. **The JDBC driver does not discover @Entity classes by itself.** Commit and rollback are database transaction outcomes, not JSON serialization operations.

## MongoDB

Java object → Spring Data MongoDB converter, or explicit driver codec → BSON document → MongoDB driver/protocol → collection. @Document and Mongo mapping annotations are not JPA annotations. A collection has different indexing and transaction assumptions from a relational table.

## DynamoDB

Java object → Enhanced Client TableSchema / attribute converters → AttributeValue map → AWS SDK request → DynamoDB item. Partition/sort keys and conditions define access and concurrency. The low-level client accepts AttributeValue maps directly. Enhanced mapping does not create every required table/index/permission or business invariant.

## Before writing a converter

Decide null handling, accepted range, decimal scale, time zone/precision, enum/code compatibility, string length and malformed-input policy. Verify both directions and database boundary values. Avoid logging real payment payloads or credentials when diagnosing failures.

[Jakarta Persistence](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1.pdf) · [MongoDB mapping](https://docs.spring.io/spring-data/mongodb/reference/mongodb/mapping/mapping.html) · [DynamoDB table schema](https://docs.aws.amazon.com/sdk-for-java/latest/developer-guide/ddb-en-client-gs-tableschema.html)
