{ config, lib, pkgs, ... }:
let
  primaryInterface = "eth0";
in {
  imports = [
    <stockholm/makefu>
    ./hardware-config.nix
    # <stockholm/makefu/2configs/tools/core.nix>
    { environment.systemPackages = with pkgs;[ rsync screen curl git ];}
    <stockholm/makefu/2configs/binary-cache/nixos.nix>
    #<stockholm/makefu/2configs/support-nixos.nix>
# configure your hw:
# <stockholm/makefu/2configs/save-diskspace.nix>
  ];
  krebs = {
    enable = true;
    tinc.retiolum.enable = true;
    build.host = config.krebs.hosts.firecracker;
  };
  networking.firewall.trustedInterfaces = [ primaryInterface ];
  documentation.info.enable = false;
  documentation.man.enable = false;
  services.nixosManual.enable = false;
  sound.enable = false;
}
