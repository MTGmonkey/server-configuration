{
  virtualisation.docker = {
    enable = true;
  };
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.rgit = {
    image = "ghcr.io/w4/rgit:main";
    ports = [
      "8000:8000"
      "9418:9418"
    ];
    volumes = [
      "/var/lib/git-server:/git:ro"
    ];
    cmd = [
      "[::]:8000"
      "/git"
      "-d /tmp/rgit-cache.db"
    ];
    environment = {
      REFRESH_INTERVAL = "5m";
    };
    user = "git:git";
  };
}
