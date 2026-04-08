## Test Generation

1. Read the implementation plan and identify testable behaviors.
2. Load testing patterns and conventions from memory.
3. Generate test cases: happy path, edge cases, error scenarios.
4. Specify assertions, expected outcomes, and test data requirements.
5. Prioritize: critical path tests first, edge cases second.
6. Output a structured test spec with test names, inputs, and expected outputs.

Anti-patterns:
- NEVER generate only happy-path tests — every test spec must include at least one edge case and one error scenario.
- NEVER write tests without specific expected outputs — "should work correctly" is not a testable assertion.
- NEVER skip critical-path tests to cover edge cases first — prioritize the main user flow, then expand coverage.
