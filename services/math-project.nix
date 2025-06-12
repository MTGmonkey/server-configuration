{
  pkgs,
  lib,
  math-project,
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
    instances.math-project = {
      enable = true;
      settings = {
        BIND = "[::1]:9282";
        BIND_NETWORK = "tcp";
        DIFFICULTY = 4;
        METRICS_BIND = "[::1]:9283";
        METRICS_BIND_NETWORK = "tcp";
        POLICY_FNAME = "/etc/anubis/math-project.botPolicies.yaml";
        TARGET = "http://localhost:8080";
      };
    };
  };

  environment.etc."anubis/math-project.botPolicies.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" botPolicies-nix;
    mode = "644";
  };

  systemd.services.math-project = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe math-project}";
      RemainAfterExit = true;
    };
  };
}
