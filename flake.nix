{
  description = "server flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    noshell.url = "github:viperML/noshell";
    spacebar-server.url = "github:spacebarchat/server";
    rgit.url = "github:w4/rgit";

    elmskell-blog.url = "git+file:///var/lib/git-server/blog.git";
    jank-client.url = "git+file:///var/lib/git-server/jank-client-fork.git";
    math-project.url = "git+file:///var/lib/git-server/math-project.git";
  };

  outputs = {
    self,
    nixpkgs,
    noshell,
    elmskell-blog,
    spacebar-server,
    jank-client,
    math-project,
    rgit,
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
        inherit math-project;
        inherit rgit;
        ssh-pub-keys = import ./ssh-pub-keys.nix;
      };
      modules = [
        ./services/ferron.nix

        ./services/elmskell.nix
        ./services/blog.nix

        jank-client.nixosModules.x86_64-linux.default
        ./services/spacebar.nix
        ./services/rgit.nix

        ./services/translate.nix

        noshell.nixosModules.default
        {programs.noshell.enable = true;}

        math-project.nixosModules.x86_64-linux.default
        {services.math-project.enable = true;}
        ./services/math-project.nix

        ./configuration.nix
      ];
    };
  };
}
