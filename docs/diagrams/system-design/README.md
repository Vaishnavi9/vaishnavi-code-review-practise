# System design

Start with the business responsibilities, then examine the technology choices.

1. [Business-service diagram](01-business-service-map.md)
2. [AWS placement diagram](02-aws-service-map.md)

Location: `docs/diagrams/system-design` inside the code-review practice project.

The business diagram embeds a black-and-white SVG that can be opened separately and enlarged. Its original Mermaid connections are retained in `01-business-service-map.mmd`. The AWS placement diagram uses Mermaid preview. These are generic learning designs; they do not describe an existing company's internal architecture or deployed infrastructure.

Explanations: [business responsibilities](01-business-service-map-explanation.md) · [AWS mapping](02-aws-service-map-explanation.md).

[Short responsibilities and connections for every block](03-block-responsibilities.md).

## Concept learning order

[Numbered black-and-white concept diagram](04-backend-learning-map.md) · [Topic index and learning guide](04-backend-learning-guide.md). Backend and database correctness first; deployment last.

## Database correctness and production problems

- [Verified PayMesh ERD, constraints, indexes and schema SQL](database-schema/README.md)
- [41 production database scenarios with wrong and corrected code](database-production-problems/README.md)
- [Executed checks and remaining verification limits](database-production-problems/VERIFICATION.md)
- [Commit, rollback, savepoints and flush diagrams](rollback/README.md)
- [General system-design fundamentals](05-system-design-fundamentals.md)
- [Load balancer](load-balancer-elastic-load-balancer/README.md)
- [Database learning prompts](../../learning-prompts/database-study/README.md)
