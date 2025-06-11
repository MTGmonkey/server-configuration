{
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
    instances.translate = {
      enable = true;
      settings = {
        BIND = "[::1]:9109";
        BIND_NETWORK = "tcp";
        DIFFICULTY = 4;
        METRICS_BIND = "[::1]:9119";
        METRICS_BIND_NETWORK = "tcp";
        POLICY_FNAME = "/etc/anubis/elmskell.botPolicies.yaml";
        TARGET = "http://localhost:8108";
      };
    };
  };

  environment.etc."anubis/translate.botPolicies.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" botPolicies-nix;
    mode = "644";
  };

  systemd.services.translate = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.libretranslate}";
      RemainAfterExit = true;
    };
  };
}
