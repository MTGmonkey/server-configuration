{
  best-blog,
  lib,
  pkgs,
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
    instances.blog = {
      enable = true;
      settings = {
        BIND = "[::1]:9181";
        BIND_NETWORK = "tcp";
        DIFFICULTY = 4;
        METRICS_BIND = "[::1]:9182";
        METRICS_BIND_NETWORK = "tcp";
        POLICY_FNAME = "/etc/anubis/blog.botPolicies.yaml";
        TARGET = "http://localhost:9345";
      };
    };
  };
  environment.etc."anubis/blog.botPolicies.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" botPolicies-nix;
    mode = "644";
  };
  systemd.services.blog = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe best-blog.packages.x86_64-linux.default}";
      RemainAfterExit = true;
      Restart = "always";
      RestartMaxDelaySec = "1m";
      RestartSec = "100ms";
      RestartSteps = 9;
    };
    wantedBy = ["multi-user.target"];
  };
}
