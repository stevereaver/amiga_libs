---
name: plane-tracking
description: Track non-trivial work for this repo in the Plane "Amiga Libs" project (plane.reavernet). Use at the start of substantive coding tasks and on completion to create/update work items. Do NOT use for questions, explanations, or trivial changes.
allowed-tools:
  - mcp__plane__workitem
  - mcp__plane__workitem_comment
  - mcp__plane__workitem_link
  - mcp__plane__workitem_activity
  - mcp__plane__state
  - mcp__plane__label
  - mcp__plane__project
  - mcp__plane__member
  - mcp__plane__cycle
  - mcp__plane__module
  - mcp__plane__get_pql_reference
---

Track work for this repository in the Plane project **Amiga Libs**
(`AMIGALIBS`) on plane.reavernet, via the `plane` MCP server.

## Constants

- `project_id`: `07f903d0-f082-493d-956c-15ee20b52c0c`
- Identifier prefix: `AMIGALIBS` (items display as `AMIGALIBS-N`)
- States:
  - Backlog: `61b5efe9-578a-4d39-aafa-b6c2a8eb5d2e` (group: backlog, project default)
  - Todo: `6568fea2-4290-433c-a800-688e71b9d954` (group: unstarted)
  - In Progress: `92c3b6eb-5416-4575-8c70-fa3b253c871c` (group: started)
  - Done: `acda6352-de3b-4df7-b7e1-f0b45e8c26fd` (group: completed)
  - Cancelled: `2c0cacfc-e1fc-4d3c-aff5-5c42fecadb39` (group: cancelled)

## When to track

**DO track** — create or update a work item when the task is:
- A new feature, bug fix, refactor, or non-trivial chore
- Multi-step work spanning several files, commits, or sessions
- An investigation that will produce code changes or a decision worth recording
- Work the user explicitly asks to track

**Do NOT track:**
- Questions, explanations, or read-only exploration
- Single-command lookups and one-liner/trivial fixes (typos, comment tweaks)
- Anything the user signals is trivial
- When genuinely borderline, skip rather than clutter the board — or ask the user

## Workflow

### 1. Task start
- Avoid duplicates first: `workitem` action `search` (or `list` with a `pql` filter) in the project for an existing item.
- If none exists: `workitem` action `create` with `project_id`, a short imperative `name` ("Add exec.library stub", not "We should add..."), `description_html` covering what/why, relevant files, and acceptance criteria. Set `priority` only when obvious.
- Set `state` to In Progress when you begin; leave it Todo if you're only capturing it for later.
- Mention the item once to the user in a short line (e.g. "Tracking as AMIGALIBS-3") — don't make a fuss about it.

### 2. During work
- `workitem_comment` (`comment_html`, e.g. `<p>...</p>`) only for significant milestones, scope changes, or blockers — not every step.
- Attach relevant URLs (GitHub PRs, docs) with `workitem_link` action `create`.
- If blocked: comment why and set state back to Todo, or leave In Progress if actively being worked around.

### 3. Completion
- After the change is verified, `workitem` action `update` with `state` = Done.
- Add one final comment: what changed, key files, commit/PR link.
- If the user abandons the task, set state = Cancelled with a brief comment.

### 4. Status queries
- "What's in flight?" → `workitem` action `list` with `project_id` (optionally `pql`, e.g. `stateGroup IN openStates()`); call `get_pql_reference` first if unsure of syntax.
- References like "AMIGALIBS-3" → `workitem` action `retrieve_by_identifier`.

## Rules

- Always search before creating — never duplicate items.
- Keep comments brief; the board is a ledger, not a chat log.
- The project has no labels configured; only use `label create` or `workitem_type resolve` if the user asks for categorization.
- Don't ask permission for routine create/update/comment tracking — it's expected.
- DO ask before deleting or archiving work items.
- If the `plane` MCP server is unreachable, tell the user once and continue the task — tracking is secondary to the work itself.
