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
        domain = "git.mtgmonkey.net";
        proxyTo = "http://localhost:8000/";
      }
      {
        domain = "chat.mtgmonkey.net";
        proxyTo = "http://localhost:9780/";
      }
      {
        domain = "www.mtgmonkey.net";
        proxyTo = "http://localhost:9080/";
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
  };

  environment.etc."ferron.yaml" = {
    source = (pkgs.formats.yaml {}).generate "" ferron-conf-nix;
    mode = "644";
  };
}
