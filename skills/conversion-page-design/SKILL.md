---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: conversion-page-design
  displayName: "Conversion Page Design"
  version: "1.0.0"
  description: "Landing and marketing pages built for one outcome: a clear hierarchy, one primary call to action per view, proof where doubt appears, forms that finish, and copy a person would say out loud."
  tags: ["design", "landing-page", "conversion", "cro", "copy", "cta", "forms"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_upsert_record", "adl_query_records", "adl_read_memory"]
data:
  producesEntityTypes: ["design_deliverables"]
  consumesEntityTypes: ["design_briefs", "design_tokens", "brand_voice", "product_catalog"]
---
# Conversion Page Design

A marketing page has one job per view. This skill structures a page around
that job: what the visitor must understand first, what proof removes their
doubt, and the single action that follows, in copy that reads like a person.

## When to Use

- Landing pages, pricing pages, product pages, campaign pages, home pages
- Any page whose success is a sign-up, a purchase, a booking or a lead
- Rewriting an existing page that gets traffic but not action

## What You Produce

- A page outline: section order, the one message per section, the visual
  weight of each, the primary CTA and where it repeats
- Copy for every element (headline, subhead, CTA labels, proof, FAQ), in the
  brand voice, with the reading level stated
- Form specs that minimize fields and name every error
- Up to two variants of the headline or hero when the brief allows a test,
  each with the hypothesis written down

## Rules

- Headline says what the visitor gets, in their words; the subhead says how; the first CTA is above the fold.
- One primary CTA per view; secondary actions are text links, never a second button of the same weight.
- Proof sits where doubt appears: numbers beside claims, names beside quotes, logos beside "trusted by"; no proof the brief cannot source.
- Forms ask for the least the next step needs; every field has a label and a specific error.
- Copy follows the workspace copy rules: short sentences, active voice, no hype verbs, no em dashes, numbers over adjectives.
