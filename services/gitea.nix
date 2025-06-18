{
  pkgs,
  lib,
  ...
}: {
  systemd.services.gitea = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.forgejo} -c /etc/gitea/config.ini";
      RemainAfterExit = true;
      Restart = "always";
      RestartMaxDelaySec = "1m";
      RestartSec = "100ms";
      RestartSteps = 9;
      User = "git";
      Group = "git";
    };
    wantedBy = ["multi-user.target"];
  };
  environment.etc."gitea/config.ini.default" = {
    text = ''
      WORK_PATH = /var/lib/git-server
      [server]
      HTTP_PORT = 8000
    '';
    mode = "644";
  };
}
