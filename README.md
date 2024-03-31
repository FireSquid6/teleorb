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
