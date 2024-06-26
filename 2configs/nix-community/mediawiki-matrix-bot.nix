{ pkgs, config, ... }:

{
  sops.secrets."mediawikibot-config-nixos.org.json" = {
    mode = "0440";
    group = config.users.groups.mediawiki.name;
  };
  users.groups.mediawiki = {};

  systemd.services.mediawiki-matrix-bot-nixos-org = {
    description = "Mediawiki Matrix Bot (nixos.org)";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "60s";
      DynamicUser = true;
      StateDirectory = "mediawiki-matrix-bot-nixos.org";
      SupplementaryGroups = [ config.users.groups.mediawiki.name ];

      ExecStart = "${pkgs.mediawiki-matrix-bot}/bin/mediawiki-matrix-bot ${config.sops.secrets."mediawikibot-config-nixos.org.json".path}";
      PrivateTmp = true;
    };
  };
}
