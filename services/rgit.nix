{rgit, ...}: {
  systemd.services.rgit = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${rgit.packages.x86_64-linux.default}/bin/rgit -d /var/lib/git-server/.db/rgit-cache.db [::1]:3000 /var/lib/git-server";
      RemainAfterExit = true;
      Restart = "always";
      RestartMaxDelay = "1m";
      RestartSec = "100ms";
      RestartSteps = 9;
      User = "git";
      Group = "git";
    };
    wantedBy = ["multi-user.target"];
  };
}
