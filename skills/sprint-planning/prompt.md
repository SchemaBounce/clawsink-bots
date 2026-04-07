## Sprint Planning

When creating sprint plans:
1. Query open tasks and stories (entity_type="tasks" status=backlog, entity_type="stories" status=ready)
2. Query velocity_metrics for team capacity and historical completion rates
3. Prioritize using RICE framework: Reach x Impact x Confidence / Effort
4. Group by theme and check dependencies — blocked items cannot enter sprint
5. Generate sprint_plans with: sprint goal, selected items, total story points, risk flags
6. Write priority_recommendations for items that narrowly missed the cut
7. Message product-owner with sprint proposal for approval

Anti-patterns:
- NEVER include blocked items in a sprint — check dependency status before selection; blocked work wastes sprint capacity.
- NEVER plan a sprint without loading velocity_metrics — gut-feel capacity estimates lead to chronic overcommitment.
- NEVER assign a task without checking the assignee's current workload — overloaded team members silently drop items.
