{
  description = "server flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    noshell.url = "github:viperML/noshell";
    spacebar-server.url = "github:spacebarchat/server";

    elmskell-blog.url = "git+https://git.mtgmonkey.net/Andromeda/blog.git";
    jank-client.url = "git+https://git.mtgmonkey.net/Andromeda/jank-client-fork.git";
    math-project.url = "git+https://git.mtgmonkey.net/Andromeda/math-project.git";
    best-blog.url = "git+https://git.mtgmonkey.net/Andromeda/best-blog.git";
  };

  outputs = {
    self,
    nixpkgs,
    noshell,
    spacebar-server,
    jank-client,
    math-project,
    best-blog,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations."server" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit self;
        inherit system;
        inherit spacebar-server;
        inherit math-project;
        inherit best-blog;
        ssh-pub-keys = import ./ssh-pub-keys.nix;
      };
      modules = [
        ./configuration.nix

        ./services/blog.nix
        ./services/elmskell.nix
        ./services/ferron.nix
        ./services/gitea.nix
        #./services/rgit.nix
        ./services/math-project.nix
        ./services/spacebar.nix
        ./services/translate.nix

        jank-client.nixosModules.x86_64-linux.default
        math-project.nixosModules.x86_64-linux.default
        noshell.nixosModules.default
        {
          programs.noshell.enable = true;
          services.math-project.enable = true;
        }
      ];
    };
  };
}
