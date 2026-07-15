<!-- agentics-template-version: 0.1.0 -->
# helm-charts: Agent collaboration conventions

**For AI agents:** this file is instructions your agent reads and follows; it is not documentation written for people. If you're a person looking for how this project works, see `DEVELOPMENT.md` and `README.md` instead.

Adapted from [softeng/agentics](https://github.com/oicr-softeng/agentics). To get updates, compare this file's version tag against the agentics CHANGELOG.

## Interaction parameters
- Ask clarifying questions before making large assumptions about intent
- Surface better alternatives before presenting an implementation, not only after being asked why one wasn't offered; let the user decide
- Push back on bad ideas and identify blind spots before they are baked into code: lead with the objection, not a neutral trade-off list; don't wait to be asked
- Verify purpose alignment before implementing: when a task names a goal, check whether the chosen approach achieves that goal directly, not just something adjacent to it; lead with that gap as an objection before writing anything
- Flag scope-adjacent issues verbally, then document them in `.dev/tech-debt.md`

## Critical constraints
- No credentials, secrets, or private URLs in any file: ever
- No chart packages (`.tgz`) committed to `main`: Jenkins handles all packaging and publishing
- Do not modify instruction files without explicit developer instruction: surface suggestions, do not self-edit
- No machine- or user-specific absolute paths, usernames, or individuals' real names in committed files
- Name code, not people: attribute work in session files, tech-debt entries, and docs to features and systems, not individuals

## When to read what

Global conventions (testing, code style, security, session discipline) are in the developer's global agent context. Project-specific reads only:

- Starting a session: read `.dev/roadmap.md`, `.dev/tech-debt.md`, and the most recent 1-2 files in `.dev/sessions/`
- Adding or improving a convention: read `conventions/convention-levels.md` in the agentics repo

## Project overview

Helm charts for the OICR Software Engineering team, published as OCI artifacts to `ghcr.io/oicr-softeng/helm-charts` by Jenkins on every push to `main`. Already-published versions are skipped.

```
helm-charts/
├── <chart-name>/  # One directory per chart (Helm chart source)
├── .dev/          # Working documents (roadmap, tech-debt, session logs)
├── .github/       # Copilot instructions
├── Makefile       # Local dev helpers
├── CLAUDE.md      # This file
├── AGENTS.md      # Agent instructions (non-Claude)
├── DEVELOPMENT.md # Developer setup and workflow guide
└── README.md      # End-user usage guide
```

## Key conventions

- Chart source lives in named directories at the repo root (e.g. `stateless-svc/`)
- Bump `version` in `Chart.yaml` before pushing changes to an existing chart
- Jenkins handles all packaging and publishing; developers push source to `main` only
- `helm` not `helm3`

## Working documents

| File | Purpose |
|------|---------|
| `.dev/roadmap.md` | Planned work: new charts, tooling improvements, CI automation |
| `.dev/tech-debt.md` | Known issues and deferred improvements |
| `.dev/sessions/` | Session logs, one file per (day, contributor) |

## Starting a session

On a session-start signal (greeting, resumption phrase, "sync up"), before touching any code:

1. Check `git log --oneline -1 -- CLAUDE.md AGENTS.md` — re-read only changed files; say so when you do
2. Read `.dev/roadmap.md`: check current focus and any `[in progress]` items
3. Read `.dev/tech-debt.md`: note `standalone: yes` entries relevant to today's work
4. Read the most recent 1-2 files in `.dev/sessions/` for context on recent work and open threads
5. Check for upstream agentics updates: compare the version tag in this file against the agentics CHANGELOG

## Keeping .dev/ current

After any meaningful unit of work: code written, bug fixed, tech-debt logged, roadmap updated:
- Add or extend the dated entry in your session file under `.dev/sessions/`
- Update `.dev/roadmap.md` or `.dev/tech-debt.md` when an item's status changes
- Do not log conversational activity (discussions, PR reviews with no local changes, waiting states)
- Do not wait for a "session over" signal

Before marking an item done: verify against actual current code or file state, not a prior description. When `.dev/` documents are updated, remind the developer to commit them.

## Session file identity

Each session's log lives in its own file under `.dev/sessions/`, named `YYYY-MM-DDTHHMMSS.md`. One file per (day, contributor): the same contributor picking work back up later the same day extends their existing file.

To find your file for today: list `.dev/sessions/` for today's date prefix, then check authorship (`git log -1 --format=%ae -- <file>` vs `git config user.email`; uncommitted = yours). If a match is yours, extend it. Otherwise create a new file.

Run `date +%Y-%m-%dT%H%M%S` to get the actual timestamp before creating a new file — do not default to `T000000`.

## Session file entry format

One lean context sentence (what + why), a blank line, then one bullet per file or logical group of changes. No date header, no prose paragraphs, no "Next:" line (open work belongs in `roadmap.md`). Bullet separator is `: ` (colon-space).

```
[One sentence: what the work was and why.]

- `path/to/file`, `path/to/other`: what changed; decision or constraint if non-obvious
- `path/to/file`: what changed
```

Write about effects, not style. Describe what the code now does or enables. A PR review that turns up one real local change logs the local change only, not the investigation.

A session file is immutable once its day is done. Exception: a Critical Constraint violation (a name, a credential) overrides immutability — fix it regardless of which day produced it.

## Tech-debt entry format

```
[short description of the issue]
fix: [what the fix actually is, in one sentence]
standalone: yes | no
context: [roadmap item reference or brief note: required when standalone: no]
```

`standalone: yes`: can be picked up freely. `standalone: no`: blocked on or coupled to roadmap work.

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
