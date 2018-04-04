#
#
#
{ config, pkgs, ... }:
with import <stockholm/lib>;

{
  imports =
    [ # base
      <stockholm/makefu>
      <stockholm/makefu/2configs/main-laptop.nix>
      <stockholm/makefu/2configs/extra-fonts.nix>
      <stockholm/makefu/2configs/tools/all.nix>
      <stockholm/makefu/2configs/tools/mic92.nix>

      <stockholm/makefu/2configs/laptop-backup.nix>
      <stockholm/makefu/2configs/dnscrypt/client.nix>
      <stockholm/makefu/2configs/avahi.nix>

      # Debugging
      # <stockholm/makefu/2configs/disable_v6.nix>

      # Testing
      # <stockholm/makefu/2configs/deployment/gitlab.nix>
      # <stockholm/makefu/2configs/deployment/wiki-irc-bot>

      # <stockholm/makefu/2configs/torrent.nix>
      # <stockholm/makefu/2configs/deployment/dirctator.nix>
      # <stockholm/makefu/2configs/vncserver.nix>
      # <stockholm/makefu/2configs/deployment/led-fader>
      # <stockholm/makefu/2configs/deployment/hound>
      # <stockholm/makefu/2configs/deployment/photostore.krebsco.de.nix>
      # <stockholm/makefu/2configs/deployment/bureautomation/hass.nix>

      # Krebs
      <stockholm/makefu/2configs/tinc/retiolum.nix>

      # applications
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/mail-client.nix>
      <stockholm/makefu/2configs/printer.nix>
      <stockholm/makefu/2configs/task-client.nix>

      # Virtualization
      <stockholm/makefu/2configs/virtualisation/libvirt.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>
      <stockholm/makefu/2configs/virtualisation/virtualbox.nix>
      {
        networking.firewall.allowedTCPPorts = [ 8080 ];
        networking.nat = {
          enable = true;
          externalInterface = "wlp3s0";
          internalInterfaces = [ "vboxnet0" ];
        };
      }

      # Services
      <stockholm/makefu/2configs/git/brain-retiolum.nix>
      <stockholm/makefu/2configs/tor.nix>
      <stockholm/makefu/2configs/vpn/vpngate.nix>
      # <stockholm/makefu/2configs/buildbot-standalone.nix>
      # <stockholm/makefu/2configs/remote-build/master.nix>

      # Hardware
      <stockholm/makefu/2configs/hw/tp-x230.nix>
      # <stockholm/makefu/2configs/hw/tpm.nix>
      # <stockholm/makefu/2configs/hw/rtl8812au.nix>
      <stockholm/makefu/2configs/hw/network-manager.nix>
      <stockholm/makefu/2configs/hw/stk1160.nix>
      # <stockholm/makefu/2configs/rad1o.nix>

      # Filesystem
      <stockholm/makefu/2configs/fs/sda-crypto-root-home.nix>

      # Security
      <stockholm/makefu/2configs/sshd-totp.nix>
      {
        programs.adb.enable = true;
      }
      # temporary
      # <stockholm/makefu/2configs/lanparty/lancache.nix>
      # <stockholm/makefu/2configs/lanparty/lancache-dns.nix>
      # <stockholm/makefu/2configs/lanparty/samba.nix>
      # <stockholm/makefu/2configs/lanparty/mumble-server.nix>

      {
        networking.wireguard.interfaces.wg0 = {
          ips = [ "10.244.0.2/24" ];
          privateKeyFile = (toString <secrets>) + "/wireguard.key";
          allowedIPsAsRoutes = true;
          peers = [
          {
            # gum
            endpoint = "${config.krebs.hosts.gum.nets.internet.ip4.addr}:51820";
            allowedIPs = [ "10.244.0.0/24" ];
            publicKey = "yAKvxTvcEVdn+MeKsmptZkR3XSEue+wSyLxwcjBYxxo=";
          }
          #{
          #  # vbob
          #  allowedIPs = [ "10.244.0.3/32" ];
          #  publicKey = "Lju7EsCu1OWXhkhdNR7c/uiN60nr0TUPHQ+s8ULPQTw=";
          #}
          ];
        };
      }
      { # bluetooth+pulse config
        # for blueman-applet
        users.users.makefu.packages = [
          pkgs.blueman
        ];
        hardware.pulseaudio = {
          enable = true;
          package = pkgs.pulseaudioFull;
          # systemWide = true;
          support32Bit = true;
          configFile = pkgs.writeText "default.pa" ''
            load-module module-udev-detect
            load-module module-bluetooth-policy
            load-module module-bluetooth-discover
            load-module module-native-protocol-unix
            load-module module-always-sink
            load-module module-console-kit
            load-module module-systemd-login
            load-module module-intended-roles
            load-module module-position-event-sounds
            load-module module-filter-heuristics
            load-module module-filter-apply
            load-module module-switch-on-connect
            load-module module-switch-on-port-available
            '';
        };

        # presumably a2dp Sink
        # Enable profile:
        ## pacmd set-card-profile "$(pactl list cards short | egrep -o bluez_card[[:alnum:]._]+)" a2dp_sink
        hardware.bluetooth.extraConfig = '';
          [general]
          Enable=Source,Sink,Media,Socket
        '';

        # connect via https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
        hardware.bluetooth.enable = true;
      }
      { # auto-mounting via polkit
        services.udisks2.enable = true;
        ## automount all disks:
        # services.devmon.enable = true;
        # services.gnome3.gvfs.enable = true;
        users.groups.storage = {
          gid = genid "storage";
          members = [ "makefu" ];
        };
        users.users.makefu.packages = with pkgs;[
          gvfs pcmanfm lxmenu-data
        ];
        environment.variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];

        ## allow users in group "storage" to mount disk
        # https://github.com/coldfix/udiskie/wiki/Permissions
        security.polkit.extraConfig =
        ''
        polkit.addRule(function(action, subject) {
            var YES = polkit.Result.YES;
            var permission = {
            "org.freedesktop.udisks.filesystem-mount": YES,
            "org.freedesktop.udisks.luks-unlock": YES,
            "org.freedesktop.udisks.drive-eject": YES,
            "org.freedesktop.udisks.drive-detach": YES,
            "org.freedesktop.udisks2.filesystem-mount": YES,
            "org.freedesktop.udisks2.encrypted-unlock": YES,
            "org.freedesktop.udisks2.eject-media": YES,
            "org.freedesktop.udisks2.power-off-drive": YES,
            "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
            "org.freedesktop.udisks2.filesystem-unmount-others": YES,
            "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
            "org.freedesktop.udisks2.eject-media-other-seat": YES,
            "org.freedesktop.udisks2.power-off-drive-other-seat": YES
            };
            if (subject.isInGroup("storage")) {
              return permission[action.id];
            }
        });
        '';

      }

    ];

  makefu.server.primary-itf = "wlp3s0";
  makefu.full-populate = true;

  nixpkgs.config.allowUnfree = true;

  # configure pulseAudio to provide a HDMI sink as well
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 24800 26061 8000 3000 ];
  networking.firewall.allowedUDPPorts = [ 665 26061 ];
  networking.firewall.trustedInterfaces = [ "vboxnet0" ];

  krebs.build.host = config.krebs.hosts.x;

  krebs.tinc.retiolum.connectTo = [ "omo" "gum" "prism" ];

  networking.extraHosts = ''
    192.168.1.11  omo.local
    80.92.65.53 www.wifionice.de wifionice.de
  '';
  # hard dependency because otherwise the device will not be unlocked
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; allowDiscards=true; }];

  nix.package = pkgs.nixUnstable;
  environment.systemPackages = [ pkgs.passwdqc-utils pkgs.nixUnstable ];
  nixpkgs.overlays = [ (import <python/overlay.nix>) ];

  # environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };

}
