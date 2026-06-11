# STR Property Management Suite: Setup Guide

This guide walks through activating all seven bots, connecting the one integration that matters most (Lodgify), and optionally adding social media publishing.

## What each bot does

| Bot | What it does |
|-----|--------------|
| Property Manager | Reads all specialist findings daily and delivers a single portfolio briefing covering occupancy, revenue, and active alerts |
| Channel Manager | Keeps calendars synchronized across Airbnb, VRBO, Booking.com, and Facebook Marketplace; detects double-booking risks in real time |
| Guest Communicator | Responds to guest messages across all platforms within 15 minutes, sends check-in instructions, and escalates emergencies |
| Dynamic Pricing | Analyzes competitor rates and local demand daily, recommends nightly rate changes, and finds orphan nights to fill with discounts |
| Property Marketer | Writes platform-optimized listing descriptions and social media content drafts; all posts go to Property Manager for approval before publishing |
| Review Manager | Monitors new reviews, drafts host responses, flags 3-star-or-below reviews immediately, and tracks per-property rating trends |
| Turnover Coordinator | Generates cleaning assignments from checkout and check-in pairs, alerts you when a turnover is running late, and logs maintenance issues from cleaner notes |

---

## Step 1: Activate the str-property-management team

In SchemaBounce, go to your workspace and open the Agents section. Find the STR Property Management team in the catalog and click Activate. This deploys all seven bots as agents with the org chart pre-wired: Property Manager at the center, the six specialists reporting to it, and Review Manager nested under Guest Communicator.

After activation, fill in the North Star configuration keys when prompted:

- `property_count` - How many properties are in the portfolio (e.g. `5`)
- `primary_channel` - Your highest-volume booking platform (e.g. `airbnb`)
- `target_occupancy_rate` - Your occupancy goal as a percentage (e.g. `75`)
- `market_type` - The rental market context: `urban`, `beach`, `mountain`, `rural`, or `lake`
- `average_nightly_rate` - Average nightly rate across the portfolio in USD (e.g. `150`)
- `check_in_method` - How guests access properties: `smart_lock`, `lockbox`, or `in_person`
- `cleaning_service` - Cleaning arrangement: `in_house`, `service_company`, or `mixed`
- `booking_channels` - All active platforms as a JSON array (e.g. `["airbnb", "vrbo", "lodgify"]`)

---

## Step 2: Connect Lodgify (the one connection that covers three platforms)

Lodgify is the keystone integration. One Lodgify connection gives the Channel Manager and Guest Communicator access to your Airbnb, VRBO, and Booking.com calendar, bookings, and messaging through Lodgify's channel sync layer.

**Why one connection covers three platforms:** Airbnb, VRBO, and Booking.com do not expose direct account-management APIs to third parties. Lodgify acts as your channel manager for all three; bots interact with those platforms through Lodgify's API rather than directly.

### How to connect Lodgify

1. Log in to your Lodgify account.
2. Go to Settings, then Account, then scroll to Public API.
3. Generate a Public API key if you do not have one.
4. In SchemaBounce, open the Channel Manager agent, go to Connections, and paste the key into the Lodgify field.

Once connected, the Channel Manager can sync calendars, pull bookings, and push rate changes to Airbnb, VRBO, and Booking.com through Lodgify.

### What this gives you immediately

After connecting Lodgify, the Channel Manager begins monitoring your calendar for conflicts every two hours. The Dynamic Pricing bot can read current availability and push approved rate recommendations through the same connection. Guest Communicator uses booking data to personalize check-in messages and time access-code delivery correctly.

**Note on Airbnb direct API:** Airbnb has a public search/listing API for read-only discovery, but no account-management API accessible to third-party tools. VRBO similarly has no public API for account operations. Both are covered through Lodgify's channel sync, not as separate direct connections.

---

## Step 3: Connect social media (optional, marketing-only)

Skip this step if social media posting is not part of your marketing plan. The other six bots run fully without it.

The Property Marketer bot can draft Instagram and Facebook posts showcasing properties, seasonal promotions, and local highlights. After Property Manager approves a draft, Channel Manager publishes it to the connected accounts.

**How social publishing works for STR:** Meta (Instagram and Facebook) requires a Business account and completed App Review before a third-party tool can post content on your behalf. App Review for content-publishing permissions takes multiple business days. Start this process before you need the posts live.

### To connect Instagram Business and Facebook Page

1. In SchemaBounce, go to Connections and connect Composio.
2. Through Composio, link your Instagram Business account and your Facebook Page.
3. Property Marketer will begin generating drafts on its weekly schedule.
4. Drafts land in Property Manager's inbox for review. Nothing publishes without approval.

**What Instagram and Facebook are not marked as required for:** Publishing is approval-gated and optional. Some operators do not run social media at all. Lodgify is the minimum viable connection for the suite; social adds the marketing layer on top.

---

## What each bot can now do (post-connection)

| Bot | With Lodgify connected | With social connected |
|-----|------------------------|----------------------|
| Channel Manager | Sync calendars across Airbnb, VRBO, Booking.com via `lodgify__*` tools; detect double-booking risks | |
| Guest Communicator | Pull confirmed bookings to gate access-code delivery; personalize check-in messages from Lodgify booking data | |
| Dynamic Pricing | Read current availability; push approved rates back through Lodgify to all three channels | |
| Property Marketer | Research SEO keywords and competitor listings; draft platform-specific descriptions | Draft Instagram/Facebook posts via `instagram__*` and `facebook-pages__*` tools after Property Manager approval |
| Review Manager | Browse Airbnb, VRBO, and Lodgify review pages to detect new reviews | |
| Turnover Coordinator | Generate cleaning assignments from Lodgify checkout/check-in data | |
| Property Manager | Consolidate all specialist findings into a daily portfolio briefing; escalate emergencies to you | |
