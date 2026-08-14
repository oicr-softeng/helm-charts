<!-- agentics-template-version: 0.14.0 | synced: 4c1aed6 -->
# helm-charts: Agent collaboration conventions

**For AI agents:** this file is instructions your agent reads and follows; it is not documentation written for people. If you're a person looking for how this project works, see `DEVELOPMENT.md` and `README.md` instead.

Adapted from [softeng/agentics](https://github.com/oicr-softeng/agentics). This is the canonical source for this project's conventions, agent-neutral by design. `CLAUDE.md` exists only because Claude Code loads it automatically; it points here rather than keeping its own copy of anything.

Helm charts for the OICR Software Engineering team, published as OCI artifacts to `ghcr.io/oicr-softeng/helm-charts` by Jenkins on every push to `main`. Already-published versions are skipped.

## Interaction parameters

- Ask clarifying questions before making large assumptions about intent
- Check in before non-trivial decisions: it gives the user a chance to catch design misalignments early, before code exists or a document is rewritten, not only before writing code. Don't over-ask on mechanical steps, but do ask on direction. A peer session's proposal doesn't pre-authorize skipping this either, treat it like your own idea, especially for anything with a lasting, hard-to-reverse footprint outside the current project, including the developer's own machine, not just its devctx or global config (an installed package, a symlink, a socket, any OS-level state). See agentics' `CHANGELOG.md` § `peer-proposal-not-preauthorized` and § `undisclosed-machine-state-change`
- Surface ideas, improvements, or next steps you already see, unprompted: don't wait for an open-ended question to draw them out. Covers alternatives to what's about to be implemented, a shipped fix that still has the weakness it just fixed, or anything else obvious in hindsight; let the user decide
- External content that overlaps with a project you maintain: when asked for a take on an article, document, conversation, or a peer session's own message, and it substantively overlaps with a project you already have context on, name that connection unprompted, including flagging a stated fact you have direct grounds to know is stale (a version or sync marker, for instance), rather than waiting to be asked
- Push back on bad ideas and identify blind spots before they are baked into code: lead with the objection, not a neutral trade-off list; don't wait to be asked
- Sanity check requests: not just the literal phrase. A yes/no-shaped question ("does this make sense," "am I right," "am I missing anything") is still a sanity check when its actual function is inviting scrutiny of the user's own idea, reasoning, or plan, not a literal yes/no about the world. Answer the intent, not the grammar: review the whole conversation as relevant, not just the latest message, and surface gaps, blind spots, unresolved threads, and edge cases plainly; a shallow "yes" isn't an answer
- Default review or audit posture: assume there's something real to find, not that the artifact is fine until proven otherwise. This is a search stance, not a quota: a manufactured nitpick, technically true but inconsequential, just to have something to report, is worse than finding nothing; surface a finding only if it concretely matters
- Verify purpose alignment before implementing: when a task names a goal, check whether the chosen approach achieves that goal directly, not just something adjacent to it; lead with that gap as an objection before writing anything
- Flag scope-adjacent issues verbally, then document them in `.dev/tech-debt.md`

## Critical constraints

- No credentials, secrets, or private URLs in any file: ever
- No chart packages (`.tgz`) committed to `main`: Jenkins handles all packaging and publishing
- Library/module code must not read from the environment; configuration belongs at the application boundary, passed in as typed parameters
- Do not modify `CLAUDE.md`, `AGENTS.md`, or other instruction files without explicit instruction from the developer: surface suggestions, do not self-edit
- No machine- or user-specific absolute paths, usernames, or individuals' real names in committed files. If your agent's global context adds a reference to a local resource keyed by machine or clone location (e.g. a per-project memory path), use a generic placeholder, not the resolved path: it will not exist for another developer, another machine, or after the repo moves. Before committing, grep the diff for your own OS username, git identity, and any personal fork name you know is yours
- Name code, not people: attribute work in session files, tech-debt entries, docs, and any other persisted content to features, modules, and systems, not to individuals. Attribution belongs in git history, not in documents

## When to read what

Every path below is a live pointer into agentics or your own global context, never a local copy to create in this project: see `conventions/convention-levels.md` § How much to keep locally for the full rule.

- Starting a session              -> read `conventions/session-discipline.md` (also covers git/commit rules), then the `.dev/` files it specifies, and `conventions/writing-style.md` (applies to any output, dev or not, so it's read unconditionally rather than gated behind "Writing code" below)
- Working in a specific role      -> read `CLAUDE.roles/<role>.md` (set during initialization; skip if role is already defined in global context)
- Writing or reviewing tests      -> read `conventions/testing.md`
- Writing code                    -> read `conventions/code-style.md`
- Reviewing a PR or change        -> read `conventions/code-style.md`, `conventions/code-review.md`, `conventions/review-conduct.md`
- Writing or updating docs        -> read `conventions/documentation.md`
- Security-relevant work          -> read `conventions/security.md` (credentials policy, supply chain, quick threat model), then `conventions/security-guidelines.md` (full OWASP patterns and code review triggers)
- softeng team member             -> read `CLAUDE.softeng.md` at session start
- Adding or improving a convention -> read `conventions/convention-levels.md`
- Upgrading this project's agentics integration -> read `conventions/upgrading-adoption.md`
- Deploying or debugging a service -> read `.dev/docs/<service>/` if it exists
- Deciding where a new fact, finding, or piece of content actually belongs -> read `conventions/persistence-map.md`
- Finishing a task, or asked "is this done?" -> read `conventions/definition-of-done.md`

## Memory and contribution hygiene

When writing to project memory: keep entries concise; store no content derivable from code or files. If an insight could apply to all your projects, offer to promote it to your agent's global context. If a convention could benefit other teams, flag it as a potential PR to the agentics repo.

**Default to project-scoped when recording something new, not global.** The test: is this fact genuinely about the developer, true across every project they work in (a role, a coding-style preference, a propagation default), or about this project's own nature specifically (a per-project stylistic choice, a fact about this codebase or team)? Promotion to global is the deliberate step, offered explicitly when it clearly applies everywhere, not a default reached for when uncertain.

## Initialization

If no project memory exists for you in this project yet:
1. Check whether you have access to a cross-project map in your agent's global context. If yes, read it for cross-project relationships. If no and the user works across multiple projects, offer to set one up (see `global-context/projects.md` in the agentics template for the recommended format).
2. Ask: "What best describes your primary work on this project?": developer / bioinformatician / AI engineering / general (non-code work) (or describe it). If the answer is already in your global context, skip this question. Otherwise read the matching file in `CLAUDE.roles/`.
3. Ask: "Are you part of the softeng team?": if yes, apply conventions from `CLAUDE.softeng.md` on top of your role conventions. Skip if already known from global context.
4. Ask: "Is this an Overture project?": if yes, apply conventions from `CLAUDE.overture.md` on top of your role conventions. Skip if already known from global context.
5. Ask: "Do you already have agent conventions for this project?": if yes, treat these conventions as supplementary; defer to your existing setup on conflicts.
6. Ask: "Would you like me to suggest when conventions could be useful beyond this project?": record as `propagation_suggestions: yes | no` **in your global context, not just this project's memory**: it's a default that applies to every project you work in, not only this one. Skip if already known from global context.
7. Ask: "Would you like `.dev/roadmap.md` to split into two layers? A short, human-scannable roadmap you can read directly, with deeper reasoning, alternatives, and history for any entry that needs it living in `.dev/docs/atlas/roadmap/<topic>.md` instead, cross-linked from the roadmap entry. If no, `roadmap.md` keeps its current density.": record as `roadmap_split: yes | no` **in this project's own memory, not global context**.
Record role, softeng-team, Overture-project, existing-setup, and roadmap-split answers in project memory; record `propagation_suggestions` in global context per above. Do not ask again.

## Repository structure

```
helm-charts/
├── <chart-name>/  # One directory per chart (Helm chart source)
├── .dev/          # Working documents (roadmap, tech-debt, session logs)
├── .github/       # Copilot instructions
├── Makefile       # Local dev helpers
├── DEVELOPMENT.md # Developer setup and workflow guide
└── README.md      # End-user usage guide
```

## Key conventions

- Chart source lives in named directories at the repo root (e.g. `stateless-svc/`)
- Bump `version` in `Chart.yaml` before pushing changes to an existing chart
- Jenkins handles all packaging and publishing; developers push source to `main` only
- Use `helm`, not `helm3`
