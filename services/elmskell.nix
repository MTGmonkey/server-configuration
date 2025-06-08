{pkgs, ...}: let
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
    instances.elmskell = {
      enable = true;
      settings = {
        BIND = "[::1]:9080";
        BIND_NETWORK = "tcp";
        DIFFICULTY = 4;
        METRICS_BIND = "[::1]:9081";
        METRICS_BIND_NETWORK = "tcp";
        POLICY_FNAME = "/etc/anubis/elmskell.botPolicies.yaml";
        TARGET = "http://localhost:8080";
      };
    };
  };

  environment.etc."anubis/elmskell.botPolicies.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" botPolicies-nix;
    mode = "644";
  };

  systemd.services.elmskell = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "/etc/nixos/services/elmskell/elmskell";
      RemainAfterExit = true;
    };
  };
  services.tor = {
    enable = true;
    enableGeoIP = false;
    relay.onionServices = {
      elmskell = {
        version = 3;
        map = [
          {
            port = 80;
            target = {
              addr = "127.0.0.1";
              port = 8080;
            };
          }
        ];
      };
    };
  };
}
