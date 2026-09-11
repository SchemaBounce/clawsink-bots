---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: ticket-writing
  displayName: "Ticket Writing"
  version: "1.0.0"
  description: "Turns a request into right-sized tickets with checkable acceptance criteria, each finishable alone."
  tags: ["tickets", "planning", "right-sizing", "acceptance-criteria", "backlog"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_upsert_record", "adl_query_records"]
data:
  producesEntityTypes: ["tasks"]
  consumesEntityTypes: ["tasks"]
---

# Ticket Writing

Turns a request, an idea, or a vague ask into tickets that can actually be
finished. The skill decides how many tickets the work is, sizes each one so it
can be completed and verified on its own, and writes acceptance criteria a
reader who did not plan the work could check.

## When to Use

Use it at the front of any workflow where work arrives as prose and has to
become trackable units: intake from a stakeholder, breaking down an epic,
turning a bug report into something assignable, or preparing work for an agent
to pick up.

It pairs with `task-management`, which creates and tracks the tickets once they
are written, and with `implementation-planning`, which takes a single
well-formed ticket and turns it into a file-level plan.

## Why Right-Sizing Is the Job

An oversized ticket fails in a way that is expensive to recover from: the work
is half-done, nothing is verifiable, and the reason it stalled is buried in a
long transcript. A right-sized ticket fails cheaply — one unit is wrong, the
rest still stands.

The test is not effort. It is whether someone picking the ticket up cold, with
no memory of the conversation that produced it, could finish it and know they
were done.

## Acceptance Criteria Are the Deliverable

A ticket without checkable acceptance criteria is a wish. "Tests pass" is not
acceptance criteria — it restates the pipeline instead of describing what
changed. Criteria should name observable behavior: what a user, a caller, or a
query can now do that it could not before.

## Typical Bots

Product owners, tech leads, triage bots, and any bot that receives work from
humans before it reaches an implementer.
