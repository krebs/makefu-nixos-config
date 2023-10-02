{ config, pkgs, ... }: with pkgs.stockholm.lib; let
  mk_peers = mapAttrs (n: v: { id = v.syncthing.id; });

  all_peers = filterAttrs (n: v: v.syncthing.id != null) config.krebs.hosts;
  used_peer_names = unique (flatten (mapAttrsToList (n: v: v.devices) config.services.syncthing.folders));
  used_peers = filterAttrs (n: v: elem n used_peer_names) all_peers;
in {
  services.syncthing = {
    enable = true;
    configDir = "/var/lib/syncthing";
    devices = mk_peers used_peers;
    key = config.sops.secrets."${config.clanCore.machineName}-syncthing.key".path;
    cert = config.sops.secrets."${config.clanCore.machineName}-syncthing.cert".path;
  };
  services.syncthing.folders.the_playlist = {
    path = "/home/lass/tmp/the_playlist";
    devices = [ "mors" "prism" ];
  };


  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
}
