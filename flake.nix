{
  description = "server flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    noshell.url = "github:viperML/noshell";
    elmskell-blog.url = "git+file:///var/lib/git-server/blog.git";
  };

  outputs = {
    self,
    nixpkgs,
    noshell,
    elmskell-blog,
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
      };
      modules = [
        ./services/elmskell.nix
        ./services/ferron.nix
        ./services/rgit.nix
        #        ./services/mattermost.nix

        noshell.nixosModules.default
        {programs.noshell.enable = true;}

        ./configuration.nix
      ];
    };
  };
}
