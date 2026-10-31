# Shared fundamentals and domain priorities

The diagram groups reusable concepts into seven blocks. It is a learning sequence, not a network diagram. Security and correctness apply throughout; they must not be deferred until the end.

Start with a concrete use case, actors, scope and non-negotiable rules. Set measurable targets for latency, throughput, availability and recovery. Draw one working request flow before selecting infrastructure.

Different domains place different weights on the same qualities. The domain examples in the diagram are illustrative; video, messaging and inventory systems also require correctness, privacy and resilience.

## Why payment correctness belongs to system design

Suppose the same logical payment reaches instance A, then a retry reaches instance B. Their Java locks and in-memory maps are separate. A lock in A cannot coordinate B.

System design chooses the identity of that operation, where its durable record lives, how concurrent claims are coordinated, and how to recover when an external provider may have acted but its response is lost. Application code and database constraints implement those choices.

A typical proposed design uses a merchant-scoped request identity and database uniqueness for local acceptance. These alone do not prevent an external provider effect from occurring twice. Stable provider request identity, provider-supported duplicate handling and recovery or reconciliation are separate concerns. A timeout may mean an unknown outcome, not a failed payment.

## Suggested next lessons

Finish the load-balancer basics: choosing a destination, health checks, and the distinction between balancer capacity and application scaling. Then study one repeated-payment scenario before expanding to other topics.

For each mechanism ask: what problem does it solve, where does it belong, what can fail, how would we test it, and what alternative would we choose under different requirements?

This is an original conceptual learning guide. No implementation, deployment, performance benchmark or learner understanding is claimed as verified by this document.
