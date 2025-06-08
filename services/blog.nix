{
  elmskell-blog,
  lib,
  pkgs,
  ...
}: let
  ferron-conf-nix = {
    global = {
      secure = false;
      wwwroot = "${elmskell-blog.packages.x86_64-linux.default}/wwwroot";
    };
  };
in {
  systemd.services.ferron = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.ferron} --config=/etc/ferron.yaml";
      RemainAfterExit = true;
    };
  };

  environment.etc."ferron.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" ferron-conf-nix;
    mode = "644";
  };
}
