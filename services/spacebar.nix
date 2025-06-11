{
  ssh-pub-keys,
  spacebar-server,
  pkgs,
  lib,
  ...
}: let
  botPolicies-nix = {
    dnsbl = false;
    status_codes = {
      CHALLENGE = 200;
      DENY = 200;
    };
    bots = [
      {
        name = "catch-everything";
        user_agent_regex = ".*";
        action = "CHALLENGE";
      }
    ];
  };
in {
  services.anubis = {
    instances.spacebar = {
      enable = true;
      settings = {
        BIND = "[::1]:9780";
        BIND_NETWORK = "tcp";
        DIFFICULTY = 4;
        METRICS_BIND = "[::1]:9781";
        METRICS_BIND_NETWORK = "tcp";
        POLICY_FNAME = "/etc/anubis/spacebar.botPolicies.yaml";
        TARGET = "http://localhost:8282";
      };
    };
  };
  environment.etc."anubis/spacebar.botPolicies.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" botPolicies-nix;
    mode = "644";
  };
  systemd.services.spacebar-server = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe spacebar-server.packages.x86_64-linux.default}";
      RemainAfterExit = true;
      User = "spacebar";
      Group = "spacebar";
    };
    environment = {
      DATABASE = "/var/lib/spacebar-server/database.db";
      STORAGE_LOCATION = "/var/lib/spacebar-server/files/";
    };
  };
  users.users.spacebar = {
    isSystemUser = true;
    group = "spacebar";
    description = "spacebar";
    home = "/var/lib/spacebar-server";
    createHome = true;
    packages = [pkgs.git spacebar-server.packages.x86_64-linux.default];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = ssh-pub-keys;
  };
  users.groups.spacebar = {};
  services.jank-client = {
    enable = true;
    port = 8282;
  };
}
