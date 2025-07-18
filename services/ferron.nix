{
  lib,
  pkgs,
  ...
}: let
  ferron-conf-nix = {
    global = {
      secure = true;
      enableAutomaticTLS = true;
      automaticTLSContactCacheDirectory = "/etc/ferron/contactCacheDir";
      useAutomaticTLSHTTPChallenge = true;
      disableProxyCertificateVerification = true;
      loadModules = ["rproxy"];
    };
    hosts = [
      {
        domain = "mtgmonkey.net";
        proxyTo = "http://localhost:9080/";
      }
      {
        domain = "blog.mtgmonkey.net";
        proxyTo = "http://localhost:9181/";
      }
      {
        domain = "math.mtgmonkey.net";
        proxyTo = "http://localhost:9282/";
      }
      {
        domain = "git.mtgmonkey.net";
        proxyTo = "http://localhost:8000/";
      }
      {
        domain = "chat.mtgmonkey.net";
        proxyTo = "http://localhost:9780/";
      }
      {
        domain = "spacebar-api.mtgmonkey.net";
        proxyTo = "http://localhost:3001/";
      }
      {
        domain = "translate.mtgmonkey.net";
        proxyTo = "http://localhost:9109/";
      }
    ];
  };
in {
  systemd.services.ferron = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.ferron} --config=/etc/ferron.yaml";
      RemainAfterExit = true;
    };
    wantedBy = ["multi-user.target"];
  };

  environment.etc."ferron.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" ferron-conf-nix;
    mode = "644";
  };
}
