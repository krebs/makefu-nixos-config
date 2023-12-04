{ pkgs, lib, config, ... }:
let
  fqdn = "rss.euer.krebsco.de";
  ratt-path = "/var/lib/ratt/";
  out-path = "${ratt-path}/all.xml";
in {
  systemd.tmpfiles.rules = ["d ${ratt-path} 0750 nginx nginx - -" ];
  systemd.services.run-ratt = {
    enable = true;
    path = with pkgs; [ ratt xmlstarlet ];
    script = builtins.readFile ./ratt-hourly.sh;
    scriptArgs = "${./urls} ${out-path}";

    serviceConfig.User = "nginx";
    serviceConfig.WorkingDirectory= ratt-path;
    startAt = "00/3:07"; # every 3 hours, fetch latest
  };

  services.nginx.virtualHosts."${fqdn}" = {
    locations."=/ratt/all.xml" = {
      alias = out-path;
    };
  };
}

