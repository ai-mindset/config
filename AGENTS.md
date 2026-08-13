<!--
Inspired by the BetterStack video that provided the source screenshots:
https://inv.nadeko.net/watch?v=D4uBfIe7SzA
-->

# {{PROJECT_NAME}} agent guide

<!--
TEMPLATE SETUP — delete this comment after customization.

For a human:
- Replace every {{PLACEHOLDER}} with repository-specific information.
- Delete optional rows, bullets, and sections that do not apply.

For an AI agent:
1. Inspect the repository before editing this file. Read manifests, lockfiles,
   CI workflows, existing documentation, and representative source and test
   files.
2. Fill placeholders only with facts supported by repository evidence. Do not
   invent commands, paths, architecture, product requirements, or policies.
3. Ask the user about consequential details that cannot be inferred safely.
4. Preserve useful generic rules unless they conflict with verified project
   practice.
5. Keep repository-wide guidance here. Put narrower guidance in nested
   AGENTS.md or AGENTS.override.md files near the code it governs.
6. Remove this setup comment after customization.

Before finishing:
- Search for unresolved placeholders with:
  `rg -n '\{\{[^}]+\}\}' AGENTS.md`
- Verify every documented command from the repository root.
- Confirm every referenced path exists.
- Remove examples and sections that are not relevant.
- Do not include secrets, credentials, or private environment values.
-->

{{ONE_SENTENCE_DESCRIPTION_OF_THE_PROJECT_AND_ITS_PURPOSE}}

- Primary users: {{PRIMARY_USERS}}
- Project stage and deployment model: {{PROJECT_STAGE_AND_DEPLOYMENT_MODEL}}
- Primary documentation: `{{PRIMARY_DOCUMENTATION_PATH}}`
- Issue or work tracking: {{ISSUE_TRACKER_OR_WORKFLOW}}

## Repository overview

| Area                   | Purpose                | Technology                | Path                     |
| ---------------------- | ---------------------- | ------------------------- | ------------------------ |
| {{COMPONENT_NAME}}     | {{COMPONENT_PURPOSE}}  | {{LANGUAGE_OR_FRAMEWORK}} | `{{PATH}}`               |
| {{COMPONENT_NAME}}     | {{COMPONENT_PURPOSE}}  | {{LANGUAGE_OR_FRAMEWORK}} | `{{PATH}}`               |
| {{ADD_OR_REMOVE_ROWS}} | {{ADD_OR_REMOVE_ROWS}} | {{ADD_OR_REMOVE_ROWS}}    | `{{ADD_OR_REMOVE_ROWS}}` |

- Nested agent instructions: {{NESTED_AGENTS_FILES_OR_NONE}}
- Skills or longer playbooks: {{SKILLS_OR_PLAYBOOKS_PATH_OR_NONE}}
- Generated code or vendored areas: {{GENERATED_OR_VENDORED_PATHS_OR_NONE}}

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
- A change affects a public API, persisted data, schema, protocol, compatibility
  boundary, or shared contract.
- Product behaviour, copy, security posture, or acceptance criteria are missing.
- The work adds or replaces a production dependency.
- Required access, authority, or external coordination has not been granted.

If a low-risk assumption is necessary, state it in the final summary.

## Workflow

1. Read the relevant instructions and documentation.
2. Inspect existing implementations and tests before designing a change.
3. For a bug, reproduce the failure or establish a failing check first when
   practical.
4. Implement incrementally and keep the change reversible.
5. Run the smallest relevant check after each meaningful edit.
6. Run the complete required quality gates before reporting completion.
7. Review the diff for scope, correctness, generated artefacts, and accidental
   secret exposure.

Do not disable, skip, weaken, or mark tests as exclusive merely to make a check
pass. If a test is incorrect, explain why before changing it.

## Commands and quality gates

Run commands from `{{DEFAULT_COMMAND_DIRECTORY_OR_REPOSITORY_ROOT}}` unless a
row says otherwise.

| Purpose              | Command                           | When required     |
| -------------------- | --------------------------------- | ----------------- |
| Install or bootstrap | `{{INSTALL_COMMAND}}`             | {{WHEN_REQUIRED}} |
| Format               | `{{FORMAT_COMMAND}}`              | {{WHEN_REQUIRED}} |
| Lint                 | `{{LINT_COMMAND}}`                | {{WHEN_REQUIRED}} |
| Type-check           | `{{TYPECHECK_COMMAND}}`           | {{WHEN_REQUIRED}} |
| Unit tests           | `{{UNIT_TEST_COMMAND}}`           | {{WHEN_REQUIRED}} |
| Integration tests    | `{{INTEGRATION_TEST_COMMAND}}`    | {{WHEN_REQUIRED}} |
| End-to-end tests     | `{{E2E_TEST_COMMAND}}`            | {{WHEN_REQUIRED}} |
| Build                | `{{BUILD_COMMAND}}`               | {{WHEN_REQUIRED}} |
| Other required gate  | `{{OTHER_COMMAND_OR_REMOVE_ROW}}` | {{WHEN_REQUIRED}} |

- Long-running development command: `{{DEV_COMMAND_OR_NONE}}`
- Do not use a non-terminating development process as the only verification.
  Prefer bounded checks, or start and stop the process explicitly.
- Required environment or services for tests: {{TEST_PREREQUISITES_OR_NONE}}

A change is complete only when applicable gates pass. Never report a red or
unrun required gate as successful; state what failed or could not be run.

## Languages and frameworks

| Scope                   | Language, framework, and version | Authoritative configuration |
| ----------------------- | -------------------------------- | --------------------------- |
| `{{PATH}}`              | {{TOOLCHAIN_AND_VERSION}}        | `{{CONFIG_PATH}}`           |
| `{{PATH}}`              | {{TOOLCHAIN_AND_VERSION}}        | `{{CONFIG_PATH}}`           |
| `{{ADD_OR_REMOVE_ROW}}` | {{ADD_OR_REMOVE_ROW}}            | `{{ADD_OR_REMOVE_ROW}}`     |

- Follow the repository's formatter, linter, compiler, and framework
  conventions.
- Prefer established local patterns over introducing a new abstraction or
  vocabulary.
- Keep strictness settings enabled. Fix type or validation errors instead of
  suppressing them.
- Use an escape hatch only when it is unavoidable and document the concrete
  reason or upstream issue.
- Validate untrusted input at system boundaries with
  {{VALIDATION_APPROACH_OR_LIBRARY}}.
- Language- or framework-specific rules:
  {{LANGUAGE_AND_FRAMEWORK_RULES_OR_NESTED_AGENTS_PATH}}

## Naming and domain language

Use one canonical term per concept. Add verified project vocabulary below and
remove the placeholder row.

| Concept            | Use                  | Avoid                         |
| ------------------ | -------------------- | ----------------------------- |
| {{DOMAIN_CONCEPT}} | `{{CANONICAL_TERM}}` | {{AMBIGUOUS_OR_LEGACY_TERMS}} |

| Item                   | Convention                   | Example       |
| ---------------------- | ---------------------------- | ------------- |
| Files and directories  | {{CONVENTION}}               | `{{EXAMPLE}}` |
| Functions and methods  | {{CONVENTION}}               | `{{EXAMPLE}}` |
| Types and components   | {{CONVENTION}}               | `{{EXAMPLE}}` |
| Booleans               | {{CONVENTION}}               | `{{EXAMPLE}}` |
| API routes or commands | {{CONVENTION_OR_REMOVE_ROW}} | `{{EXAMPLE}}` |
| Database objects       | {{CONVENTION_OR_REMOVE_ROW}} | `{{EXAMPLE}}` |
| User-facing copy       | {{CONVENTION_OR_REMOVE_ROW}} | `{{EXAMPLE}}` |

## Project structure

```text
{{REPOSITORY_TREE_WITH_ONE_LINE_PURPOSES}}
```

- New code belongs in: {{NEW_CODE_LOCATION_RULES}}
- Tests belong in: {{TEST_LOCATION_RULES}}
- Shared code belongs in: {{SHARED_CODE_RULES}}
- Generated files: {{GENERATED_FILE_RULES}}
- Files or directories that must not be edited directly:
  {{DO_NOT_EDIT_PATHS_OR_NONE}}
- Rules for adding files at the repository root:
  {{ROOT_FILE_RULES_OR_REMOVE_BULLET}}

## Architecture and invariants

{{SHORT_ARCHITECTURE_OVERVIEW}}

- Primary request or data flow: {{REQUEST_OR_DATA_FLOW}}
- Authentication and authorization: {{AUTH_MODEL_OR_NOT_APPLICABLE}}
- Persistence and migrations: {{PERSISTENCE_MODEL_OR_NOT_APPLICABLE}}
- Background work, queues, or synchronization: {{ASYNC_MODEL_OR_NOT_APPLICABLE}}
- External services and trust boundaries: {{EXTERNAL_BOUNDARIES_OR_NONE}}

Do not violate these invariants:

- {{CRITICAL_INVARIANT}}
- {{CRITICAL_INVARIANT}}
- {{ADD_OR_REMOVE_INVARIANTS}}

**Where things live:**

| Need                      | Look in                  |
| ------------------------- | ------------------------ |
| {{CONCERN}}               | `{{PATH}}`               |
| {{CONCERN}}               | `{{PATH}}`               |
| {{CONCERN}}               | `{{PATH}}`               |
| Configuration             | `{{CONFIGURATION_PATH}}` |
| CI and release automation | `{{CI_OR_RELEASE_PATH}}` |

## Data, APIs, and external boundaries

<!-- Remove this section or inapplicable bullets when the project has none. -->

- API or protocol source of truth: {{API_CONTRACT_SOURCE_OR_NOT_APPLICABLE}}
- Validate request, event, file, and third-party input before use.
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
- Ask before adding or replacing a production dependency.
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
- Verify changed screens in relevant responsive states, themes, loading states,
  empty states, error states, and realistic content extremes.
- Look for clipped text, overlap, inaccessible controls, broken focus order, and
  content hidden by overlays or safe areas.

## Security and privacy

- Threat model or security documentation: {{SECURITY_DOCUMENTATION_OR_NONE}}
- Sensitive data handled by the project: {{SENSITIVE_DATA_CATEGORIES_OR_NONE}}
- Authorization must be enforced at {{AUTHORIZATION_ENFORCEMENT_BOUNDARY}}.
- Treat all external input as untrusted.
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
- Summarize behaviour changes, not just filenames.
- List checks run and their results.
- State assumptions, unverified areas, and remaining risks.
- Report adjacent issues separately without fixing them unless requested.

Commit message convention: {{COMMIT_MESSAGE_CONVENTION}}

## Keeping this file current

This file should contain durable, repository-specific guidance, not a wishlist.
State each rule once and keep it concise.

When an agent makes a mistake, gets corrected, or discovers an undocumented
repository constraint:

1. Add one imperative rule to the failure log below.
2. Keep it specific to this repository and describe the correct behaviour.
3. Move long workflows into a skill or playbook and link them here.
4. Put specialized rules in the nearest nested `AGENTS.md`.
5. Include the instruction update with the related change and mention it in the
   summary.

Keep this root file focused on repository-wide guidance. Remove stale rules and
examples. Prefer nested instruction files for subsystem-specific details.

## Failure log

<!--
Empty by design. Add a bullet only after a real repository-specific failure.
Do not invent historical failures while filling this template.
-->
