let
  internal-ip = "192.168.111.11";
in {
  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts."hass" = {
    serverAliases = [ "hass.lan" "ha" "ha.lan" "hass.omo.w" "hass.omo.r" ];
    locations."/".proxyPass = "http://localhost:8123";
    locations."/".proxyWebsockets = true;
  };
}
