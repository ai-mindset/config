<!--
Inspired by the BetterStack video that provided the source screenshots:
https://inv.nadeko.net/watch?v=D4uBfIe7SzA

Refined with model-agnostic guidance from:
https://inv.nadeko.net/watch?v=5TNXByrtHc4
-->

# {{PROJECT_NAME}} agent guide

<!--
TEMPLATE SETUP — delete this comment after customization.

This source template is intentionally comprehensive. Its customized result must
be concise and contain only guidance that applies to the repository.

For a human:
- When this template is first introduced, ask the agent to customize and prune
  it in the same task. Do not leave the unresolved template as active guidance.
- Replace every {{PLACEHOLDER}} with repository-specific information.
- Delete optional rows, bullets, and sections that do not apply.

For an AI agent:
1. Inspect the repository before editing this file. Read manifests, lockfiles,
   CI workflows, existing documentation, and representative source and test
   files.
2. Fill placeholders only with facts supported by repository evidence. Do not
   invent commands, paths, architecture, product requirements, or policies.
3. Ask the user about consequential details that cannot be inferred safely.
4. Preserve useful generic rules only when they apply to this repository and do
   not conflict with verified project practice.
5. Keep the root file compact and repository-wide. Move specialized guidance
   into linked playbooks or nested instruction files recognized by the target
   agent runtime.
6. Confirm which features the target runtime supports, including instruction
   discovery, nested overrides, mid-run steering, task ledgers, and subagents.
7. Replace vague aspirations with concrete, observable instructions and checks.
8. Remove this setup comment after customization.

Before finishing:
- Search for unresolved placeholders with:
  `rg -n '\{\{[^}]+\}\}' AGENTS.md`
- Verify every documented command from the repository root.
- Confirm every referenced path exists.
- Remove examples and sections that are not relevant.
- Remove duplicated rules and keep enough instruction budget for narrower
  guidance. Prefer links to detailed playbooks over embedding long workflows.
- Check the final size with `wc -c AGENTS.md` against the active runtime's
  instruction limit. Codex project-file discovery defaults to 32 KiB; leave
  ample headroom for nested guidance. Other runtimes may differ.
- Do not include secrets, credentials, or private environment values.
-->

{{ONE_SENTENCE_DESCRIPTION_OF_THE_PROJECT_AND_ITS_PURPOSE}}

- Primary users: {{PRIMARY_USERS}}
- Project stage and deployment model: {{PROJECT_STAGE_AND_DEPLOYMENT_MODEL}}
- Primary documentation: `{{PRIMARY_DOCUMENTATION_PATH}}`
- Issue or work tracking: {{ISSUE_TRACKER_OR_WORKFLOW}}

## Repository overview

| Area                                      | Purpose                                   | Technology                                      | Path                               |
| ----------------------------------------- | ----------------------------------------- | ----------------------------------------------- | ---------------------------------- |
| {{COMPONENT_1_NAME}}                      | {{COMPONENT_1_PURPOSE}}                   | {{COMPONENT_1_LANGUAGE_OR_FRAMEWORK}}            | `{{COMPONENT_1_PATH}}`             |
| {{COMPONENT_2_NAME}}                      | {{COMPONENT_2_PURPOSE}}                   | {{COMPONENT_2_LANGUAGE_OR_FRAMEWORK}}            | `{{COMPONENT_2_PATH}}`             |
| {{OPTIONAL_COMPONENT_NAME_OR_REMOVE_ROW}} | {{OPTIONAL_COMPONENT_PURPOSE_OR_REMOVE}}  | {{OPTIONAL_COMPONENT_TECHNOLOGY_OR_REMOVE}}      | `{{OPTIONAL_COMPONENT_PATH}}`      |

- Configuration: `{{CONFIGURATION_PATH}}`
- CI and release automation: `{{CI_OR_RELEASE_PATH}}`
- New code belongs in: {{NEW_CODE_LOCATION_RULES}}
- Tests belong in: {{TEST_LOCATION_RULES}}
- Shared code belongs in: {{SHARED_CODE_RULES}}
- Generated or vendored areas and edit rules:
  {{GENERATED_OR_VENDORED_PATHS_AND_RULES_OR_NONE}}
- Files or directories that must not be edited directly:
  {{DO_NOT_EDIT_PATHS_OR_NONE}}
- Rules for adding files at the repository root:
  {{ROOT_FILE_RULES_OR_REMOVE_BULLET}}
- Nested agent instructions: {{NESTED_INSTRUCTION_FILES_OR_NONE}}
- Tool-specific instruction adapters: {{TOOL_SPECIFIC_ADAPTER_PATHS_OR_NONE}}
- Skills or longer playbooks: {{SKILLS_OR_PLAYBOOKS_PATH_OR_NONE}}
- Long-running task ledger: {{TASK_LEDGER_PATH_OR_NONE}}

## Agent compatibility

- Keep core guidance model- and vendor-neutral. Use instruction overrides,
  mid-run steering, persistent task files, or subagents only when the active
  runtime supports them and the task authorizes them.
- When several agent tools share this repository, keep one canonical policy
  here and use small tool-specific adapters rather than duplicating rules.

## Safety and scope

- Work only inside this repository and explicitly approved temporary locations.
- Do not read, print, copy, or commit secrets. Treat environment files,
  credentials, tokens, private keys, and production data as sensitive.
- Preserve user changes and unrelated work. Do not overwrite or revert changes
  that are outside the task.
- Make the smallest coherent change that satisfies the request.
- Use non-destructive commands by default. Ask before deleting non-temporary
  files, rewriting history, changing production data, or performing another
  difficult-to-reverse action.
- Do not push, publish, deploy, release, or mutate external systems unless the
  user explicitly requests it.
- Do not broaden the task to fix adjacent issues. Report them separately.

## Ask before you assume

Ask a focused question before proceeding when:

- The request has multiple reasonable interpretations with materially different
  outcomes.
- A requested change crosses a public API, persisted-data, schema, protocol,
  compatibility, or shared-contract boundary and its compatibility or migration
  expectations cannot be inferred safely.
- Material product behaviour, copy, security posture, or acceptance criteria
  cannot be inferred safely from the request or repository evidence.
- The work adds or replaces a production dependency.
- Required access, authority, or external coordination has not been granted.

If a low-risk assumption is necessary, state it in the final summary.

## Definition of done

Before implementation, derive a concrete finish line from the full request,
repository evidence, and required checks. Make completion observable:

- Identify what must change and what obsolete paths or compatibility code must
  be removed.
- Identify the tests, documentation, generated artefacts, and quality gates that
  are relevant and proportionate to the changed behaviour and risk.
- Turn subjective goals into specific constraints or examples. Replace generic
  requests for extra effort, caution, or quality with observable acceptance
  criteria.

For a well-scoped task, complete proportionate inspection, implementation,
verification, and handoff without asking for confirmation between routine steps.
Ask only when a condition in **Ask before you assume** applies.

## Workflow

1. Read the relevant instructions and documentation.
2. Inspect the implementation, tests, contracts, and history needed for this
   task; do not load unrelated context by default.
3. For a bug, reproduce the failure or establish a failing check first when
   practical.
4. Implement incrementally and keep the change reversible.
5. Run the smallest relevant checks while working when their feedback reduces
   risk; do not rerun unchanged expensive gates without reason.
6. Run the applicable required quality gates before reporting completion.

Do not disable, skip, weaken, or mark tests as exclusive merely to make a check
pass. If a test is incorrect, explain why before changing it.

### Long-running work

- Match the requested depth and pace. Answer quick, direct questions directly;
  do not turn them into long-running work unless correctness requires it.
- Keep working while the next step is safe, in scope, and reversible. Where
  supported, give progress updates without treating them as permission gates.
- When the runtime delivers new user input during a run, incorporate it at the
  next safe boundary. Preserve still-valid work instead of restarting by
  default.
- For work likely to outlast one context window, maintain the configured task
  ledger. Record the objective, constraints, decisions, completed work, current
  work, remaining work, and blockers. If none is configured, do not create or
  commit one unless requested; use an approved temporary location instead.
- When the runtime supports parallel agents and the task authorizes them, divide
  independent scopes clearly, require evidence with each result, and verify it
  before integration. The primary agent remains responsible for cross-cutting
  consistency and final checks.
- Diagnose explainable failures and try safe, relevant alternatives. Stop when
  progress requires missing authority, a consequential decision, a destructive
  action that was not approved, or a failure that remains unexplained after
  reasonable investigation.

## Commands and quality gates

Run commands from `{{DEFAULT_COMMAND_DIRECTORY_OR_REPOSITORY_ROOT}}` unless a
row says otherwise.

| Purpose              | Command                                | When required                             |
| -------------------- | -------------------------------------- | ----------------------------------------- |
| Install or bootstrap | `{{INSTALL_COMMAND}}`                  | {{INSTALL_WHEN_REQUIRED}}                 |
| Format               | `{{FORMAT_COMMAND}}`                   | {{FORMAT_WHEN_REQUIRED}}                  |
| Lint                 | `{{LINT_COMMAND}}`                     | {{LINT_WHEN_REQUIRED}}                    |
| Type-check           | `{{TYPECHECK_COMMAND}}`                | {{TYPECHECK_WHEN_REQUIRED}}               |
| Unit tests           | `{{UNIT_TEST_COMMAND}}`                | {{UNIT_TEST_WHEN_REQUIRED}}               |
| Integration tests    | `{{INTEGRATION_TEST_COMMAND}}`         | {{INTEGRATION_TEST_WHEN_REQUIRED}}        |
| End-to-end tests     | `{{E2E_TEST_COMMAND}}`                 | {{E2E_TEST_WHEN_REQUIRED}}                |
| Build                | `{{BUILD_COMMAND}}`                    | {{BUILD_WHEN_REQUIRED}}                   |
| Other required gate  | `{{OTHER_GATE_COMMAND_OR_REMOVE_ROW}}` | {{OTHER_GATE_WHEN_REQUIRED_OR_REMOVE_ROW}} |

- Long-running development command: `{{DEV_COMMAND_OR_NONE}}`
- Do not use a non-terminating development process as the only verification.
  Prefer bounded checks, or start and stop the process explicitly.
- Required environment or services for tests: {{TEST_PREREQUISITES_OR_NONE}}

A change is complete only when applicable gates pass. Never report a red or
unrun required gate as successful; state what failed or could not be run.

## Languages and frameworks

| Scope                                    | Language, framework, and version                 | Authoritative configuration            |
| ---------------------------------------- | ------------------------------------------------ | -------------------------------------- |
| `{{TOOLCHAIN_1_SCOPE}}`                  | {{TOOLCHAIN_1_LANGUAGE_FRAMEWORK_AND_VERSION}}   | `{{TOOLCHAIN_1_CONFIG_PATH}}`          |
| `{{TOOLCHAIN_2_SCOPE}}`                  | {{TOOLCHAIN_2_LANGUAGE_FRAMEWORK_AND_VERSION}}   | `{{TOOLCHAIN_2_CONFIG_PATH}}`          |
| `{{OPTIONAL_TOOLCHAIN_SCOPE_OR_REMOVE}}` | {{OPTIONAL_TOOLCHAIN_DETAILS_OR_REMOVE}}         | `{{OPTIONAL_TOOLCHAIN_CONFIG_PATH}}`   |

- Follow the repository's formatter, linter, compiler, and framework
  conventions.
- Prefer established local patterns over introducing a new abstraction or
  vocabulary.
- Keep strictness settings enabled. Fix type or validation errors instead of
  suppressing them.
- Use an escape hatch only when it is unavoidable and document the concrete
  reason or upstream issue.
- Language- or framework-specific rules:
  {{LANGUAGE_AND_FRAMEWORK_RULES_OR_NESTED_AGENTS_PATH}}

## Naming and domain language

Use one canonical term per concept. Add verified project vocabulary below and
remove the placeholder row.

| Concept            | Use                  | Avoid                         |
| ------------------ | -------------------- | ----------------------------- |
| {{DOMAIN_CONCEPT}} | `{{CANONICAL_TERM}}` | {{AMBIGUOUS_OR_LEGACY_TERMS}} |

| Item                   | Convention                                  | Example                            |
| ---------------------- | ------------------------------------------- | ---------------------------------- |
| Files and directories  | {{FILE_AND_DIRECTORY_CONVENTION}}           | `{{FILE_AND_DIRECTORY_EXAMPLE}}`   |
| Functions and methods  | {{FUNCTION_AND_METHOD_CONVENTION}}          | `{{FUNCTION_AND_METHOD_EXAMPLE}}`  |
| Types and components   | {{TYPE_AND_COMPONENT_CONVENTION}}           | `{{TYPE_AND_COMPONENT_EXAMPLE}}`   |
| Booleans               | {{BOOLEAN_CONVENTION}}                      | `{{BOOLEAN_EXAMPLE}}`              |
| API routes or commands | {{API_ROUTE_OR_COMMAND_CONVENTION_OR_NONE}} | `{{API_ROUTE_OR_COMMAND_EXAMPLE}}` |
| Database objects       | {{DATABASE_OBJECT_CONVENTION_OR_NONE}}      | `{{DATABASE_OBJECT_EXAMPLE}}`      |
| User-facing copy       | {{USER_COPY_CONVENTION_OR_NONE}}            | `{{USER_COPY_EXAMPLE}}`            |

## Architecture and invariants

{{SHORT_ARCHITECTURE_OVERVIEW}}

- Primary request or data flow: {{REQUEST_OR_DATA_FLOW}}
- Authentication and authorization: {{AUTH_MODEL_OR_NOT_APPLICABLE}}
- Persistence and migrations: {{PERSISTENCE_MODEL_OR_NOT_APPLICABLE}}
- Background work, queues, or synchronization: {{ASYNC_MODEL_OR_NOT_APPLICABLE}}
- External services and trust boundaries: {{EXTERNAL_BOUNDARIES_OR_NONE}}

Do not violate these invariants:

- {{CRITICAL_INVARIANT_1}}
- {{CRITICAL_INVARIANT_2}}
- {{OPTIONAL_ADDITIONAL_INVARIANTS_OR_REMOVE}}

## Data, APIs, and external boundaries

<!-- Remove this section or inapplicable bullets when the project has none. -->

- API or protocol source of truth: {{API_CONTRACT_SOURCE_OR_NOT_APPLICABLE}}
- Keep types and generated clients derived from the source of truth where the
  toolchain supports it.
- Migration command: `{{MIGRATION_COMMAND_OR_NOT_APPLICABLE}}`
- Migration policy: {{MIGRATION_POLICY_OR_NOT_APPLICABLE}}
- Transaction and consistency rules: {{TRANSACTION_RULES_OR_NOT_APPLICABLE}}
- Error contract or exception model: {{ERROR_MODEL_OR_NOT_APPLICABLE}}
- Never leak secrets, internal stack traces, or sensitive records in errors or
  logs.
- Log structured context sufficient to diagnose failures, using
  {{LOGGING_APPROACH_OR_LIBRARY}}.

## Dependencies

- Prefer the standard library, platform, or an existing dependency when it meets
  the requirement cleanly.
- Before adding a dependency, check maintenance activity, ownership, release
  history, licensing, security posture, and transitive cost.
- Use the repository's package manager and preserve its lockfile.
- Version policy: {{DEPENDENCY_VERSION_POLICY}}
- Dependency approval or security review process:
  {{DEPENDENCY_REVIEW_PROCESS_OR_NONE}}
- Never add a dependency as an unrelated side effect.

## Performance and reliability

<!-- Remove this section if the project has no explicit requirements yet. -->

- Performance budgets: {{LATENCY_THROUGHPUT_MEMORY_OR_SIZE_BUDGETS}}
- Reliability or availability targets: {{RELIABILITY_TARGETS_OR_NONE}}
- Expected data scale: {{EXPECTED_SCALE_OR_UNKNOWN}}
- Keep filtering, sorting, aggregation, and pagination in the appropriate data
  layer; do not transfer unbounded data merely to discard most of it later.
- Avoid repeated per-item I/O when batching, joining, or caching is clearer.
- Add indexes or equivalent access-path optimizations with new query patterns
  when evidence supports them.
- Measure before and after performance-sensitive changes with
  {{PROFILING_OR_BENCHMARK_COMMAND_OR_METHOD}}.
- Document any deliberate tradeoff against a stated budget.

## Testing

- Test framework and location: {{TEST_FRAMEWORKS_AND_PATHS}}
- Unit-test boundaries: {{UNIT_TEST_SCOPE}}
- Integration-test boundaries and dependencies: {{INTEGRATION_TEST_SCOPE}}
- End-to-end scenarios: {{CRITICAL_E2E_SCENARIOS_OR_NOT_APPLICABLE}}
- Test data or fixture strategy: {{TEST_DATA_STRATEGY}}
- Coverage policy: {{COVERAGE_POLICY_OR_NONE}}

For behaviour changes:

- Test the happy path and the most important failure paths.
- Add a regression test for a fixed bug when practical.
- Exercise real boundaries in integration tests rather than mocking away the
  behaviour under test.
- Keep tests deterministic and independent. Do not depend on execution order or
  shared mutable state unless the framework explicitly manages it.

### UI verification

<!-- Remove this subsection when the project has no user interface. -->

- Supported viewports, devices, or platforms: {{SUPPORTED_UI_TARGETS}}
- Accessibility requirements: {{ACCESSIBILITY_REQUIREMENTS}}
- Visual regression or screenshot command: `{{VISUAL_TEST_COMMAND_OR_METHOD}}`
- For visual work, follow the established design system and state concrete
  direction such as reference screens, typography, palette, spacing, component
  treatment, and explicitly unwanted patterns. Vague goals such as "modern" or
  "not generic" are not sufficient acceptance criteria.
- Verify changed screens in relevant responsive states, themes, loading states,
  empty states, error states, and realistic content extremes.
- Look for clipped text, overlap, inaccessible controls, broken focus order, and
  content hidden by overlays or safe areas.

## Code review

When asked to review a change:

- Inspect the diff and the surrounding implementation, contracts, tests, and
  call sites. A change summary is context, not evidence of correctness.
- Prioritize actionable defects that could block a merge: correctness bugs,
  regressions, security issues, contract violations, and missing coverage for
  changed risk.
- For each finding, provide severity, file and line, impact, why it is wrong,
  and concrete evidence or a reproduction path. Include a fix direction when it
  is not obvious.
- Do not inflate the findings with formatting preferences or speculative
  concerns. Label optional suggestions separately from merge-blocking findings.
- If there are no findings, say so and name any residual risk or verification
  gap.

## Security and privacy

- Threat model or security documentation: {{SECURITY_DOCUMENTATION_OR_NONE}}
- Sensitive data handled by the project: {{SENSITIVE_DATA_CATEGORIES_OR_NONE}}
- Authorization must be enforced at {{AUTHORIZATION_ENFORCEMENT_BOUNDARY}}.
- Perform security testing only within explicitly authorized targets and scope.
  If authorization is unclear, stop and ask rather than broadening the target.
- Treat all external input as untrusted and validate it at system boundaries
  with {{VALIDATION_APPROACH_OR_LIBRARY}}.
- Use established cryptographic and authentication libraries; do not invent
  security primitives.
- Do not weaken validation, authentication, authorization, sandboxing, or
  transport security to make a test pass.
- Security reporting process: {{SECURITY_REPORTING_PROCESS}}
- Privacy, retention, or compliance requirements:
  {{PRIVACY_RETENTION_OR_COMPLIANCE_RULES_OR_NONE}}

## Review and handoff

Before finishing:

- Review `git diff` and `git status`.
- Confirm only intended files changed.
- Confirm generated artefacts and documentation are updated when required.
- Put blockers and required user actions first; do not bury them after the work
  summary.
- Summarize behaviour changes, not just filenames.
- List checks run and their results.
- State assumptions, unverified areas, and remaining risks.

Commit message convention: {{COMMIT_MESSAGE_CONVENTION}}

## Keeping this file current

This file should contain durable, repository-specific guidance, not a wishlist.
State each rule once and keep it concise. Prefer direct, verifiable instructions
over generic requests for more effort or care.

Add a failure-log rule only when a real failure reveals a durable,
repository-specific constraint likely to recur and not documented elsewhere.
If instruction maintenance is outside the request, report the candidate instead
of editing this file as an unrelated side effect.

When adding a rule within the authorized task:

1. Write one imperative rule describing the correct behaviour.
2. Move long workflows into a skill or playbook and link them here.
3. Put specialized rules in the nearest supported nested instruction file.
4. Mention the instruction update in the summary.

Keep this root file focused on repository-wide guidance. Remove stale rules and
examples.

## Failure log

<!--
Empty by design. Add a bullet only after a real repository-specific failure.
Do not invent historical failures while filling this template.
-->
