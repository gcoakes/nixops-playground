{ pkgs, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
      virtualHosts = {
        "oakes.family" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://localhost:8080";
        };
      };
    };
    lighttpd = {
      enable = true;
      port = 8080;
      cgit = {
        enable = true;
        subdir = "";
        configText = ''
          source-filter=${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py
          about-filter=${pkgs.cgit}/lib/cgit/filters/about-formatting.sh
          cache-size=1000
          scan-path=/srv/git
        '';
      };
    };
  };

  users.users.git = {
    isSystemUser = true;
    description = "git user";
    home = "/src/git";
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keyFiles =
      [ ../ssh-laptop.pub ../ssh-workstation.pub ];
  };

  security.acme = {
    acceptTerms = true;
    email = "gregcoakes@gmail.com";
  };
}
