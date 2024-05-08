# Teleorb

Teleorb is a multiplayer speedrun based platformer.

# Projects

- `/game` - Acts as both the game server and the player client. Built with Godot.
- `/warden` - Service that handles authentication for all players. Built with Bun, Typescript, and Elysia.
- `/gatekeeper` - Service that handles authenticating servers and creating them. Built with Bun, Typescript, and Elysia.

Deployments are done on fly.io and digitalocean.

# Versioning

Teleorb uses its own versioning system since semver doesn't make much sense for a project like this. Versions across all projects are syncrhonized (even if a release doesn't actually change that project) and it is assumed that versions in all projects must be the same for the system to work properly.

Versions look like the following:

```
ERA-VERSION-HOTFIX
```

These could be:

```
alpha-1-2
beta-1-0  # you always need a trailing 0

```

`HOTFIX` changes every time a small patch is made and resets whenver `VERSION` increases. `VERSION` increases whenever new features are added and resets whenever `ERA` changes. `ERA` changes whenever I feel like it. Eras used to move up using greek letters, but now use elements to distinguish them from semver (which typically uses "alpha" and "beta" to denote prereleases).
