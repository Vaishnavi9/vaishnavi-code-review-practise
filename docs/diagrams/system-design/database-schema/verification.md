# Schema verification

Verified on 31 October 2026.

- Source: local PostgreSQL 18.6, database `paymesh`, schema `paymesh`.
- Read catalog metadata only; no table rows exported.
- Restored schema-only SQL into an isolated PostgreSQL instance with stop-on-error and one transaction.
- Compared all column names, types, nullability, defaults, identity/generated metadata; all constraints including FK targets, deferrability and validation; all index definitions; table/sequence/view inventory and RLS flags. **Columns, indexes, object inventory and constraint attributes matched. Four CHECK expressions were deparsed with per-element casts instead of an array cast on restore; all their allowed values, an invalid value, an empty value and NULL produced identical results.**
- Confirmed 28 tables, 50 foreign-key constraints, 82 indexes. There are 332 catalog constraints including PostgreSQL 18 NOT NULL entries.
- Diagrams are generated from these same catalog results. No inferred relationship is drawn.

This proves structural reproduction, not business correctness, performance, tenant authorization, backup recovery objectives or safe migration into an existing database. No rows, roles, privileges or external integrations are reproduced.

The existing `sql/001_create_transactions.sql` matches the table’s main columns and business constraints. The complete snapshot also includes the other 27 existing tables. Do not run both create scripts against the same schema.

Important current limitation: `transactions` only permits status `CREATED` and has no merchant foreign key; changing either is a future application/schema exercise. Do not assume the entire larger schema is mapped by the small service.
