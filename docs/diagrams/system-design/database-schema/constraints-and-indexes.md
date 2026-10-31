# Exact constraints, defaults and indexes

Generated from PostgreSQL catalog metadata; SQL definitions are authoritative. PostgreSQL 18 exposes NOT NULL constraints in the catalog, so the total includes these entries.

## bank_accounts

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| bank_account_id | uuid | True | `gen_random_uuid()` |
| cash_ledger_account_id | uuid | True | `—` |
| bank_code | character varying(100) | True | `—` |
| external_account_token | character varying(300) | True | `—` |
| currency | character varying(3) | True | `—` |
| purpose | character varying(30) | True | `—` |
| status | character varying(30) | True | `—` |

### Constraints

**bank_accounts_bank_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL bank_account_id
```

**bank_accounts_bank_code_external_account_token_currency_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (bank_code, external_account_token, currency)
```

**bank_accounts_bank_code_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL bank_code
```

**bank_accounts_cash_ledger_account_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (cash_ledger_account_id) REFERENCES paymesh.ledger_accounts(account_id)
```

**bank_accounts_cash_ledger_account_id_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (cash_ledger_account_id)
```

**bank_accounts_cash_ledger_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL cash_ledger_account_id
```

**bank_accounts_currency_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (currency::text ~ '^[A-Z]{3}$'::text)
```

**bank_accounts_currency_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL currency
```

**bank_accounts_external_account_token_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL external_account_token
```

**bank_accounts_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (bank_account_id)
```

**bank_accounts_purpose_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL purpose
```

**bank_accounts_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX bank_accounts_bank_code_external_account_token_currency_key ON paymesh.bank_accounts USING btree (bank_code, external_account_token, currency);
```

```sql
CREATE UNIQUE INDEX bank_accounts_cash_ledger_account_id_key ON paymesh.bank_accounts USING btree (cash_ledger_account_id);
```

```sql
CREATE UNIQUE INDEX bank_accounts_pkey ON paymesh.bank_accounts USING btree (bank_account_id);
```

## bank_statement_lines

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| statement_line_id | uuid | True | `gen_random_uuid()` |
| statement_id | uuid | True | `—` |
| line_number | integer | True | `—` |
| external_transaction_reference | character varying(200) | False | `—` |
| direction | character varying(3) | True | `—` |
| amount_minor | bigint | True | `—` |
| description | text | False | `—` |
| booked_at | timestamp with time zone | True | `—` |
| value_date | date | False | `—` |

### Constraints

**bank_statement_lines_amount_minor_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (amount_minor > 0)
```

**bank_statement_lines_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL amount_minor
```

**bank_statement_lines_booked_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL booked_at
```

**bank_statement_lines_direction_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (direction::text = ANY (ARRAY['IN'::character varying, 'OUT'::character varying]::text[]))
```

**bank_statement_lines_direction_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL direction
```

**bank_statement_lines_line_number_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (line_number > 0)
```

**bank_statement_lines_line_number_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL line_number
```

**bank_statement_lines_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (statement_line_id)
```

**bank_statement_lines_statement_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (statement_id) REFERENCES paymesh.bank_statements(statement_id)
```

**bank_statement_lines_statement_id_line_number_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (statement_id, line_number)
```

**bank_statement_lines_statement_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL statement_id
```

**bank_statement_lines_statement_line_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL statement_line_id
```

### Indexes

```sql
CREATE UNIQUE INDEX bank_statement_lines_pkey ON paymesh.bank_statement_lines USING btree (statement_line_id);
```

```sql
CREATE INDEX bank_statement_lines_reference_idx ON paymesh.bank_statement_lines USING btree (external_transaction_reference);
```

```sql
CREATE UNIQUE INDEX bank_statement_lines_statement_id_line_number_key ON paymesh.bank_statement_lines USING btree (statement_id, line_number);
```

## bank_statements

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| statement_id | uuid | True | `gen_random_uuid()` |
| bank_account_id | uuid | True | `—` |
| external_statement_reference | character varying(200) | True | `—` |
| period_start | timestamp with time zone | True | `—` |
| period_end | timestamp with time zone | True | `—` |
| source_file_reference | character varying(500) | False | `—` |
| imported_at | timestamp with time zone | True | `now()` |

### Constraints

**bank_statements_bank_account_id_external_statement_referenc_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (bank_account_id, external_statement_reference)
```

**bank_statements_bank_account_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (bank_account_id) REFERENCES paymesh.bank_accounts(bank_account_id)
```

**bank_statements_bank_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL bank_account_id
```

**bank_statements_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (period_end > period_start)
```

**bank_statements_external_statement_reference_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL external_statement_reference
```

**bank_statements_imported_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL imported_at
```

**bank_statements_period_end_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL period_end
```

**bank_statements_period_start_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL period_start
```

**bank_statements_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (statement_id)
```

**bank_statements_statement_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL statement_id
```

### Indexes

```sql
CREATE UNIQUE INDEX bank_statements_bank_account_id_external_statement_referenc_key ON paymesh.bank_statements USING btree (bank_account_id, external_statement_reference);
```

```sql
CREATE UNIQUE INDEX bank_statements_pkey ON paymesh.bank_statements USING btree (statement_id);
```

## fund_reservations

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| reservation_id | uuid | True | `gen_random_uuid()` |
| settlement_batch_id | uuid | True | `—` |
| source_account_id | uuid | True | `—` |
| reserved_account_id | uuid | True | `—` |
| amount_minor | bigint | True | `—` |
| status | character varying(40) | True | `—` |
| reservation_journal_entry_id | uuid | True | `—` |
| release_journal_entry_id | uuid | False | `—` |
| created_at | timestamp with time zone | True | `now()` |
| closed_at | timestamp with time zone | False | `—` |

### Constraints

**fund_reservations_amount_minor_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (amount_minor > 0)
```

**fund_reservations_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL amount_minor
```

**fund_reservations_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (source_account_id <> reserved_account_id)
```

**fund_reservations_check1** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (release_journal_entry_id IS DISTINCT FROM reservation_journal_entry_id)
```

**fund_reservations_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**fund_reservations_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (reservation_id)
```

**fund_reservations_release_journal_entry_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (release_journal_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id)
```

**fund_reservations_release_journal_entry_id_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (release_journal_entry_id)
```

**fund_reservations_reservation_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL reservation_id
```

**fund_reservations_reservation_journal_entry_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (reservation_journal_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id)
```

**fund_reservations_reservation_journal_entry_id_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (reservation_journal_entry_id)
```

**fund_reservations_reservation_journal_entry_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL reservation_journal_entry_id
```

**fund_reservations_reserved_account_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (reserved_account_id) REFERENCES paymesh.ledger_accounts(account_id)
```

**fund_reservations_reserved_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL reserved_account_id
```

**fund_reservations_settlement_batch_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (settlement_batch_id) REFERENCES paymesh.settlement_batches(settlement_batch_id)
```

**fund_reservations_settlement_batch_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL settlement_batch_id
```

**fund_reservations_source_account_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (source_account_id) REFERENCES paymesh.ledger_accounts(account_id)
```

**fund_reservations_source_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL source_account_id
```

**fund_reservations_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE INDEX fund_reservations_batch_idx ON paymesh.fund_reservations USING btree (settlement_batch_id);
```

```sql
CREATE UNIQUE INDEX fund_reservations_pkey ON paymesh.fund_reservations USING btree (reservation_id);
```

```sql
CREATE UNIQUE INDEX fund_reservations_release_journal_entry_id_key ON paymesh.fund_reservations USING btree (release_journal_entry_id);
```

```sql
CREATE UNIQUE INDEX fund_reservations_reservation_journal_entry_id_key ON paymesh.fund_reservations USING btree (reservation_journal_entry_id);
```

```sql
CREATE INDEX fund_reservations_source_status_idx ON paymesh.fund_reservations USING btree (source_account_id, status);
```

## idempotency_requests

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| request_id | uuid | True | `gen_random_uuid()` |
| merchant_id | uuid | True | `—` |
| request_scope | character varying(200) | True | `—` |
| idempotency_key | character varying(200) | True | `—` |
| request_fingerprint | character varying(128) | True | `—` |
| payment_id | uuid | False | `—` |
| operation_id | uuid | False | `—` |
| payout_id | uuid | False | `—` |
| status | character varying(40) | True | `—` |
| response_code | integer | False | `—` |
| response_body | jsonb | False | `—` |
| created_at | timestamp with time zone | True | `now()` |
| expires_at | timestamp with time zone | False | `—` |

### Constraints

**idempotency_requests_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**idempotency_requests_idempotency_key_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL idempotency_key
```

**idempotency_requests_merchant_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id)
```

**idempotency_requests_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**idempotency_requests_merchant_id_request_scope_idempotency__key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (merchant_id, request_scope, idempotency_key)
```

**idempotency_requests_operation_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (operation_id) REFERENCES paymesh.payment_operations(operation_id)
```

**idempotency_requests_payment_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id)
```

**idempotency_requests_payout_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id)
```

**idempotency_requests_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (request_id)
```

**idempotency_requests_request_fingerprint_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL request_fingerprint
```

**idempotency_requests_request_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL request_id
```

**idempotency_requests_request_scope_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL request_scope
```

**idempotency_requests_response_code_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (response_code >= 100 AND response_code <= 599)
```

**idempotency_requests_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX idempotency_requests_merchant_id_request_scope_idempotency__key ON paymesh.idempotency_requests USING btree (merchant_id, request_scope, idempotency_key);
```

```sql
CREATE UNIQUE INDEX idempotency_requests_pkey ON paymesh.idempotency_requests USING btree (request_id);
```

## journal_entries

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| journal_entry_id | uuid | True | `gen_random_uuid()` |
| posting_key | character varying(250) | True | `—` |
| operation_id | uuid | False | `—` |
| payout_id | uuid | False | `—` |
| reversal_of_entry_id | uuid | False | `—` |
| event_type | character varying(50) | True | `—` |
| currency | character varying(3) | True | `—` |
| description | character varying(500) | False | `—` |
| effective_at | timestamp with time zone | True | `—` |
| recorded_at | timestamp with time zone | True | `now()` |

### Constraints

**journal_entries_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (reversal_of_entry_id IS DISTINCT FROM journal_entry_id)
```

**journal_entries_currency_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (currency::text ~ '^[A-Z]{3}$'::text)
```

**journal_entries_currency_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL currency
```

**journal_entries_effective_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL effective_at
```

**journal_entries_event_type_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL event_type
```

**journal_entries_journal_entry_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL journal_entry_id
```

**journal_entries_operation_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (operation_id) REFERENCES paymesh.payment_operations(operation_id)
```

**journal_entries_payout_fk** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id)
```

**journal_entries_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (journal_entry_id)
```

**journal_entries_posting_key_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (posting_key)
```

**journal_entries_posting_key_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL posting_key
```

**journal_entries_recorded_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL recorded_at
```

**journal_entries_reversal_of_entry_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (reversal_of_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id)
```

### Indexes

```sql
CREATE INDEX journal_entries_effective_idx ON paymesh.journal_entries USING btree (effective_at);
```

```sql
CREATE INDEX journal_entries_operation_idx ON paymesh.journal_entries USING btree (operation_id);
```

```sql
CREATE INDEX journal_entries_payout_idx ON paymesh.journal_entries USING btree (payout_id);
```

```sql
CREATE UNIQUE INDEX journal_entries_pkey ON paymesh.journal_entries USING btree (journal_entry_id);
```

```sql
CREATE UNIQUE INDEX journal_entries_posting_key_key ON paymesh.journal_entries USING btree (posting_key);
```

## journal_lines

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| journal_line_id | uuid | True | `gen_random_uuid()` |
| journal_entry_id | uuid | True | `—` |
| account_id | uuid | True | `—` |
| line_number | integer | True | `—` |
| side | character varying(6) | True | `—` |
| amount_minor | bigint | True | `—` |

### Constraints

**journal_lines_account_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (account_id) REFERENCES paymesh.ledger_accounts(account_id)
```

**journal_lines_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL account_id
```

**journal_lines_amount_minor_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (amount_minor > 0)
```

**journal_lines_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL amount_minor
```

**journal_lines_journal_entry_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (journal_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id)
```

**journal_lines_journal_entry_id_line_number_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (journal_entry_id, line_number)
```

**journal_lines_journal_entry_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL journal_entry_id
```

**journal_lines_journal_line_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL journal_line_id
```

**journal_lines_line_number_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (line_number > 0)
```

**journal_lines_line_number_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL line_number
```

**journal_lines_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (journal_line_id)
```

**journal_lines_side_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (side::text = ANY (ARRAY['DEBIT'::character varying, 'CREDIT'::character varying]::text[]))
```

**journal_lines_side_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL side
```

### Indexes

```sql
CREATE INDEX journal_lines_account_idx ON paymesh.journal_lines USING btree (account_id);
```

```sql
CREATE UNIQUE INDEX journal_lines_journal_entry_id_line_number_key ON paymesh.journal_lines USING btree (journal_entry_id, line_number);
```

```sql
CREATE UNIQUE INDEX journal_lines_pkey ON paymesh.journal_lines USING btree (journal_line_id);
```

## ledger_accounts

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| account_id | uuid | True | `gen_random_uuid()` |
| merchant_id | uuid | False | `—` |
| account_code | character varying(150) | True | `—` |
| name | character varying(200) | True | `—` |
| account_type | character varying(30) | True | `—` |
| currency | character varying(3) | True | `—` |
| status | character varying(30) | True | `—` |
| created_at | timestamp with time zone | True | `now()` |

### Constraints

**ledger_accounts_account_code_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (account_code)
```

**ledger_accounts_account_code_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL account_code
```

**ledger_accounts_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL account_id
```

**ledger_accounts_account_type_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (account_type::text = ANY (ARRAY['ASSET'::character varying, 'LIABILITY'::character varying, 'REVENUE'::character varying, 'EXPENSE'::character varying, 'EQUITY'::character varying]::text[]))
```

**ledger_accounts_account_type_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL account_type
```

**ledger_accounts_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**ledger_accounts_currency_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (currency::text ~ '^[A-Z]{3}$'::text)
```

**ledger_accounts_currency_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL currency
```

**ledger_accounts_merchant_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id)
```

**ledger_accounts_name_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL name
```

**ledger_accounts_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (account_id)
```

**ledger_accounts_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX ledger_accounts_account_code_key ON paymesh.ledger_accounts USING btree (account_code);
```

```sql
CREATE INDEX ledger_accounts_merchant_currency_idx ON paymesh.ledger_accounts USING btree (merchant_id, currency);
```

```sql
CREATE UNIQUE INDEX ledger_accounts_pkey ON paymesh.ledger_accounts USING btree (account_id);
```

## merchant_provider_accounts

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| merchant_provider_account_id | uuid | True | `gen_random_uuid()` |
| merchant_id | uuid | True | `—` |
| provider_id | uuid | True | `—` |
| external_account_reference | character varying(200) | True | `—` |
| credential_secret_reference | character varying(500) | False | `—` |
| status | character varying(30) | True | `—` |
| created_at | timestamp with time zone | True | `now()` |

### Constraints

**merchant_provider_accounts_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**merchant_provider_accounts_external_account_reference_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL external_account_reference
```

**merchant_provider_accounts_merchant_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id)
```

**merchant_provider_accounts_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**merchant_provider_accounts_merchant_provider_account_i_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_provider_account_id
```

**merchant_provider_accounts_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (merchant_provider_account_id)
```

**merchant_provider_accounts_provider_id_external_account_ref_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (provider_id, external_account_reference)
```

**merchant_provider_accounts_provider_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (provider_id) REFERENCES paymesh.providers(provider_id)
```

**merchant_provider_accounts_provider_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL provider_id
```

**merchant_provider_accounts_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE INDEX merchant_provider_accounts_merchant_idx ON paymesh.merchant_provider_accounts USING btree (merchant_id);
```

```sql
CREATE UNIQUE INDEX merchant_provider_accounts_pkey ON paymesh.merchant_provider_accounts USING btree (merchant_provider_account_id);
```

```sql
CREATE UNIQUE INDEX merchant_provider_accounts_provider_id_external_account_ref_key ON paymesh.merchant_provider_accounts USING btree (provider_id, external_account_reference);
```

## merchants

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| merchant_id | uuid | True | `gen_random_uuid()` |
| name | character varying(200) | True | `—` |
| onboarding_status | character varying(30) | True | `—` |
| processing_status | character varying(30) | True | `—` |
| payout_status | character varying(30) | True | `—` |
| created_at | timestamp with time zone | True | `now()` |
| updated_at | timestamp with time zone | True | `now()` |

### Constraints

**merchants_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**merchants_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**merchants_name_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL name
```

**merchants_onboarding_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL onboarding_status
```

**merchants_payout_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payout_status
```

**merchants_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (merchant_id)
```

**merchants_processing_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL processing_status
```

**merchants_updated_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL updated_at
```

### Indexes

```sql
CREATE UNIQUE INDEX merchants_pkey ON paymesh.merchants USING btree (merchant_id);
```

## outbox_events

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| event_id | uuid | True | `gen_random_uuid()` |
| merchant_id | uuid | True | `—` |
| payment_id | uuid | False | `—` |
| payout_id | uuid | False | `—` |
| event_type | character varying(100) | True | `—` |
| schema_version | integer | True | `1` |
| payload | jsonb | True | `—` |
| status | character varying(40) | True | `—` |
| publish_attempt_count | integer | True | `0` |
| available_at | timestamp with time zone | True | `now()` |
| created_at | timestamp with time zone | True | `now()` |
| published_at | timestamp with time zone | False | `—` |

### Constraints

**outbox_events_available_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL available_at
```

**outbox_events_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**outbox_events_event_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL event_id
```

**outbox_events_event_type_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL event_type
```

**outbox_events_merchant_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id)
```

**outbox_events_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**outbox_events_payload_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payload
```

**outbox_events_payment_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id)
```

**outbox_events_payout_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id)
```

**outbox_events_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (event_id)
```

**outbox_events_publish_attempt_count_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (publish_attempt_count >= 0)
```

**outbox_events_publish_attempt_count_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL publish_attempt_count
```

**outbox_events_schema_version_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (schema_version > 0)
```

**outbox_events_schema_version_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL schema_version
```

**outbox_events_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE INDEX outbox_events_available_idx ON paymesh.outbox_events USING btree (status, available_at);
```

```sql
CREATE INDEX outbox_events_payment_idx ON paymesh.outbox_events USING btree (payment_id);
```

```sql
CREATE INDEX outbox_events_payout_idx ON paymesh.outbox_events USING btree (payout_id);
```

```sql
CREATE UNIQUE INDEX outbox_events_pkey ON paymesh.outbox_events USING btree (event_id);
```

## payment_operations

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| operation_id | uuid | True | `gen_random_uuid()` |
| payment_id | uuid | True | `—` |
| parent_operation_id | uuid | False | `—` |
| operation_type | character varying(30) | True | `—` |
| amount_minor | bigint | True | `—` |
| status | character varying(40) | True | `—` |
| version | bigint | True | `0` |
| created_at | timestamp with time zone | True | `now()` |
| completed_at | timestamp with time zone | False | `—` |

### Constraints

**payment_operations_amount_minor_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (amount_minor > 0)
```

**payment_operations_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL amount_minor
```

**payment_operations_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (parent_operation_id IS DISTINCT FROM operation_id)
```

**payment_operations_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**payment_operations_operation_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL operation_id
```

**payment_operations_operation_type_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (operation_type::text = ANY (ARRAY['AUTHORIZE'::character varying, 'CHARGE'::character varying, 'CAPTURE'::character varying, 'VOID'::character varying, 'REFUND'::character varying]::text[]))
```

**payment_operations_operation_type_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL operation_type
```

**payment_operations_parent_operation_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (parent_operation_id) REFERENCES paymesh.payment_operations(operation_id)
```

**payment_operations_payment_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id)
```

**payment_operations_payment_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payment_id
```

**payment_operations_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (operation_id)
```

**payment_operations_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

**payment_operations_version_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (version >= 0)
```

**payment_operations_version_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL version
```

### Indexes

```sql
CREATE INDEX payment_operations_parent_idx ON paymesh.payment_operations USING btree (parent_operation_id);
```

```sql
CREATE INDEX payment_operations_payment_created_idx ON paymesh.payment_operations USING btree (payment_id, created_at);
```

```sql
CREATE UNIQUE INDEX payment_operations_pkey ON paymesh.payment_operations USING btree (operation_id);
```

## payment_status_history

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| history_id | uuid | True | `gen_random_uuid()` |
| payment_id | uuid | True | `—` |
| payment_version | bigint | True | `—` |
| old_status | character varying(40) | False | `—` |
| new_status | character varying(40) | True | `—` |
| reason | character varying(300) | False | `—` |
| source_inbox_event_id | uuid | False | `—` |
| recorded_at | timestamp with time zone | True | `now()` |

### Constraints

**payment_status_history_history_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL history_id
```

**payment_status_history_new_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL new_status
```

**payment_status_history_payment_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id)
```

**payment_status_history_payment_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payment_id
```

**payment_status_history_payment_id_payment_version_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (payment_id, payment_version)
```

**payment_status_history_payment_version_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (payment_version >= 0)
```

**payment_status_history_payment_version_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payment_version
```

**payment_status_history_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (history_id)
```

**payment_status_history_recorded_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL recorded_at
```

**payment_status_history_source_inbox_event_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (source_inbox_event_id) REFERENCES paymesh.provider_inbox_events(inbox_event_id)
```

### Indexes

```sql
CREATE UNIQUE INDEX payment_status_history_payment_id_payment_version_key ON paymesh.payment_status_history USING btree (payment_id, payment_version);
```

```sql
CREATE UNIQUE INDEX payment_status_history_pkey ON paymesh.payment_status_history USING btree (history_id);
```

## payments

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| payment_id | uuid | True | `gen_random_uuid()` |
| merchant_id | uuid | True | `—` |
| merchant_order_reference | character varying(200) | False | `—` |
| amount_minor | bigint | True | `—` |
| currency | character varying(3) | True | `—` |
| payment_method_type | character varying(50) | True | `—` |
| status | character varying(40) | True | `—` |
| version | bigint | True | `0` |
| created_at | timestamp with time zone | True | `now()` |
| updated_at | timestamp with time zone | True | `now()` |

### Constraints

**payments_amount_minor_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (amount_minor > 0)
```

**payments_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL amount_minor
```

**payments_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**payments_currency_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (currency::text ~ '^[A-Z]{3}$'::text)
```

**payments_currency_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL currency
```

**payments_merchant_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id)
```

**payments_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**payments_payment_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payment_id
```

**payments_payment_method_type_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payment_method_type
```

**payments_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (payment_id)
```

**payments_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

**payments_updated_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL updated_at
```

**payments_version_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (version >= 0)
```

**payments_version_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL version
```

### Indexes

```sql
CREATE INDEX payments_merchant_created_idx ON paymesh.payments USING btree (merchant_id, created_at);
```

```sql
CREATE INDEX payments_merchant_order_idx ON paymesh.payments USING btree (merchant_id, merchant_order_reference);
```

```sql
CREATE UNIQUE INDEX payments_pkey ON paymesh.payments USING btree (payment_id);
```

## payout_attempts

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| payout_attempt_id | uuid | True | `gen_random_uuid()` |
| payout_id | uuid | True | `—` |
| bank_account_id | uuid | True | `—` |
| attempt_number | integer | True | `—` |
| external_idempotency_key | character varying(200) | True | `—` |
| bank_reference | character varying(200) | False | `—` |
| status | character varying(40) | True | `—` |
| error_code | character varying(100) | False | `—` |
| started_at | timestamp with time zone | True | `now()` |
| last_checked_at | timestamp with time zone | False | `—` |
| resolved_at | timestamp with time zone | False | `—` |

### Constraints

**payout_attempts_attempt_number_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (attempt_number > 0)
```

**payout_attempts_attempt_number_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL attempt_number
```

**payout_attempts_bank_account_id_external_idempotency_key_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (bank_account_id, external_idempotency_key)
```

**payout_attempts_bank_account_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (bank_account_id) REFERENCES paymesh.bank_accounts(bank_account_id)
```

**payout_attempts_bank_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL bank_account_id
```

**payout_attempts_external_idempotency_key_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL external_idempotency_key
```

**payout_attempts_payout_attempt_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payout_attempt_id
```

**payout_attempts_payout_id_attempt_number_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (payout_id, attempt_number)
```

**payout_attempts_payout_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id)
```

**payout_attempts_payout_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payout_id
```

**payout_attempts_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (payout_attempt_id)
```

**payout_attempts_started_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL started_at
```

**payout_attempts_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX payout_attempts_bank_account_id_external_idempotency_key_key ON paymesh.payout_attempts USING btree (bank_account_id, external_idempotency_key);
```

```sql
CREATE UNIQUE INDEX payout_attempts_payout_id_attempt_number_key ON paymesh.payout_attempts USING btree (payout_id, attempt_number);
```

```sql
CREATE UNIQUE INDEX payout_attempts_pkey ON paymesh.payout_attempts USING btree (payout_attempt_id);
```

```sql
CREATE INDEX payout_attempts_reference_idx ON paymesh.payout_attempts USING btree (bank_account_id, bank_reference);
```

## payout_destinations

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| payout_destination_id | uuid | True | `gen_random_uuid()` |
| merchant_id | uuid | True | `—` |
| bank_account_token | character varying(300) | True | `—` |
| account_holder_name | character varying(200) | True | `—` |
| currency | character varying(3) | True | `—` |
| status | character varying(30) | True | `—` |
| created_at | timestamp with time zone | True | `now()` |

### Constraints

**payout_destinations_account_holder_name_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL account_holder_name
```

**payout_destinations_bank_account_token_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL bank_account_token
```

**payout_destinations_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**payout_destinations_currency_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (currency::text ~ '^[A-Z]{3}$'::text)
```

**payout_destinations_currency_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL currency
```

**payout_destinations_merchant_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id)
```

**payout_destinations_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**payout_destinations_payout_destination_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payout_destination_id
```

**payout_destinations_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (payout_destination_id)
```

**payout_destinations_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE INDEX payout_destinations_merchant_idx ON paymesh.payout_destinations USING btree (merchant_id);
```

```sql
CREATE UNIQUE INDEX payout_destinations_pkey ON paymesh.payout_destinations USING btree (payout_destination_id);
```

## payouts

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| payout_id | uuid | True | `gen_random_uuid()` |
| reservation_id | uuid | True | `—` |
| payout_destination_id | uuid | True | `—` |
| amount_minor | bigint | True | `—` |
| currency | character varying(3) | True | `—` |
| status | character varying(40) | True | `—` |
| version | bigint | True | `0` |
| created_at | timestamp with time zone | True | `now()` |
| completed_at | timestamp with time zone | False | `—` |

### Constraints

**payouts_amount_minor_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (amount_minor > 0)
```

**payouts_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL amount_minor
```

**payouts_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**payouts_currency_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (currency::text ~ '^[A-Z]{3}$'::text)
```

**payouts_currency_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL currency
```

**payouts_payout_destination_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payout_destination_id) REFERENCES paymesh.payout_destinations(payout_destination_id)
```

**payouts_payout_destination_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payout_destination_id
```

**payouts_payout_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payout_id
```

**payouts_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (payout_id)
```

**payouts_reservation_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (reservation_id) REFERENCES paymesh.fund_reservations(reservation_id)
```

**payouts_reservation_id_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (reservation_id)
```

**payouts_reservation_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL reservation_id
```

**payouts_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

**payouts_version_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (version >= 0)
```

**payouts_version_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL version
```

### Indexes

```sql
CREATE INDEX payouts_destination_idx ON paymesh.payouts USING btree (payout_destination_id);
```

```sql
CREATE UNIQUE INDEX payouts_pkey ON paymesh.payouts USING btree (payout_id);
```

```sql
CREATE UNIQUE INDEX payouts_reservation_id_key ON paymesh.payouts USING btree (reservation_id);
```

```sql
CREATE INDEX payouts_status_created_idx ON paymesh.payouts USING btree (status, created_at);
```

## provider_attempts

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| attempt_id | uuid | True | `gen_random_uuid()` |
| operation_id | uuid | True | `—` |
| merchant_provider_account_id | uuid | True | `—` |
| attempt_number | integer | True | `—` |
| provider_request_scope | character varying(100) | True | `—` |
| provider_idempotency_key | character varying(200) | True | `—` |
| provider_reference | character varying(200) | False | `—` |
| status | character varying(40) | True | `—` |
| provider_status | character varying(100) | False | `—` |
| error_code | character varying(100) | False | `—` |
| next_action | jsonb | False | `—` |
| started_at | timestamp with time zone | True | `now()` |
| last_checked_at | timestamp with time zone | False | `—` |
| resolved_at | timestamp with time zone | False | `—` |

### Constraints

**provider_attempts_attempt_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL attempt_id
```

**provider_attempts_attempt_number_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (attempt_number > 0)
```

**provider_attempts_attempt_number_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL attempt_number
```

**provider_attempts_merchant_provider_account_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_provider_account_id) REFERENCES paymesh.merchant_provider_accounts(merchant_provider_account_id)
```

**provider_attempts_merchant_provider_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_provider_account_id
```

**provider_attempts_merchant_provider_account_id_provider_req_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (merchant_provider_account_id, provider_request_scope, provider_idempotency_key)
```

**provider_attempts_operation_id_attempt_number_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (operation_id, attempt_number)
```

**provider_attempts_operation_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (operation_id) REFERENCES paymesh.payment_operations(operation_id)
```

**provider_attempts_operation_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL operation_id
```

**provider_attempts_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (attempt_id)
```

**provider_attempts_provider_idempotency_key_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL provider_idempotency_key
```

**provider_attempts_provider_request_scope_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL provider_request_scope
```

**provider_attempts_started_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL started_at
```

**provider_attempts_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX provider_attempts_merchant_provider_account_id_provider_req_key ON paymesh.provider_attempts USING btree (merchant_provider_account_id, provider_request_scope, provider_idempotency_key);
```

```sql
CREATE UNIQUE INDEX provider_attempts_operation_id_attempt_number_key ON paymesh.provider_attempts USING btree (operation_id, attempt_number);
```

```sql
CREATE UNIQUE INDEX provider_attempts_pkey ON paymesh.provider_attempts USING btree (attempt_id);
```

```sql
CREATE INDEX provider_attempts_reference_idx ON paymesh.provider_attempts USING btree (merchant_provider_account_id, provider_reference);
```

```sql
CREATE INDEX provider_attempts_status_check_idx ON paymesh.provider_attempts USING btree (status, last_checked_at);
```

## provider_inbox_events

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| inbox_event_id | uuid | True | `gen_random_uuid()` |
| merchant_provider_account_id | uuid | True | `—` |
| attempt_id | uuid | False | `—` |
| deduplication_key | character varying(250) | True | `—` |
| event_type | character varying(100) | True | `—` |
| payload | jsonb | True | `—` |
| status | character varying(40) | True | `—` |
| processing_attempt_count | integer | True | `0` |
| last_error | text | False | `—` |
| received_at | timestamp with time zone | True | `now()` |
| verified_at | timestamp with time zone | True | `—` |
| processed_at | timestamp with time zone | False | `—` |
| next_attempt_at | timestamp with time zone | False | `—` |

### Constraints

**provider_inbox_events_attempt_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (attempt_id) REFERENCES paymesh.provider_attempts(attempt_id)
```

**provider_inbox_events_deduplication_key_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL deduplication_key
```

**provider_inbox_events_event_type_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL event_type
```

**provider_inbox_events_inbox_event_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL inbox_event_id
```

**provider_inbox_events_merchant_provider_account_id_deduplic_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (merchant_provider_account_id, deduplication_key)
```

**provider_inbox_events_merchant_provider_account_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_provider_account_id) REFERENCES paymesh.merchant_provider_accounts(merchant_provider_account_id)
```

**provider_inbox_events_merchant_provider_account_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_provider_account_id
```

**provider_inbox_events_payload_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL payload
```

**provider_inbox_events_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (inbox_event_id)
```

**provider_inbox_events_processing_attempt_count_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (processing_attempt_count >= 0)
```

**provider_inbox_events_processing_attempt_count_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL processing_attempt_count
```

**provider_inbox_events_received_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL received_at
```

**provider_inbox_events_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

**provider_inbox_events_verified_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL verified_at
```

### Indexes

```sql
CREATE INDEX provider_inbox_events_attempt_idx ON paymesh.provider_inbox_events USING btree (attempt_id);
```

```sql
CREATE UNIQUE INDEX provider_inbox_events_merchant_provider_account_id_deduplic_key ON paymesh.provider_inbox_events USING btree (merchant_provider_account_id, deduplication_key);
```

```sql
CREATE UNIQUE INDEX provider_inbox_events_pkey ON paymesh.provider_inbox_events USING btree (inbox_event_id);
```

```sql
CREATE INDEX provider_inbox_events_retry_idx ON paymesh.provider_inbox_events USING btree (status, next_attempt_at);
```

## providers

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| provider_id | uuid | True | `gen_random_uuid()` |
| code | character varying(50) | True | `—` |
| name | character varying(200) | True | `—` |
| status | character varying(30) | True | `—` |
| created_at | timestamp with time zone | True | `now()` |

### Constraints

**providers_code_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (code)
```

**providers_code_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL code
```

**providers_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**providers_name_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL name
```

**providers_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (provider_id)
```

**providers_provider_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL provider_id
```

**providers_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX providers_code_key ON paymesh.providers USING btree (code);
```

```sql
CREATE UNIQUE INDEX providers_pkey ON paymesh.providers USING btree (provider_id);
```

## reconciliation_cases

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| case_id | uuid | True | `gen_random_uuid()` |
| statement_line_id | uuid | False | `—` |
| journal_entry_id | uuid | False | `—` |
| payment_id | uuid | False | `—` |
| payout_id | uuid | False | `—` |
| reason | character varying(100) | True | `—` |
| status | character varying(40) | True | `—` |
| resolution_notes | text | False | `—` |
| created_at | timestamp with time zone | True | `now()` |
| resolved_at | timestamp with time zone | False | `—` |

### Constraints

**reconciliation_cases_case_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL case_id
```

**reconciliation_cases_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**reconciliation_cases_journal_entry_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (journal_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id)
```

**reconciliation_cases_payment_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id)
```

**reconciliation_cases_payout_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id)
```

**reconciliation_cases_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (case_id)
```

**reconciliation_cases_reason_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL reason
```

**reconciliation_cases_statement_line_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (statement_line_id) REFERENCES paymesh.bank_statement_lines(statement_line_id)
```

**reconciliation_cases_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX reconciliation_cases_pkey ON paymesh.reconciliation_cases USING btree (case_id);
```

```sql
CREATE INDEX reconciliation_cases_status_idx ON paymesh.reconciliation_cases USING btree (status, created_at);
```

## reconciliation_matches

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| statement_line_id | uuid | True | `—` |
| journal_line_id | uuid | True | `—` |
| matched_amount_minor | bigint | True | `—` |
| match_method | character varying(30) | True | `—` |
| matched_at | timestamp with time zone | True | `now()` |

### Constraints

**reconciliation_matches_journal_line_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (journal_line_id) REFERENCES paymesh.journal_lines(journal_line_id)
```

**reconciliation_matches_journal_line_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL journal_line_id
```

**reconciliation_matches_match_method_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL match_method
```

**reconciliation_matches_matched_amount_minor_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (matched_amount_minor > 0)
```

**reconciliation_matches_matched_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL matched_amount_minor
```

**reconciliation_matches_matched_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL matched_at
```

**reconciliation_matches_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (statement_line_id, journal_line_id)
```

**reconciliation_matches_statement_line_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (statement_line_id) REFERENCES paymesh.bank_statement_lines(statement_line_id)
```

**reconciliation_matches_statement_line_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL statement_line_id
```

### Indexes

```sql
CREATE INDEX reconciliation_matches_journal_line_idx ON paymesh.reconciliation_matches USING btree (journal_line_id);
```

```sql
CREATE UNIQUE INDEX reconciliation_matches_pkey ON paymesh.reconciliation_matches USING btree (statement_line_id, journal_line_id);
```

## settlement_batches

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| settlement_batch_id | uuid | True | `gen_random_uuid()` |
| merchant_id | uuid | True | `—` |
| batch_reference | character varying(200) | True | `—` |
| currency | character varying(3) | True | `—` |
| status | character varying(40) | True | `—` |
| cutoff_at | timestamp with time zone | True | `—` |
| created_at | timestamp with time zone | True | `now()` |
| finalized_at | timestamp with time zone | False | `—` |

### Constraints

**settlement_batches_batch_reference_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (batch_reference)
```

**settlement_batches_batch_reference_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL batch_reference
```

**settlement_batches_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**settlement_batches_currency_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (currency::text ~ '^[A-Z]{3}$'::text)
```

**settlement_batches_currency_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL currency
```

**settlement_batches_cutoff_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL cutoff_at
```

**settlement_batches_merchant_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id)
```

**settlement_batches_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**settlement_batches_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (settlement_batch_id)
```

**settlement_batches_settlement_batch_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL settlement_batch_id
```

**settlement_batches_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX settlement_batches_batch_reference_key ON paymesh.settlement_batches USING btree (batch_reference);
```

```sql
CREATE INDEX settlement_batches_merchant_idx ON paymesh.settlement_batches USING btree (merchant_id, currency, created_at);
```

```sql
CREATE UNIQUE INDEX settlement_batches_pkey ON paymesh.settlement_batches USING btree (settlement_batch_id);
```

## settlement_items

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| settlement_item_id | uuid | True | `gen_random_uuid()` |
| settlement_batch_id | uuid | True | `—` |
| source_journal_line_id | uuid | True | `—` |
| item_type | character varying(30) | True | `—` |
| signed_amount_minor | bigint | True | `—` |
| created_at | timestamp with time zone | True | `now()` |

### Constraints

**settlement_items_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**settlement_items_item_type_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL item_type
```

**settlement_items_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (settlement_item_id)
```

**settlement_items_settlement_batch_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (settlement_batch_id) REFERENCES paymesh.settlement_batches(settlement_batch_id)
```

**settlement_items_settlement_batch_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL settlement_batch_id
```

**settlement_items_settlement_item_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL settlement_item_id
```

**settlement_items_signed_amount_minor_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (signed_amount_minor <> 0)
```

**settlement_items_signed_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL signed_amount_minor
```

**settlement_items_source_journal_line_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (source_journal_line_id) REFERENCES paymesh.journal_lines(journal_line_id)
```

**settlement_items_source_journal_line_id_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (source_journal_line_id)
```

**settlement_items_source_journal_line_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL source_journal_line_id
```

### Indexes

```sql
CREATE INDEX settlement_items_batch_idx ON paymesh.settlement_items USING btree (settlement_batch_id);
```

```sql
CREATE UNIQUE INDEX settlement_items_pkey ON paymesh.settlement_items USING btree (settlement_item_id);
```

```sql
CREATE UNIQUE INDEX settlement_items_source_journal_line_id_key ON paymesh.settlement_items USING btree (source_journal_line_id);
```

## transactions

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| id | uuid | True | `—` |
| merchant_id | character varying(100) | True | `—` |
| request_key | character varying(128) | True | `—` |
| amount_minor | bigint | True | `—` |
| currency | character varying(3) | True | `—` |
| status | character varying(20) | True | `'CREATED'::character varying` |
| created_at | timestamp with time zone | True | `CURRENT_TIMESTAMP` |

### Constraints

**transactions_amount_minor_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL amount_minor
```

**transactions_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**transactions_currency_format** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (currency::text ~ '^[A-Z]{3}$'::text)
```

**transactions_currency_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL currency
```

**transactions_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL id
```

**transactions_initial_status** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (status::text = 'CREATED'::text)
```

**transactions_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**transactions_merchant_not_blank** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (length(btrim(merchant_id::text)) > 0)
```

**transactions_merchant_request_unique** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (merchant_id, request_key)
```

**transactions_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (id)
```

**transactions_positive_amount** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (amount_minor > 0)
```

**transactions_request_key_not_blank** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (length(btrim(request_key::text)) > 0)
```

**transactions_request_key_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL request_key
```

**transactions_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX transactions_merchant_request_unique ON paymesh.transactions USING btree (merchant_id, request_key);
```

```sql
CREATE UNIQUE INDEX transactions_pkey ON paymesh.transactions USING btree (id);
```

## webhook_deliveries

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| delivery_id | uuid | True | `gen_random_uuid()` |
| event_id | uuid | True | `—` |
| endpoint_id | uuid | True | `—` |
| destination_url_snapshot | character varying(2000) | True | `—` |
| status | character varying(40) | True | `—` |
| attempt_count | integer | True | `0` |
| next_attempt_at | timestamp with time zone | False | `—` |
| created_at | timestamp with time zone | True | `now()` |
| delivered_at | timestamp with time zone | False | `—` |

### Constraints

**webhook_deliveries_attempt_count_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (attempt_count >= 0)
```

**webhook_deliveries_attempt_count_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL attempt_count
```

**webhook_deliveries_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**webhook_deliveries_delivery_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL delivery_id
```

**webhook_deliveries_destination_url_snapshot_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL destination_url_snapshot
```

**webhook_deliveries_endpoint_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (endpoint_id) REFERENCES paymesh.webhook_endpoints(endpoint_id)
```

**webhook_deliveries_endpoint_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL endpoint_id
```

**webhook_deliveries_event_id_endpoint_id_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (event_id, endpoint_id)
```

**webhook_deliveries_event_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (event_id) REFERENCES paymesh.outbox_events(event_id)
```

**webhook_deliveries_event_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL event_id
```

**webhook_deliveries_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (delivery_id)
```

**webhook_deliveries_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

### Indexes

```sql
CREATE UNIQUE INDEX webhook_deliveries_event_id_endpoint_id_key ON paymesh.webhook_deliveries USING btree (event_id, endpoint_id);
```

```sql
CREATE UNIQUE INDEX webhook_deliveries_pkey ON paymesh.webhook_deliveries USING btree (delivery_id);
```

```sql
CREATE INDEX webhook_deliveries_retry_idx ON paymesh.webhook_deliveries USING btree (status, next_attempt_at);
```

## webhook_delivery_attempts

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| delivery_attempt_id | uuid | True | `gen_random_uuid()` |
| delivery_id | uuid | True | `—` |
| attempt_number | integer | True | `—` |
| http_status | integer | False | `—` |
| error_code | character varying(100) | False | `—` |
| started_at | timestamp with time zone | True | `now()` |
| finished_at | timestamp with time zone | False | `—` |

### Constraints

**webhook_delivery_attempts_attempt_number_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (attempt_number > 0)
```

**webhook_delivery_attempts_attempt_number_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL attempt_number
```

**webhook_delivery_attempts_delivery_attempt_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL delivery_attempt_id
```

**webhook_delivery_attempts_delivery_id_attempt_number_key** — validated: True; deferrable: False; initially deferred: False.

```sql
UNIQUE (delivery_id, attempt_number)
```

**webhook_delivery_attempts_delivery_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (delivery_id) REFERENCES paymesh.webhook_deliveries(delivery_id)
```

**webhook_delivery_attempts_delivery_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL delivery_id
```

**webhook_delivery_attempts_http_status_check** — validated: True; deferrable: False; initially deferred: False.

```sql
CHECK (http_status >= 100 AND http_status <= 599)
```

**webhook_delivery_attempts_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (delivery_attempt_id)
```

**webhook_delivery_attempts_started_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL started_at
```

### Indexes

```sql
CREATE UNIQUE INDEX webhook_delivery_attempts_delivery_id_attempt_number_key ON paymesh.webhook_delivery_attempts USING btree (delivery_id, attempt_number);
```

```sql
CREATE UNIQUE INDEX webhook_delivery_attempts_pkey ON paymesh.webhook_delivery_attempts USING btree (delivery_attempt_id);
```

## webhook_endpoints

### Columns and defaults

| Column | Type | Not null | Default |
|---|---|---|---|
| endpoint_id | uuid | True | `gen_random_uuid()` |
| merchant_id | uuid | True | `—` |
| url | character varying(2000) | True | `—` |
| signing_secret_reference | character varying(500) | True | `—` |
| status | character varying(30) | True | `—` |
| created_at | timestamp with time zone | True | `now()` |

### Constraints

**webhook_endpoints_created_at_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL created_at
```

**webhook_endpoints_endpoint_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL endpoint_id
```

**webhook_endpoints_merchant_id_fkey** — validated: True; deferrable: False; initially deferred: False.

```sql
FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id)
```

**webhook_endpoints_merchant_id_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL merchant_id
```

**webhook_endpoints_pkey** — validated: True; deferrable: False; initially deferred: False.

```sql
PRIMARY KEY (endpoint_id)
```

**webhook_endpoints_signing_secret_reference_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL signing_secret_reference
```

**webhook_endpoints_status_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL status
```

**webhook_endpoints_url_not_null** — validated: True; deferrable: False; initially deferred: False.

```sql
NOT NULL url
```

### Indexes

```sql
CREATE INDEX webhook_endpoints_merchant_idx ON paymesh.webhook_endpoints USING btree (merchant_id);
```

```sql
CREATE UNIQUE INDEX webhook_endpoints_pkey ON paymesh.webhook_endpoints USING btree (endpoint_id);
```
