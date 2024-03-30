# Teleorb

Teleorb is a multiplayer speedrun based platformer.

# Technology

- Game built in Godot 4 `/game`. This can be run as a standard executable on the client, or as a headless server
- Authentication and database using bun, elysia, lucia, and drizzle `/database`
- Lobby server will probably be built in bun + elysia as well `/lobby`

All deployments are done through [fly.io](https://fly.io)

# Nitpicks for Code Reviews

- Please use the terms `speed` and `velocity` appropriately when naming variables. `acceleration` could refer to a scalar or vector quantity.
- Start private methods and variables (those only meant to be internal) with an underscore or make them a single character long
- Don't explain _what_ the code is doing in comments, explain _why_ the code is doing
