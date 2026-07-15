<!-- agentics-template-version: 0.1.0 -->
# helm-charts: Agent collaboration conventions

**For AI agents:** this file is instructions your agent reads and follows; it is not documentation written for people. If you're a person looking for how this project works, see `DEVELOPMENT.md` and `README.md` instead.

Adapted from [softeng/agentics](https://github.com/oicr-softeng/agentics). This is the comprehensive reference for agents that do not load files on demand. If you are Claude, prefer `CLAUDE.md`.

Helm Charts server for the OICR Software Engineering team. Charts are packaged and published as OCI artifacts to GHCR via Jenkins on every push to `main`.

## Interaction parameters

- Ask clarifying questions before making large assumptions about intent
- Surface better alternatives before presenting an implementation, not only after being asked why one wasn't offered; let the user decide
- Push back on bad ideas and identify blind spots before they are baked into code: lead with the objection, not a neutral trade-off list; don't wait to be asked
- Verify purpose alignment before implementing: when a task names a goal, check whether the chosen approach achieves that goal directly, not just something adjacent to it; lead with that gap as an objection before writing anything
- Flag scope-adjacent issues verbally, then document them in `.dev/tech-debt.md`

## Critical constraints

- No credentials, secrets, or private URLs in any committed file: ever
- Do not modify `CLAUDE.md`, `AGENTS.md`, or other instruction files without explicit developer instruction: surface suggestions, do not self-edit
- No machine- or user-specific absolute paths, usernames, or individuals' real names in committed files
- Name code, not people: attribute work to features, modules, and systems in session files, tech-debt entries, and docs; attribution belongs in git history

## Project overview

- **Published to:** `oci://ghcr.io/oicr-softeng/helm-charts` (OCI artifacts on GHCR)
- **Publishing:** Jenkins CI on every push to `main`
- **Helm version:** Helm 3 (use `helm`, not `helm3`)

## Repository structure

```
helm-charts/
├── <chart-name>/  # One directory per chart (Helm chart source)
├── .dev/          # Working documents (roadmap, tech-debt, sessions)
├── DEVELOPMENT.md # Developer setup and workflow guide
└── README.md      # End-user instructions
```

## Key chart conventions

- Chart source lives in named directories at the repo root (e.g. `mychart/`)
- Bump `version` in `Chart.yaml` before pushing changes to an existing chart
- Jenkins handles packaging and publishing; developers push source to `main` only

## Session-start signals

A session is a work period, not necessarily a new chat thread. Treat greetings, resumption phrases ("let's continue", "back to it"), and on-demand requests ("sync up", "re-read your instructions") as session-start signals even mid-thread.

## Starting a session

On a session-start signal, before touching any code:

1. Check `git log --oneline -1 -- CLAUDE.md AGENTS.md` — re-read only changed files; say "I've re-read [file]: the prior version is superseded" when you do
2. Read `.dev/roadmap.md`: check current focus and any `[in progress]` items
3. Read `.dev/tech-debt.md`: note `standalone: yes` entries relevant to today's work
4. Read the most recent 1-2 files in `.dev/sessions/` (sort by filename; ISO timestamps sort chronologically) for context on recent work and open threads
5. Check for upstream agentics updates: compare the version tag in this file against the agentics CHANGELOG

## Keeping `.dev/` current

Update `.dev/roadmap.md` or `.dev/tech-debt.md` within the same session whenever a roadmap item's status changes, a tech-debt entry is resolved, or a meaningful decision is made.

After any meaningful unit of work: add or extend the dated entry in your session file. Do not wait for a "session over" signal. Do not log conversational activity (discussions, PR reviews with no local changes, waiting states) — but a review that produces one real local change (a tech-debt entry, a roadmap update) logs that change like any other.

When `.dev/` documents are updated, remind the developer to commit them.

## Session file identity

Each session's log lives in its own file under `.dev/sessions/`, named `YYYY-MM-DDTHHMMSS.md`. A different contributor always needs their own file; the same contributor picking work back up later the same day extends their existing file.

To find your file for today: list `.dev/sessions/` for today's date prefix, then check authorship of any match. If a match is yours, extend it. Otherwise create a new file — run `date +%Y-%m-%dT%H%M%S` to get the real timestamp before creating it.

Never rename an already-created file. Fetch the real time before creating a file, never after.

## Session file entry format

One lean context sentence (what + why), a blank line, then one bullet per file or logical group of changes. No date header, no prose paragraphs, no "Next:" line (open work belongs in `roadmap.md`). Bullet separator is `: ` (colon-space).

```
[One sentence: what the work was and why.]

- `path/to/file`, `path/to/other`: what changed; decision or constraint if non-obvious
- `path/to/file`: what changed
```

Write about effects, not style. Describe what the code now does or enables. Name code, not people: attribute work to features and modules, not individuals.

A session file is immutable once its day is done. Exception: a Critical Constraint violation (an individual's name, a credential) overrides immutability and must be corrected regardless of which day produced it.

## Tech-debt entry format

```
[short description of the issue]
fix: [what the fix actually is, in one sentence]
standalone: yes | no
context: [roadmap item reference or brief note — required when standalone: no]
```

`standalone: yes`: can be picked up freely. `standalone: no`: blocked on or coupled to roadmap work; read the context note before touching it.

## Code style

**Comments:** write none by default. Add one only when the WHY is non-obvious: a hidden constraint, subtle invariant, workaround for a specific bug. Never explain WHAT the code does.

**Scope:** stick to stated scope. Surface weaknesses verbally. Log issues too large to fix in scope in `.dev/tech-debt.md`. Three similar lines is better than a premature abstraction.

**Search before writing:** search the codebase for existing patterns before writing from scratch.

**Property ordering:** alphabetize properties in YAML/JSON config files at all nesting levels — prevents silent duplicate key overwrites.

**Language:** flag typos and language issues when spotted. Don't fix silently. Canadian English spelling.

## Convention placement and propagation

Conventions live at one of three levels:
- **Project-specific**: applies to this project only — goes in this file or `.dev/tech-debt.md`
- **Global**: applies to all the developer's projects — belongs in the developer's global agent context
- **Shareable**: could benefit other teams — flag as a potential PR to the agentics repo

When adding or improving a convention, ask which level is correct. If a convention just improved here, ask whether sibling projects would benefit.

## Memory hygiene

Keep entries concise; store no content derivable from code or files. If an insight could apply to all projects, offer to promote it to global context. If a convention could benefit other teams, flag it as a potential PR to the agentics repo.

## Initialization

If no project memory exists for you in this project yet:
1. Check whether a cross-project map is accessible in your global context. If yes, read it.
2. Ask: "What best describes your primary work on this project?": developer / bioinformatician / AI engineering / general. Skip if known from global context.
3. Ask: "Are you part of the softeng team?": if yes, apply softeng conventions. Skip if known from global context.
4. Ask: "Would you like me to suggest when conventions could be useful beyond this project?": record as `propagation_suggestions: yes | no`. Skip if known from global context.
Record all answers in project memory. Do not ask again.
