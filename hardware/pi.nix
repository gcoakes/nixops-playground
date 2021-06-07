{ modulesPath, ... }: {
  nixpkgs.system = "aarch64-linux";

  imports = [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];

  fileSystems."/srv/git".label = "data";

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # Allow sudo without password, if the user is using an authorized ssh key.
  security.sudo.enable = true;
  security.pam.enableSSHAgentAuth = true;

  users.users.root.openssh.authorizedKeys.keyFiles =
    [ ../ssh-workstation.pub ../ssh-laptop.pub ];
}
