{ lib, pkgs, ... }: {
  deployment.keys."ddclient.conf" = {
    text = builtins.readFile ../secrets/ddclient.conf;
    user = "ddclient";
    permissions = "0600";
  };

  users.users.ddclient = {
    isSystemUser = true;
    group = "ddclient";
    extraGroups = [ "keys" ];
  };

  services.ddclient = {
    enable = true;
    protocol = "googledomains";
    domains = [ "oakes.family" ];
    extraConfig = builtins.readFile ../secrets/ddclient.conf;
  };

  systemd.services.ddclient = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "ddclient";
      Group = "keys";
      wants = [ "ddclient.conf-key.service" ];
      after = [ "ddclient.conf-key.service" ];
    };
  };
}
