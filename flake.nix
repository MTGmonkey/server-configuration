{
  description = "server flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    noshell.url = "github:viperML/noshell";
    elmskell-blog.url = "git+file:///var/lib/git-server/blog.git";
    spacebar-server.url = "github:spacebarchat/server";
  };

  outputs = {
    self,
    nixpkgs,
    noshell,
    elmskell-blog,
    spacebar-server,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations."server" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit self;
        inherit system;
        inherit elmskell-blog;
        inherit spacebar-server;
        ssh-pub-keys = import ./ssh-pub-keys.nix;
      };
      modules = [
        ./services/ferron.nix

        ./services/elmskell.nix
        ./services/blog.nix

        ./services/spacebar.nix
        ./services/rgit.nix

        noshell.nixosModules.default
        {programs.noshell.enable = true;}

        ./configuration.nix
      ];
    };
  };
}
