{ config, ... }:
let
  internal-ip = "192.168.111.11";
  port = 4533;
in
{
  services.navidrome.enable = true;
  services.navidrome.settings = {
    MusicFolder = "/media/cryptX/music/kinder";
    Address = "0.0.0.0";
  };
  systemd.services.navidrome = {
    serviceConfig = {
      Restart = "always";
      
      RestartSec = "15";
    };
    unitConfig.RequiresMountsFor = [ "/media/cryptX" ];
  };

  state = [ "/var/lib/navidrome" ];
  # networking.firewall.allowedTCPPorts = [ 4040 ];
  # state = [ config.services.airsonic.home ];
  services.nginx.virtualHosts."navidrome" = {
    serverAliases = [
              "navidrome.lan"
      "music"  "music.lan"
      "musik" "musik.lan"
      "music.omo.r"
      "music.makefu.r" "music.makefu"
    ];

    locations."/".proxyPass = "http://localhost:${toString port}";
    locations."/".proxyWebsockets = true;
  };
  networking.firewall.allowedTCPPorts = [ port ];
  # also configure dlna
  services.minidlna.enable = true;
  services.minidlna.settings = {
    inotify = "yes";
    friendly_name = "omo";
    media_dir = [ "A,/media/cryptX/music" ];
  };
}
