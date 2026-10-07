---
name: ops-log
description: "Write complete, concise ASD-STE100 operational logs about raj with dynamic sections; title/date only; iterate locally, commit and publish only on separate explicit requests."
---

# Operational logs

Create or revise a log only when the user asks. Record raj's work and intent, not the agent's tool output. Refer to raj by name. Never write 'the user' in a log.

## File format

Keep each log as one Markdown file directly in logs/. Use only title and date in YAML front matter. Preserve the existing slug and publication date on revision. Use a timezone-aware date value for the current log publisher.

Do not add status, task, harness, provider, model, effort, contributors, or related-link metadata. Do not create artifact files or extra directories. Put links to past meditations and blogs in the body.

## Body outline

Use these top-level Markdown headings in this order:

1. Abstract — a brief account of what the log covers.
2. Context — explain the starting state and the reason for the work.
3. A dynamic number of named sections — use as many sections as needed to connect the whole story. Each section must explain a concrete part of the work, its reason, and its effect. Do not force several material changes under one broad heading.
4. Conclusion — state the result or the expected new state. Do not present a plan as a completed action.
5. Past relevant meditations and blogs — link to existing, relevant posts. Do not invent links. Omit unrelated sources and raw artifacts. If there is no relevant past post, say so briefly under this heading.

Do not add a separate Action or Expected state field by default. Use the named sections and Conclusion for that information.

## Language

Use ASD-STE100 Simplified Technical English throughout new log prose. ASD-STE100 is the sole writing standard: https://www.asd-ste100.org/ . The current official issue is Issue 9 (January 2025).

Use approved words with their approved meaning and part of speech. Use a subject-specific technical noun or verb only when needed, and use the same term for the same concept. Define terms when the reader needs a definition. Use short, direct sentences, active voice, and one main idea per sentence. Avoid idioms, synonyms for the same concept, long noun groups, and needless detail.

The official standard includes writing rules and a controlled dictionary. Use the official rules and dictionary for a compliance review when available. The public website does not provide the complete dictionary; it directs users to a request form for the official copy. Do not claim verified compliance from AI output or plain-language checks alone. Official references: https://www.asd-ste100.org/about_STE.html and https://www.asd-ste100.org/STE_downloads.html .

Keep sentences concise without removing material detail. Cover the decisions, changes, and resulting behavior that raj needs to understand the work. Concrete UI behavior, routes, data flow, and the writing workflow are useful when they are part of the change. Omit redundant wording and internal tool chatter, not the substance of the work. Do not impose a word target, section limit, or add sections to fill space. Keep uncertainty explicit. Use the correct tense for completed work and plans.

## Diagrams and math

Mermaid diagrams and math are permitted when they make the information clearer or shorter. Prefer Mermaid for flows and relationships. Prefer an inline SVG for an accurate UI wireframe; keep the SVG in the Markdown file, without an artifact directory. Do not add them for decoration. Use them only when the publishing surface can show them correctly. Keep labels and explanations in STE. Simple changes usually need neither.

## Integration

Do not edit meditation prose unless asked. Preserve collection URLs, independent mx/lx codes, shared map coordinates, and collection search behavior. Use the workflow below for embedding, preview, commit, and publication.

## Separate iteration from commit

Draft iteration is the default. Edit the requested log and writing rules, build a local preview, and give raj the result for review. Continue with small revisions while raj refines the log. Do not stage, commit, push, or publish during iteration. Do not infer approval from a successful preview or from a request for another revision.

For a prose preview, use the normal embedding updater: only changed entries require inference. Treat the updated working blog.sqlite as part of the local draft. Do not create a separate artifact tree. Verify the actual rendered content, diagrams, and past links. Report whether the current changes are local, committed, or published.

Commit only when raj explicitly asks for a commit or approves a specific final version for commit. Check the final embedding state and local build. Include only the agreed log and its required state or rendering changes, not unrelated work. Do not use publish.sh merely to commit: it also stages all non-ignored changes and pushes.

Push or publish only when raj explicitly asks for that step. Permission to commit does not, by itself, permit a push or publication. Keep dotfiles skill changes separate from blog changes; do not commit either repository without the relevant request.
