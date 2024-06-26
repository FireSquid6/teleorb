# How Dedicated Servers Work

1. When the game starts, it checks for a json file in either:
   1. The path in the environment variable `TELEORB_SERVER_JSON_PATH`
   2. `<config-directory>/teleorb-dedicated-server.json` where `<config-directory>` is whatever your system returns from `OS.get_config_dir()` (typically `~/.config`)
2. If that file doesn't exist, it runs as normal
3. If the file exists (and is enabled), a dedicated server is started

The dedicated server will:

- not spawn a player for itself
- load into a specified level

# `dedicated-server.json` options

`enabled` (bool) - whether to use a dedicated server or not
`level` (string) - the level to build and use for the lobby **not implemented**
`mode` (string) - either `match` or `free` **not implemented**

See the example files for more info
