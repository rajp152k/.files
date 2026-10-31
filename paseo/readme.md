# Paseo

This Stow package tracks the non-secret Paseo daemon config. It adds Autolith
as an ACP provider. Paseo runtime data, pairing keys, logs, and sessions remain
in `~/.paseo` and are not tracked.

## Install

From `~/.files`, preview and apply the package:

```sh
stow --simulate --verbose --no-folding --target="$HOME" paseo
stow --no-folding --target="$HOME" paseo
```

The provider command uses `/Users/nilenso/.local/bin/autolith`. Update that
path in `.paseo/config.json` on machines with a different Autolith install.

Authenticate Autolith with `autolith auth`, then start Paseo with `paseo` or
`paseo daemon start`. Select **Autolith** from Paseo's agent provider list.
