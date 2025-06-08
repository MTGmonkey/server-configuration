{
  elmskell-blog,
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
  ferron-conf-nix = {
    global = {
      port = 8181;
      secure = false;
      wwwroot = "${elmskell-blog.packages.x86_64-linux.default}/wwwroot";
    };
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
        TARGET = "http://localhost:8181";
      };
    };
  };
  environment.etc."anubis/blog.botPolicies.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" botPolicies-nix;
    mode = "644";
  };
  systemd.services.blog-ferron = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.ferron} --config=/etc/blog.ferron.yaml";
      RemainAfterExit = true;
    };
  };
  environment.etc."blog.ferron.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" ferron-conf-nix;
    mode = "644";
  };
}
