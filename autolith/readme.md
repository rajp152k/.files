# Autolith dispatch policy

Use `dispatch-low` for clear, bounded lookups, extraction, status checks, and mechanical edits with explicit checks. Use `dispatch-medium` for implementation, debugging, unclear scope, sensitive work, and failed checks. Return evidence when you escalate. Do not repeat blind low-effort attempts.

Keep main coordinators at medium unless the user chooses another setting. Use direct tools for small exact work. Use a specialist role when you need its tool limits or output contract. Inspect its actual model and effort first.

## Files and deployment

- `agents/dispatch-low.sexp`: inherit the parent model, use low effort, allow child-safe tools, and disable nested dispatch.
- `agents/dispatch-medium.sexp`: inherit the parent model, use medium effort, allow child-safe tools and nested dispatch.
- `extensions/dispatch-policy.lisp`: add request-local instructions and provide reload and inspection functions.
- `extensions/commands/config-reload.lisp`: load the policy when `init.lisp` loads this extension.

Stow the `autolith` package into the home directory. On this machine, `~/.config/autolith/extensions` already points into this package. The added `~/.config/autolith/agents` link points to `../../.files/autolith/.config/autolith/agents`.

Roles are read from disk at each `task.agents` and `task.run` call. Project roles take precedence over user roles. A malformed project role blocks the same user role. Inspect `task.agents` before dispatch. Running children keep the settings chosen when they started.

## Reload

For the first policy-only load in an existing image, evaluate:

\```lisp
(let ((*extension-registration-source* :user))
  (load (merge-pathnames "extensions/dispatch-policy.lisp"
                        (config :config-root))
        :verbose nil :print nil))
(dispatch-policy-status)
\```

For later policy-only reloads, evaluate:

\```lisp
(dispatch-policy-reload)
\```

This reload replaces the same contributor registration and reports effective role routes. It does not set the main model or effort. Inspect `(context-status)` after the next provider request to check that `dispatch-policy-v1` was included.

`/reval` runs `user-init-load`. It reloads site initialization, trusted directory initialization, and user initialization. It removes and rebuilds site/user context, command, MCP, and provider registrations. This package's initialization loads the command extension, which loads the dispatch policy. The next provider request can receive the policy. Context advice uses the normal advice budget and can be omitted when that budget is full.

`/reval` also executes all other initialization code. The current `init.lisp` sets the main model and effort. Use the policy-only load above if you must preserve a different session choice. `/reval` does not restart sessions or children, reload tracked source or private commits, or rebuild the cached base system-prompt template. Role files do not need `/reval`.

## Model and RLM routing

The two roles use `@parent`, not a fixed provider or model. At verification time, this session resolved `gpt-6.1-sol` to provider `chatgpt`; the role routes were that model with low and medium effort. Other parent models need their own effort-support check.

In the checked Autolith releases, `@task`, `@parent`, and `@auto` select the parent model. `@smol` selects `gpt-5.6-luna`; `@slow` and `@designer` select `gpt-6.1-terra`. These aliases do not mean low or medium effort.

The checked RLM implementation supports explicit top-level `model` and `effort` fields. Use them only when the exposed tool schema includes them. Use exact supported model IDs, not task-role aliases. Nested RLM calls inherit the enclosing model and effort. This policy does not change RLM defaults.

The instructions guide task selection. They do not enforce task classification. The native role settings enforce the selected child's effort. The policy does not change existing specialist roles, switch main models, or dispatch work by itself.

## Checks

Load the extension and `tests/autolith-dispatch-policy.lisp` from the repository root in an Autolith Lisp worker. Call `check-dispatch-policy` with a configuration whose config root includes these user roles and whose workspace has no same-name project override. The checks cover role discovery, model inheritance, explicit child effort independent of parent effort, spawn limits, reload deduplication, and unchanged main settings. They make no model requests.

## Rollback

Revert the policy commit. In each image that loaded the policy, evaluate:

\```lisp
(unregister-context-contributor "dispatch-policy-context")
\```

Remove the added `~/.config/autolith/agents` link if you created it for this policy. Do not remove other user roles. Existing children continue with their original settings. The inspection functions can remain defined until the image next starts; they do not register advice or change settings when idle.
