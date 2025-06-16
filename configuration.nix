{
  pkgs,
  ssh-pub-keys,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  networking.hostName = "server";
  networking.domain = "";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443 9418];
    allowedUDPPorts = [80 443 9418];
  };
  boot.loader.grub.devices = ["nodev"];

  services.openssh = {
    enable = true;
    allowSFTP = false;
    ports = [5522];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = true;
    };
    extraConfig = ''
      AllowTcpForwarding no
      AllowAgentForwarding no
      MaxAuthTries 3
      MaxSessions 4
      TCPKeepAlive no
    '';
  };

  services.fail2ban = {
    enable = true;
    maxretry = 10;
    bantime-increment.enable = true;
  };

  users.users.mtgmonkey = {
    isNormalUser = true;
    description = "mtgmonkey";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = ssh-pub-keys;
  };

  users.users.git = {
    isSystemUser = true;
    group = "git";
    description = "git";
    home = "/var/lib/git-server";
    createHome = true;
    packages = [pkgs.git];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = ssh-pub-keys;
  };

  users.groups.git = {};

  system.stateVersion = "23.11";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.settings.allow-import-from-derivation = true;
}
