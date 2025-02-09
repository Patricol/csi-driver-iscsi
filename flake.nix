{
  description = "A Nix-flake-based Go development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      goVersion = 21; # Change this to update the whole stack

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      });
    in
    {
      overlays.default = final: prev: {
        go = final."go_1_${toString goVersion}";
      };

      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gotools
            golangci-lint
          ];

          env = {
            REGISTRY = "patricol/iscsiplugin";
            IMAGE_VERSION = "latest";
          };

          # Add any shell logic you want executed any time the environment is activated
          shellHook = ''
            alias make-container="make push REGISTRY_NAME=patricol IMAGE_TAGS=canary"
          '';
          # NOTE: mount_linux.go is here: https://github.com/kubernetes/mount-utils/blob/master/mount_linux.go

        };
      });
    };
}
