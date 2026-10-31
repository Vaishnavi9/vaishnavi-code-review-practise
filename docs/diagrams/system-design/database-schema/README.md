# PayMesh database — verified schema

Captured from local PostgreSQL 18.6 on 31 October 2026. **28 tables, 50 foreign keys, 82 indexes.** The SQL was restored successfully into an isolated PostgreSQL instance; metadata equivalence is checked in the verification report. No payment rows, credentials, owners or grants are included.

[Complete FK overview](01-all-relationships.md) · [Rebuild SQL](paymesh-schema.sql) · [Exact constraints and indexes](constraints-and-indexes.md) · [Verification](verification.md)

Every arrow means **child foreign-key columns reference parent key columns**. It is not request order or money movement. Diagrams show declared database relationships only. Nullability is displayed; cardinalities beyond the enforced keys are not invented. A nullable foreign key permits no related row. A nonunique foreign key permits many children to reference one parent.

The practice `Transaction` entity maps only to `paymesh.transactions`. The other 27 tables belong to the larger existing learning schema; they are not implemented by this small service. `transactions.merchant_id` is text and has **no foreign key** to `merchants`. The unique merchant/request pair is a business constraint, not a relationship. All tables currently have row-level security disabled; this is not evidence that tenant authorization is implemented.

## Table views

Each view contains all columns, primary-key and foreign-key markers, nullability, and labelled FK arrows. Open its SVG to enlarge. Explanations are kept in this file and the constraint reference.

- [bank_accounts](bank_accounts.md) — 7 columns, 1 outgoing foreign keys.
- [bank_statement_lines](bank_statement_lines.md) — 9 columns, 1 outgoing foreign keys.
- [bank_statements](bank_statements.md) — 7 columns, 1 outgoing foreign keys.
- [fund_reservations](fund_reservations.md) — 10 columns, 5 outgoing foreign keys.
- [idempotency_requests](idempotency_requests.md) — 13 columns, 4 outgoing foreign keys.
- [journal_entries](journal_entries.md) — 10 columns, 3 outgoing foreign keys.
- [journal_lines](journal_lines.md) — 6 columns, 2 outgoing foreign keys.
- [ledger_accounts](ledger_accounts.md) — 8 columns, 1 outgoing foreign keys.
- [merchant_provider_accounts](merchant_provider_accounts.md) — 7 columns, 2 outgoing foreign keys.
- [merchants](merchants.md) — 7 columns, 0 outgoing foreign keys.
- [outbox_events](outbox_events.md) — 12 columns, 3 outgoing foreign keys.
- [payment_operations](payment_operations.md) — 9 columns, 2 outgoing foreign keys.
- [payment_status_history](payment_status_history.md) — 8 columns, 2 outgoing foreign keys.
- [payments](payments.md) — 10 columns, 1 outgoing foreign keys.
- [payout_attempts](payout_attempts.md) — 11 columns, 2 outgoing foreign keys.
- [payout_destinations](payout_destinations.md) — 7 columns, 1 outgoing foreign keys.
- [payouts](payouts.md) — 9 columns, 2 outgoing foreign keys.
- [provider_attempts](provider_attempts.md) — 14 columns, 2 outgoing foreign keys.
- [provider_inbox_events](provider_inbox_events.md) — 13 columns, 2 outgoing foreign keys.
- [providers](providers.md) — 5 columns, 0 outgoing foreign keys.
- [reconciliation_cases](reconciliation_cases.md) — 10 columns, 4 outgoing foreign keys.
- [reconciliation_matches](reconciliation_matches.md) — 5 columns, 2 outgoing foreign keys.
- [settlement_batches](settlement_batches.md) — 8 columns, 1 outgoing foreign keys.
- [settlement_items](settlement_items.md) — 6 columns, 2 outgoing foreign keys.
- [transactions](transactions.md) — 7 columns, 0 outgoing foreign keys.
- [webhook_deliveries](webhook_deliveries.md) — 9 columns, 2 outgoing foreign keys.
- [webhook_delivery_attempts](webhook_delivery_attempts.md) — 7 columns, 1 outgoing foreign keys.
- [webhook_endpoints](webhook_endpoints.md) — 6 columns, 1 outgoing foreign keys.

## Rebuild safely

This is a snapshot for an **empty, disposable PostgreSQL 18 database**. It creates the `paymesh` schema. It is not an idempotent migration and must not be run on the existing PayMesh database.

```sh
psql -X -v ON_ERROR_STOP=1 --single-transaction --dbname="$SCRATCH_DATABASE_URL" --file=paymesh-schema.sql
```

Use an externally configured connection profile. Do not add credentials to this file. The export omits database creation, roles, grants, table rows and external infrastructure. A successful schema restore proves reproducibility, not financial correctness.
