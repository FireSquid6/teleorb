# Teleorb

Teleorb is a multiplayer speedrun based platformer.

# Projects

- `/game` - Acts as both the game server and the player client
- `/server` - The runtime for each deployed server. Runs the actual game server as a subprocess.
- `/chronos` - Service that handles leaderboard and ratings calculation
- `/warden` - Service that handles authentication for all players
- `/gatekeeper` - Service that handles authenticating servers and creating them
- `/site` - The website for teleorb

All deployments are done through [fly.io](https://fly.io)

# Nitpicks for Code Reviews

- Please use the terms `speed` and `velocity` appropriately when naming variables. `acceleration` could refer to a scalar or vector quantity.
- Start private methods and variables (those only meant to be internal) with an underscore or make them a single character long
- Don't explain _what_ the code is doing in comments, explain _why_ the code is doing

# Versioning

Semver doesn't really make sense for a game that doesn't expose a public interface. We use a custom versioning system.

Versions look like the following:

```
ERA-VERSION-HOTFIX
```

These could be:

```
alpha-1-2
beta-1-0  # you always need a trailing 0

```

`HOTFIX` changes every time a small patch is made and resets whenver `VERSION` increases. `VERSION` increases whenever new features are added and resets whenever `ERA` changes. `ERA` changes whenever I feel like it. Eras typically move up by using greek letters.
