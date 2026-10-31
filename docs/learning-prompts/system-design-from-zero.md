# System design from zero: TinyURL to a generic payment platform

Reusable study prompt. Updated 31 October 2026. This builds on the existing production-lab prompt, preserving its evidence and adding the current learner questions.


Prepared 31 October 2026. Recheck project state and version-sensitive claims when reused.

Act as a principal payments architect, senior Java/Spring engineer, database engineer, site reliability engineer and demanding but beginner-friendly interview coach.

Help me understand and defend a generic payment platform through my existing PayMesh learning project. Teach mechanisms, not a catalogue of products. Define unfamiliar terms and every acronym before using them. Start with one coherent design, explain its weaknesses, then introduce alternatives only when a requirement justifies them.

My purpose is local learning and interview preparation, not cloud deployment. Produce an evidence-based architecture workbook and teach one story at a time. Do not build every proposed service merely because its name appears below. Use synthetic payments only. Do not promise mastery or interview success.

LEARNING BLOCKS — FOLLOW THIS ORDER

1. Request journey: client, DNS, HTTPS, load balancer, gateway, application instance and database.
2. TinyURL: creation, lookup, redirect, persistence, caching and expiration.
3. Identity and hashing: encoding versus hashing, random identifiers, collision handling and consistent hashing.
4. Database design: access patterns, keys, relationships, constraints, indexes, transactions and concurrency; compare PostgreSQL, DynamoDB and OpenSearch.
5. Scaling: multiple instances, pools, replicas, partitions, sharding, hot keys, admission and capacity limits.
6. Payment correctness: merchant-scoped authorization, payment states, idempotency, outbox/inbox, provider uncertainty and reconciliation.
7. Security: credentials, authorization, workload identity, transport/storage protection, webhooks, abuse and audit.
8. Operations: deployments, graceful shutdown, observability, tests, recovery and design trade-offs.

For tomorrow's preparation, favour depth in blocks 1, 4, 6 and 7 after a short TinyURL example. Use blocks 3, 5 and 8 to defend alternatives. Do not promise to cover everything or guarantee interview success. Finish with one unfamiliar design exercise and a verbal review of one small Java method. Treat this as a proposed study order, not confirmed interview content.

BEGINNER BRIDGE: TINYURL BEFORE PAYMENTS

Requirements first: who creates links, public or private redirects, custom aliases, expiration, deletion, editability, expected create/read rates, acceptable latency, retention, availability and abuse model. Clearly mark unknowns and hypothetical numbers. Do not quietly equate a million users with a million simultaneous requests.

Explain two operations separately:
- Create: authenticated/limited client sends a long URL; validate it, allocate a short code, atomically reserve it in a durable store, return the short URL only after the required durable write.
- Redirect: client requests the short code; find the active mapping, return the long URL in an HTTP Location response with an appropriate redirect status; the browser then makes a new request to the destination. The shortener normally does not fetch the destination page or proxy all its contents.

Start with one application and one database. Add a cache only after identifying the read requirement. Add a load balancer and second instance to explain distribution and health checks. Define DNS versus load balancing versus application routing versus API gateway policy. Explain TLS termination and why trusted identity context must be protected. A gateway need not be a custom microservice.

Use separate small diagrams for:
A. Creation sequence including uniqueness conflict and retry.
B. Redirect sequence including cache miss, expired link and not found.
C. Data model: link ID, unique short code, target URL, owner, timestamps, status and expiration.
D. Two instances racing to reserve one code.
E. Cache freshness and an edit/delete race.
F. Read replicas and read-after-create lag.
G. Optional shard placement after one database becomes a measured bottleneck.

Choose redirect status by permanence, caching and method semantics. Do not blindly claim permanent redirects are always best for mutable or revocable links. Define the timestamp/clock assumptions for expiration, cleanup lag and soft deletion. Show a key lookup and unique insert as pseudocode, not application changes. Discuss cache-negative entries and how they can hide a newly created mapping. A popular single code can remain a hot key despite many shards.

HASHING: DO NOT MIX THESE FIVE JOBS

Explain each with a small input/output example and a collision/failure case:
1. Base62 encoding represents a number using letters/digits; it is not encryption or a cryptographic hash. A unique allocated counter encoded in Base62 remains unique if the encoding is injective, but distributed allocation and predictable/enumerable IDs require design.
2. Random short-code generation assigns an identifier. Use an appropriate secure random generator when unpredictability matters, plus a database unique constraint/conditional write and bounded retries. Randomness alone is not proof of uniqueness. A public URL is not an authorization system.
3. Hashing a long URL gives a deterministic digest. Truncation can collide; it does not reconstruct the original URL and does not eliminate a lookup store. Explain canonicalization, fragments/query parameters, privacy, per-owner deduplication and why two users may intentionally want different short codes for the same destination.
4. A hash table uses a hash to find a bucket and resolves collisions through equality checks/its data structure. This is a process-local lookup mechanism, not durable distributed storage.
5. Consistent hashing assigns keys to changing storage/cache owners with limited remapping. It neither creates short codes nor guarantees payment atomicity. Compare modulo hashing, a ring with virtual nodes and rendezvous hashing conceptually; label each as a general design alternative, not a verified internal routing algorithm.

Separately distinguish cryptographic integrity checks, HMAC/signatures and password hashing. Hashing is not encryption; a fast unsalted hash is not a suitable password-storage scheme. Use verified security guidance rather than inventing cryptography. Do not use payment secrets in example hashes or logs.

For a Base62 code of length L, explain keyspace K = 62^L. For n independent uniform random draws with n much smaller than K, expected colliding pairs are approximately n(n-1)/(2K); the probability of at least one collision is approximately 1-exp(-n(n-1)/(2K)). State assumptions. Distinguish observed/generated candidates from successfully reserved keys; retries handle collisions and also consume capacity. Choose length from expected lifetime volume and security requirements, not a universal magic number.

Compare three short-code choices in a decision table: allocated ID + Base62, secure random code + atomic unique reservation, and URL digest prefix + collision handling. Include write coordination, enumeration, repeat submissions, code length, portability and failure recovery. Recommend one only after the requirements justify it. Custom aliases still need atomic uniqueness and an ownership policy.

SECURITY THROUGH THE SAME TWO STORIES

For TinyURL, threat-model malicious destinations, phishing, enumeration, ownership bypass, exhausted creation quotas and a compromised account. Restrict allowed URL schemes and validate syntax without pretending syntax validation proves the destination is safe. If preview/unfurl/URL-scanning workers fetch user URLs, introduce SSRF controls: network isolation, destination policy, redirect and DNS rebinding checks, bounded fetch sizes/timeouts and no access to internal metadata endpoints. Do not introduce a fetching service just to demonstrate a tool.

For payments, reuse the identity/authorization/race reasoning but raise the invariant: another merchant cannot read or mutate my payment; duplicate delivery cannot cause a second financial effect; concurrent reservations cannot overspend; unknown outcomes must not be guessed. Explain what TLS, IAM and encryption do and which application bugs they cannot prevent. Keep audit evidence separate from telemetry and redact secrets/personal data.

Transfer table: short-code uniqueness -> merchant-scoped payment-operation identity; URL mapping persistence -> durable acceptance; read cache -> status projection; alias race -> duplicate-request race; redirect destination -> external provider boundary. Explain where the analogy stops: redirecting a browser is not an irreversible movement of money, so payment recovery needs stronger business rules.

AWS INTERVIEW PRACTICE, NOT A CLAIM ABOUT QUESTIONS THEY WILL ASK

Proposed learning technologies: EKS, DynamoDB, Kinesis and OpenSearch, alongside Java/Spring Boot, Datadog and Terraform. Learn what each does, why a requirement might justify it, one failure mode, the ownership boundary and one simpler alternative. IAM, VPC, load balancing, TLS, secrets and monitoring support the proposed deployment. These are curriculum choices, not verified interview requirements.

Practice questions:
- What changes when one Spring application becomes ten pods, and what remains limited downstream?
- How do partition/sort keys and conditional writes protect one payment decision in DynamoDB?
- What does a Kinesis consumer checkpoint mean after its database write but before the checkpoint succeeds?
- Why can OpenSearch be stale, and which decisions must not trust it?
- How does a pod obtain a limited AWS identity without embedded long-lived keys?
- How do we stop polling and drain work safely before scale-down?
- Which signal distinguishes provider slowness from database pool exhaustion?

These are original practice questions, not leaked, promised or verified interview questions. Use a mock 60-minute design session only as a practice format: requirements 8 minutes, API/data 10, core flow 12, scale/failures/security 20, trade-offs and recap 10. Adapt to the interviewer's direction and the learner's weak points.

0. CURRENT LEARNING PRIORITY — DESIGN FIRST, HANDS-ON LATER

Teach me as a beginner preparing for a senior Java/backend interview. Prepare the reference material in depth, but discuss one mechanism at a time, slowly, with one comprehension question. Do not begin implementation or run infrastructure under this prompt. Do not assign interview dates or formats to dates without confirmation.

My active beginner project is /Users/vaishnavidhanwade/Desktop/vaishnavi-code-review-practise. The separate paymesh-production-lab below is a larger comparison lab, not the same application. Inspect and label them separately. In the beginner project the current service constructs an entity and calls a narrow repository; it is not a complete payment platform. Its AWS dependencies are libraries, not evidence of deployed or authenticated services. Its local PostgreSQL table currently has a merchant-and-request-key unique constraint. A broader idempotency identity is a future proposal.

Status, request-identity and database-comparison diagrams are planned companion lessons. Do not claim those files are delivered or reviewed unless they actually exist. Start with the block order below.

Begin with the request journey and TinyURL. After the basics, explain the status and identity of one payment, then show how two application instances coordinate correctly and examine database scaling. Do not start with a catalogue of technologies.

DESIGN AND EVIDENCE BOUNDARY

This is a generic learning system. Technology choices and service boundaries are proposals. Public API contracts do not reveal internal databases or deployment topology. Do not infer production traffic or implementation from product names. Verify product guarantees with official technical documentation and label untested design assumptions.

STORY A — WHICH PAYMENT METHODS CAN THIS CUSTOMER USE?

Use a synthetic merchant established in country A and a consumer resident in country C. First define merchant legal domicile, consumer residence, billing country, payment-method market, processing currency, consumer currency and settlement currency. They are different dimensions. An IP address alone does not establish eligibility or legal residence.

As a proposed PayMesh mechanism, filter a versioned method-capability catalogue against the authenticated merchant's active configuration/enrollment, consumer market, currencies, amount limits, recurring/capture/refund needs and supported authentication flows. Apply relevant compliance/risk restrictions and explain who supplies them; do not invent regulatory rules. Show the reason a method is included or excluded. Use a hypothetical local method available for consumers in country C paying its supported currency, conditional on merchant eligibility. Do not infer that every merchant in country A can serve every consumer in C.

Explain fast lookup using preloaded/indexed capability data and a bounded cache. Record configuration version used for the decision, recheck critical eligibility on acceptance, and define revocation freshness. Do not discover providers by making arbitrary live requests to every provider for each checkout. Provider selection is a separate proposed responsibility from shopper method selection: capability, agreed corridor, contract, health, quota, routing policy and settlement constraints. Do not switch to another provider blindly after an ambiguous submission; that risks two financial effects.

Teaching assumption: eligibility rules are synthetic until verified against a selected integration contract.

STORY B — ONE LOGICAL OPERATION, MANY NETWORK ATTEMPTS

Define our synthetic charge states explicitly and label them as proposed. When discussing an external API, use its documented states and identify the contract separately. Keep charge, authorization, capture, refund and settlement states distinct. Show conditional capture, partial operations, unknown outcomes and why a failed refund is not necessarily a failed charge. Mark incomplete transition coverage rather than fabricating edges.

Distinguish returned payment-charge ID, merchant business reference, per-operation idempotency key, per-attempt tracing reference, provider instruction identity and internal event ID. Show their lifetimes and who creates each. Explain what happens on simultaneous identical requests and changed payload under the same key. A public retry header does not reveal an internal database composite key; define our own proposed identity scope explicitly.

For our proposed design compare unique (merchant, operation scope, request key) plus a canonical payload fingerprint and original receipt, with the narrower current practice-table key. Illustrate two pods racing to claim the key using a database constraint/conditional write. Explain retention expiry, failed claims, unknown commits and retries after key expiry. Do not claim a local synchronized method or distributed cache alone guarantees payment uniqueness.

Contract status: the learning API is synthetic. Provider-specific retry, status and authentication contracts must be verified before any real integration.

STORY C — SCALE THE APPLICATION WITHOUT BREAKING THE DATABASE RULE

Begin with two stateless application instances and one authoritative store. Show each JVM's separate heap, Hibernate SessionFactory and bounded connection pool; each transaction's separate EntityManager/persistence context and pending action queue. Hibernate is a library in each application, not a shared remote database server. Flush synchronizes that persistence context, not other processes; commit/rollback remain separate. Do not share EntityManagers across threads. Identify exactly where uniqueness, locks/conditional updates, versions and short transactions protect the invariant across instances.

Explain four separate choices: larger database machine, read replicas, table partitioning within a database, and sharding across owners. Read replicas may lag and do not automatically distribute writes. Native PostgreSQL hash partitioning is not a self-managing multi-server consistent-hash ring. Consistent hashing helps place/remap keys; it does not itself supply atomicity, replication, conflict resolution, failover or a global unique constraint. A hot merchant/key can remain hot. Explain resharding ownership, fencing, temporary routing versions and cross-shard transactions before proposing sharding for money.

Amazon DynamoDB is AWS-managed; DynamoDB Local is a development/test tool. Model partition and sort keys, conditional writes, transaction scope, read consistency, indexes, hot keys, throttling and retries using AWS's current documentation. Do not claim current DynamoDB internals match the original Dynamo paper. PostgreSQL, MongoDB and DynamoDB are not interchangeable just because each can store JSON.

OpenSearch is search/analytics software; Amazon OpenSearch Service is the managed offering. Propose it as a derived search view with duplicate-safe, version-aware updates and measurable lag. Absence in search is not proof of absent acceptance; do not authorize debits from search results. Compare a simpler database index first. Explain how the projection is rebuilt and what retention/backfill evidence makes that possible.

AUTHENTICATION AND AUTHORIZATION

Separate merchant API authentication, merchant/resource authorization, consumer payment authentication, workload IAM and operator access. Explain API-key Bearer authentication separately from OAuth access tokens; a Java security starter alone does not establish the configured authentication scheme. For proposed OAuth/JWT alternatives, explain issuer/audience/signature/expiry/scopes and tenant checks. Header values and resource IDs are not permission grants. Service-to-service calls require scoped identities; an API gateway must not be the only tenant enforcement point. Use placeholders, redacted logs and least privilege. Keep root and broad admin roles out of application runtime.

DELIVERY CONTRACT

Produce one indexed local workbook under the active project's docs area, with one concept per Markdown document, one original diagram and a small labelled snippet where useful. Separate diagrams for state, sequence, ER relationships, deployment and data placement. Do not mix arrows with incompatible meanings. Include a file/source inventory with checked date and status: implemented, configured, tested under stated conditions, proposed or unknown. A configured dashboard or successful unit build does not prove the end-to-end system is running.

Preserve current files and private settings. No credential copying, cloud deployment, source implementation, database mutation, publishing or load tests are authorized by this study prompt. A later explicit hands-on request can authorize a small concrete exercise. The broader material below is a reference specification, not permission to skip the first story or begin all services at once.

1. INSPECT REALITY BEFORE DESIGNING

Primary project:
/Users/vaishnavidhanwade/Desktop/paymesh-production-lab

Inspect settings.gradle, build.gradle, relevant source, test source, existing test reports and these references:
- aws/SERVICE-CATALOG.md and aws/architecture/service-catalog.json
- aws/README.md, aws/LEARNING-GUIDE.md and aws/API-COMPARISON.md
- aws/VERIFICATION.md and aws/evidence/readiness-register.json
- aws/evidence/local-verification-2026-10-31.json
- docs/architecture.md, docs/observability.md, docs/correctness.md and docs/failure-drills.md
- docs/diagrams/abc-global-platform-map/course-guide.md and course-references.json
- contracts/http/openapi.yaml and contracts/events/
- aws/GRADLE-DEBUGGING.md

Additional visual learning references:
/Users/vaishnavidhanwade/Desktop/paymesh-spring-aws-lab/docs/diagrams/system-database-design
/Users/vaishnavidhanwade/Desktop/paymesh-spring-aws-lab/docs/diagrams/thread-safety-jvm-databases

Read configuration keys and sanitized templates without exposing credentials or private connection strings. Do not print .env, tokens, passwords or Terraform state. Do not modify backend source, dependencies, application properties, credentials or the interview assessment repository. Do not commit or push. Read-only inspection and original learning artifacts are the default; propose experiments before executing them.

Known evidence, not a promise about the current runtime:
- On 31 October the Java 25 / Gradle 9.5.1 full local build passed 61 tests, zero failures/errors/skips, with DynamoDB Local enabled.
- Mocked AWS clients do not establish real SNS, SQS, Kinesis or OpenSearch behavior.
- The same day's runtime preflight found the Docker filesystem full, all three Kafka brokers exited, Zipkin stopped and five application health endpoints reporting DOWN. End-to-end testing was not rerun. Recheck before describing the runtime as healthy.
- Do not stress a full disk, delete volumes, reset broker metadata or recreate topics to hide a failed durability claim.
- No application stack was deployed to AWS. Earlier deployment instructions are reference material; my current local-only instruction takes precedence.

Build an evidence matrix: capability | source location | implementation status | latest executed evidence/date | local real dependency or test double | remaining gap. Use distinct labels: proposed; configured; implemented; locally tested; integration-tested; unverified. Never convert a dependency, successful compilation, healthy process or generated diagram into proof of an end-to-end feature.

2. USE MY SCALER MATERIAL HONESTLY

Use the recorded course ledger first. Inspect exact accessible lessons or notes when useful. If authentication has expired, ask me to sign in without sharing credentials and continue with existing mappings and official sources. Do not claim to have watched recordings that were not inspected or reproduce course slides/transcripts. Create original explanations and diagrams.

Map these Scaler references to specific PayMesh questions:
- HLD curriculum: https://www.scaler.com/academy/mentee-dashboard/core-curriculum/m/8/classes
- HLD basics / consistent hashing, class 43703: https://www.scaler.com/academy/mentee-dashboard/class/43703 — key placement, adding nodes and hot keys.
- Caching, 43708 and 43720: https://www.scaler.com/academy/mentee-dashboard/class/43708 and https://www.scaler.com/academy/mentee-dashboard/class/43720 — stale status, invalidation races, stampedes and TTL.
- CAP and primary/replica replication, 43731: https://www.scaler.com/academy/mentee-dashboard/class/43731 — partition behavior, replica lag and correctness-sensitive reads.
- SQL versus NoSQL, 43743 and 43767: https://www.scaler.com/academy/mentee-dashboard/class/43743 and https://www.scaler.com/academy/mentee-dashboard/class/43767 — choose by access patterns, transactions and invariants.
- Messaging, 43788 and 51977: https://www.scaler.com/academy/mentee-dashboard/class/43788 and https://www.scaler.com/academy/mentee-dashboard/class/51977 — queues, fan-out, coupling and backpressure.
- Kafka, 43799 and 51987: https://www.scaler.com/academy/mentee-dashboard/class/43799 and https://www.scaler.com/academy/mentee-dashboard/class/51987 — partitions, replication, offsets, replay and consumer failures. Treat historical ZooKeeper setup separately from current Kafka/KRaft guidance.
- Object storage, 43819: https://www.scaler.com/academy/mentee-dashboard/class/43819 — reports and retained exports; spatial indexing is not a prerequisite here.
- Schema design, 34093 and 40097: https://www.scaler.com/academy/mentee-dashboard/class/34093 and https://www.scaler.com/academy/mentee-dashboard/class/40097 — entities, keys, relationships, constraints and access paths.
- Transactions, 32896: https://www.scaler.com/academy/mentee-dashboard/class/32896 — atomicity, isolation and concurrent reservations.
- Concurrency, 34100, and synchronization, 35427: https://www.scaler.com/academy/mentee-dashboard/class/34100 and https://www.scaler.com/academy/mentee-dashboard/class/35427 — shared state, visibility and coordination.

The saved ledger records curriculum inspection for most HLD references and selected notes for 43799, not a complete review of those videos. Record any new inspection separately with date and depth: curriculum only, selected notes, transcript excerpt or specified recording segment.

Supplement with the existing Udemy mapping for Software Architecture & Design of Modern Large Scale Systems. Its performance lecture 8 and scalability lecture 9 have previously inspected visible automatic transcripts, not complete video reviews:
https://www.udemy.com/course/software-architecture-design-of-modern-large-scale-systems/learn/lecture/28196346
https://www.udemy.com/course/software-architecture-design-of-modern-large-scale-systems/learn/lecture/28196360

For every learning topic provide: exact course reference | inspected depth | original explanation | official technical reference | PayMesh file/flow | independent exercise. Correct outdated material respectfully using version-matched primary documentation.

3. KEEP PUBLIC FACTS, DESIGN CHOICES AND ASSUMPTIONS SEPARATE

Use three visible labels throughout:
- Verified product behavior — cite the exact official technical page and inspected version.
- Proposed PayMesh design — our architecture, ownership and implementation choices.
- Hypothetical teaching assumption — invented workload, latency, quota or failure conditions.

Use official technical documentation for platform guarantees. Our synthetic API is not automatically compatible with any external payment API. Do not infer internal architecture or traffic from public APIs.

Verify technical guarantees against current, version-relevant Java, Spring, PostgreSQL, Kafka, AWS and Kubernetes documentation. Useful starting points:
https://docs.oracle.com/en/java/javase/25/docs/api/
https://docs.spring.io/spring-framework/reference/
https://www.postgresql.org/docs/current/
https://kafka.apache.org/documentation/
https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TransactWriteItems.html
https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html
https://docs.aws.amazon.com/streams/latest/dev/key-concepts.html
https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/
https://opentelemetry.io/docs/concepts/signals/

4. EXPLAIN THE BUSINESS AND IDENTIFY THE RESPONSIBILITIES

Introduce consumer, merchant, payment service provider, platform and external payment provider. Trace one fictional EUR 19.99 payment. Separate API messages, recorded financial obligations and movement of funds. Define payment intent/request versus provider attempt; authentication, authorization, capture, settlement and payout; pending, failed, successful and unknown outcomes. Explain which lifecycle steps vary by payment method.

Inventory all 25 responsibilities already identified, then suggest additional ones only when a concrete requirement is missing:
1. API gateway and admission control.
2. Merchant identity, configuration and entitlements.
3. Payment orchestration and authoritative state.
4. Fraud and risk decisions.
5. Provider routing and eligibility.
6. Provider submission and connectors.
7. Incoming provider webhook receipt and processing.
8. Refund processing and reservations.
9. Ledger and financial postings.
10. Cashflow and liquidity.
11. Settlement tracking.
12. Merchant payout execution.
13. Reconciliation and exception handling.
14. Fees and pricing.
15. Foreign exchange and quote validity.
16. Merchant notifications and outgoing webhooks.
17. Status, cache and search projections.
18. Analytics.
19. Merchant and financial reporting.
20. Payment instruments and token references.
21. Recurring agreements and scheduling.
22. Disputes and chargeback cases where applicable.
23. Operations cases and audit.
24. Onboarding and compliance integration.
25. Synthetic provider for controlled learning failures.

Do not equate 25 responsibilities with 25 microservices. Classify each as an existing application, shared library, module within an owner, justified future service, external system or deferred requirement. Keep observability, identity infrastructure, secrets, deployment automation and backups separate from business-service counting.

For each responsibility state: customer need; owned data and source of truth; inputs/outputs with a small contract example; synchronous/asynchronous path; transaction boundary; invariant; concurrency and idempotency rule; retry/timeout behavior; authorization boundary; peak bottleneck; key metric and first useful alert; implementation evidence; simpler alternative; extraction trigger.

Recommend a minimal baseline before the target architecture. Compare a modular monolith, ports-and-adapters structure and microservices. Explain boundaries using ownership, failure isolation and measured scaling needs. Explain SOLID principles and patterns only where they simplify a concrete change or protect a rule. Avoid interfaces, factories and extra processes without a reason.

5. ANCHOR THE DESIGN IN THE CURRENT CODE

The selected learning path has api-gateway, aws-payments, aws-delivery, aws-provider and aws-insights. Verify their source before describing behavior. aws-support is a library. The Kafka/PostgreSQL comparison uses payment-service, provider-worker, provider-simulator and status-projection plus the shared gateway; contracts and lab-support are libraries.

Explain the selected proposed flow:
merchant → gateway → payments → atomic payment/request/outbox persistence → outbox relay → SNS/SQS → delivery → synthetic provider → outcome publication → payment state and insights → Kinesis → search projection.

Show caches as derived views, not authorities. Distinguish the application flow from deployment plans. Kinesis serves retained streaming; SQS serves work delivery. Explain why each is present and whether a simpler design could omit one. Kafka is a separate comparison, not silently renamed as Kinesis. Do not put every broker into the same flow to tick technology boxes.

6. DRAW THE MECHANISMS PROGRESSIVELY

Produce original, readable diagrams in this order:
A. System context: people, PayMesh and external systems.
B. Current implemented components and owned stores.
C. Proposed extensions, visibly marked planned.
D. Payment acceptance sequence with transaction and acknowledgement boundaries.
E. Duplicate/concurrent acceptance and unknown-provider-outcome sequences.
F. Entity relationships, key/index choices and state transitions.
G. Peak load, rejection, queue growth and recovery.
H. Telemetry flow and safe shutdown/recovery.

Use Mermaid where suitable or the existing SVG/React renderer. Match the pale background, dotted grid, large original icons, faint containers, readable labels and restrained blue/teal/amber/red palette. Pair color with text and symbols. Keep relationship diagrams separate from runtime calls. Label synchronous calls, asynchronous messages, transaction/trust boundaries, ownership and source of truth.

For animations show one deterministic event at a time: before-state, actor/thread, operation, durable write, response/acknowledgement and after-state. Moving arrowheads follow the actual direction. Playback speed is not a performance measurement. Include pause, reduced motion and readable static snapshots. Never draw 202 Accepted as money movement.

7. FOLLOW THE FAILURE WINDOWS AND DATABASE RULES

Walk through normal acceptance, customer redirect/authentication, lost merchant response, concurrent identical requests on two instances, changed payload with reused key, provider response loss, duplicate/out-of-order webhooks, concurrent refunds, worker crash and reconciliation.

At every step name the executing service/thread, database owner/connection, transaction, locks or conditional write, durable state, message identity, response, retry behavior and what the merchant sees.

Explain amount plus currency, minor units versus decimal calculations, explicit rounding, overflow, uniqueness, foreign keys, normalization, historical snapshots, joins, composite indexes, query plans and stable keyset pagination. Compare PostgreSQL and DynamoDB using access patterns and invariants, including the costs of scans, secondary indexes and transactions. Do not import SQL isolation terminology blindly into DynamoDB guarantees.

Keep database atomicity, isolation and durability distinct. Demonstrate lost updates and concurrent refund reservation. Separate a ledger invariant from a payment status. Define pending reservations and unknown refund results so concurrent requests cannot cumulatively over-refund.

Explain merchant-scoped API idempotency, request fingerprints and original receipts; consumer deduplication/version rules; and stable provider instruction identity as separate safeguards. Explain idempotency expiry and replay after retention. An outbox makes the local acceptance/handoff atomic, not the external provider effect exactly once. Explain Kafka transaction scope separately from external database/provider effects.

For incoming webhooks: verify authenticity, durably receive, acknowledge, deduplicate and process. Analyse crashes before persistence, after persistence before acknowledgement and after effect before completion marking. Treat stale events as old evidence, not permission to regress state.

8. CONNECT SCALING TO JAVA AND SPRING CONCURRENCY

Identify shared state in singleton beans; request-local state; safe publication; atomicity, visibility and happens-before; volatile versus compound updates; ConcurrentHashMap versus mutable values; atomic counters versus metrics; locks, semaphores, executor queues and interruption.

Show why a process-local lock does not coordinate two instances. Explain bounded concurrency versus requests-per-second quotas. Include connection ownership, transaction duration and avoiding network calls while holding database locks. Compare platform and virtual threads without claiming more threads create more downstream capacity.

Use one small bad-versus-good example per current story. Require coordinated race tests using latches/barriers, bounded waits, worker-error propagation and cleanup. A passing sequential test or lucky thread schedule is not thread-safety evidence. Explain why parallel streams and their shared pool may be inappropriate for blocking payment calls.

9. CALCULATE CAPACITY WITH EXPLICIT HYPOTHETICAL ASSUMPTIONS

Use these teaching inputs, never as measured production traffic:
- 200 new logical payments/second normally.
- 2,000/second for one 15-minute daily peak; 200/second for the remaining 23 hours 45 minutes.
- Separate flash test: 5,000/second for 60 seconds; do not silently add it to the daily model.
- Four status reads per new payment; three internal event records per payment; average event 2 KiB.
- Seven days event retention. Kafka comparison replication factor three; do not apply a user-configured replication factor to Kinesis billing/storage.
- Mean API acceptance latency 200 ms; proposed p95 acceptance target below 500 ms. Completion time is a different measurement.
- Eight concurrent provider calls per worker; mean call latency 200 ms normally and two seconds when degraded.
- One provider receives 30% of payments and allows 300 submission calls/second across the platform.
- Initial worker sizing target: no more than 70% utilization.

State missing assumptions: payload distribution, retries, decline rate, database item/row size, polling timing, tenant/key skew, batch size, retention per stream, deadlines and read traffic during recovery. Start with one submission per logical payment and no retries, then model retry amplification separately. Document which of the three events actually enter each queue/stream before calculating its capacity.

For every formula show units, substitution, result and applicability. Calculate API reads/writes, event rate/bandwidth, daily volume, seven-day raw storage and Kafka replicated storage, then separately estimate indexes, headers, logs, operational headroom and retention overhead. Explain decimal MB versus binary MiB.

Use Little's Law only for a clearly bounded stable system: average in-flight work = arrival rate × mean residence time. Do not use p95 as a mean or assume steady state while backlog grows without bound.

Compute worker throughput/concurrency and ceiling-rounded worker counts at 70% utilization, then cap aggregate provider throughput by its quota. For the constrained provider calculate peak arrivals, backlog growth and recovery with continuing normal arrivals. Distinguish the hard 300/s quota from an optional conservative operating budget; do not count the same headroom twice. Calculate both if comparing policies. State exactly when a backlog cannot drain or violates the payment deadline.

Explain hot keys, partition/shard distribution, consumer parallelism, broker/storage/network capacity, database contention and connection limits. Verify product/version quotas from primary documentation. More instances cannot remove a provider quota, a hot key or exhausted disk.

10. SPECIFY OVERLOAD AND SCALING BEHAVIOR

Answer concretely: What happens to the next payment when the system is full?

Distinguish rejection before durable acceptance, durably queued work and deferred scheduling. Explain 429 for a merchant limit, 503 for temporarily unavailable capacity, and asynchronous acceptance only after the required durable commit. Treat ambiguous post-commit response loss separately. Include Retry-After, stable retry identity, customer expiration, cancellation and fairness.

Define bounded admission, per-merchant protection, worker/connection pools, maximum outstanding work, oldest-message-age limits, retry budgets, capped exponential backoff with jitter, circuit breakers and bulkheads. Specify which correctness checks must never be skipped under pressure.

Compare scheduled scaling for a known peak with reactive scaling. Separate application replicas, cluster/node capacity, database capacity and stream capacity. Explain Kubernetes Horizontal Pod Autoscaler inputs, resource requests/limits, metrics availability, readiness/startup/liveness, scaling delay, stabilization and graceful termination. Compare CPU with queue age, lag and demand signals. Pods are not proof of capacity.

Explain safe scale-down: stop admitting work, stop polling, drain bounded in-flight work, finish/rollback transactions, acknowledge only durable effects, fence leases/checkpoints and allow unfinished work to be redelivered. Explain when scale-to-zero is unsuitable. Describe local stop versus removal versus irreversible data deletion; propose cleanup, never delete data or deploy resources under this prompt.

11. MAKE OBSERVABILITY ANSWER CUSTOMER QUESTIONS

Define logs, metrics, traces and profiles, then distinguish all of them from an immutable financial audit trail and correctness tests. Map the existing Micrometer/Prometheus/Grafana/Zipkin code to actual instrumented boundaries. Discuss OpenTelemetry as an interoperability option; do not claim it is already fully wired.

Define service-level indicators (SLIs), objectives (SLOs), measurement windows and error budgets. Treat proposed thresholds as assumptions. Separate availability, durable acceptance latency, eventual completion, projection freshness and financial correctness. Define how declines, overload rejections and unknown results affect each denominator; do not hide failures by excluding them without justification.

Build four focused dashboard specifications:
- Merchant experience: offered/accepted/rejected rate, latency percentiles, pending age and unknown outcomes.
- Processing: outbox oldest age, queue age/depth, retries, dead letters, provider latency/errors/quota use, stream lag and checkpoint failures.
- Runtime: CPU, JVM heap/garbage collection, threads/executor queues, connection pool waits, locks, disk bytes/inodes, broker health and replica state.
- Correctness/recovery: duplicate-suppression evidence, invalid transitions, stale-event rejection, reconciliation exceptions, projection lag and failed recovery checks.

For each panel give its question, metric type/unit, source, bounded labels, aggregation/window, missing-data behavior, proposed threshold, owner and first useful action. Verify emitted metric names before writing PromQL; otherwise label queries proposed. Do not average per-instance p95 values. Keep request/payment/event IDs out of unbounded metric labels; use redacted structured logs/traces for correlation.

Trace HTTP calls, persisted outbox handoffs and asynchronous workers using explicit context or span links. Thread-local logging context does not automatically cross executors/messages; clear it on completion. Trace IDs are not idempotency keys. Discuss sampling, retention, cardinality, access controls and secret/personal-data redaction.

Use the actual full-Docker-disk incident as the first operations case: symptom → evidence → causal hypothesis → smallest safe repair → data-integrity checks → controlled restart → recovery proof → prevention. An alert or a healthy endpoint alone does not prove no payment was duplicated or lost.

12. DESIGN TESTS THAT CAN DISPROVE THE ARCHITECTURE

Separate unit, coordinated concurrency, real database integration, HTTP/event contract, end-to-end, property-based invariant, security-denial, fault-injection and recovery tests. Inspect existing evidence rather than inventing results. Coverage is a gap-finding tool, not correctness proof.

Compare load, stress, spike, soak and recovery testing. Use k6 for a bounded HTTP arrival workload, JUnit for invariants and Java Flight Recorder/thread dumps for runtime investigation when justified. Explain offered arrival rate versus completed throughput, status polling/retries, dropped iterations, warmup and load-generator limits. A closed-loop client can hide overload by slowing its offered traffic; measure that explicitly.

Specify local-only targets, synthetic data, duration, maximum rate/concurrency, required disk headroom and abort criteria. Do not run load while the current runtime is unhealthy. No test may contact real providers, send notifications to others or change AWS resources without a separate request.

Cover: broker unavailable after database commit; crash after effect before acknowledgement; provider processed but reply lost; duplicate/stale webhook; pool exhaustion; provider ten times slower; hot partition/shard; poison message; cache/replica lag; disk full; node/zone loss; and burst ended but backlog remains.

For each drill give invariant, injection boundary, expected durable records, safe/unsafe retry, detection, first operator action, recovery criterion and what the test still cannot prove. Preserve business/event identities during replay. Distinguish restoring business state from preserving original broker history.

13. SECURITY, RELEASES AND RECOVERY

Explain merchant authentication, tenant authorization, workload identity and human administrator access separately. Review least privilege, secret rotation, Transport Layer Security, network boundaries and administrative endpoint isolation. Do not use root or broad administrator credentials in applications. Existing teaching keys do not constitute production identity.

Describe reproducible Gradle builds, dependency/image checks, contract compatibility, expand-and-contract schema changes, rolling/canary release, graceful shutdown, rollback triggers and data migration limitations. Show which controls exist and which are proposals. Readiness should reflect whether a specific operation can be served; do not make liveness blindly restart every process on a dependency outage.

Define recovery-time and recovery-point objectives per data class. Separate multi-availability-zone resilience from multi-region disaster recovery, replication from backup, and backup existence from tested restoration. Discuss consistency, routing and duplicate-effect risks on regional failover. Keep financial truth and rebuildable projections distinct.

14. DELIVER AND TEACH IN A USEFUL ORDER

Deliver a categorized index, current-versus-target service matrix, original progressive diagrams, contract/schema examples, capacity worksheet, observability/alert specification, failure-drill matrix, prioritized gaps and a staged local learning plan. Link exact source files and course references. Mark examples complete/fragment/pseudocode, required Java version/imports, and executed/unexecuted status. Do not enable preview features silently.

For every lesson use:
customer need → prerequisites/definitions → invariant → diagram → numbered mechanism → small code/SQL example → failure → smallest correction → test evidence → trade-off/alternative → independent variation → closed-book explanation.

Use the same story across Java, Spring, storage and messaging before moving to another one. Start with TinyURL and the request journey; transfer the same reasoning to gateway shared state and admission, atomic acceptance, concurrent duplicates, delivery/uncertainty, projections, capacity and recovery. Include beginner explanations first and senior-level challenges second.

Track learning only by explicit evidence: introduced, practised with help, independently implemented, independently explained or needs practice. An opened lesson, animation, copied snippet or generated passing test is not mastery.

Finish the reference material with a two-minute architecture explanation, a ten-minute walkthrough, ten design/code-review questions clearly labeled practice questions (not actual interview questions), five numerical exercises, five dangerous design mistakes and one small red-green-refactor assignment.

For the first teaching response: present the eight-block learning order below, distinguish proposed learning technologies from confirmed interview requirements, then explain only the journey of one TinyURL request. Show a small original diagram and ask one reasoning question. Wait for my answer. Do not begin the payment service inventory, dump the entire curriculum or implement/deploy services yet.
