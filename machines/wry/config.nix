{ config, lib, pkgs, ... }:

with pkgs.stockholm.lib;
let

  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {
  imports = [
      <stockholm/makefu>
      # TODO: copy this config or move to krebs
      <stockholm/makefu/2configs/hw/CAC.nix>
      <stockholm/makefu/2configs/fs/CAC-CentOS-7-64bit.nix>
      <stockholm/makefu/2configs/save-diskspace.nix>

      # <stockholm/makefu/2configs/bepasty-dual.nix>

      <stockholm/makefu/2configs/iodined.nix>
      <stockholm/makefu/2configs/backup.nix>

      # other nginx
      # <stockholm/makefu/2configs/nginx/euer.test.nix>

      # collectd
      <stockholm/makefu/2configs/stats/client.nix>
      <stockholm/makefu/2configs/logging/client.nix>

      <stockholm/makefu/2configs/tinc/retiolum.nix>
      # <stockholm/makefu/2configs/torrent.nix>
  ];

  krebs.build.host = config.krebs.hosts.wry;

  # prepare graphs
  services.nginx.enable = true;
  krebs.retiolum-bootstrap.enable = true;

  networking = {
    firewall = {
      allowPing = true;
      logRefusedConnections = false;
      allowedTCPPorts = [ 53 80 443 ];
      allowedUDPPorts = [ 655 53 ];
    };
    interfaces.enp2s1.ipv4.addresses = [{
      address = external-ip;
      prefixLength = 24;
    }];
    defaultGateway = "104.233.87.1";
    nameservers = [ "8.8.8.8" ];
  };

  environment.systemPackages = [ pkgs.screen ];
}
