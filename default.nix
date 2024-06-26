# Help! I'm a nix user and it isn't working!
#
# try running these commands:
# sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
# sudo nix-channel --update
# then run nix-shell again

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{ nixpkgs ? import <nixpkgs> { } }:
with nixpkgs; mkShell {
  DOCKER_BUILDKIT = "1";
  packages = [
    unstable.bun
    nodejs_20

    libgcc

    flyctl
    doctl

    wget
    unzip


    patchelf
    docker  # v24.0.5 
    # You'll also need Godot 4 installed if you're making the server or the game
    # This isn't specified in the default.nix because Godot is a desktop app
  ];
  shellHook = ''
    export USE_STEAM_RUN=1
    export PATH=$PATH:$PWD/scripts
  '';
}

