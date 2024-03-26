# Teleorb

Teleorb is a multiplayer speedrun based platformer.

# Technology

- Game built in Godot 4 `/game`. This can be run as a standard executable on the client, or as a headless server
- Authentication and database using bun, elysia, lucia, and drizzle `/database`
- Lobby server will probably be built in bun + elysia as well `/lobby`

All deployments are done through [fly.io](https://fly.io)
