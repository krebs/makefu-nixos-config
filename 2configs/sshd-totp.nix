{ pkgs, config, ... }:
# Enables second factor for ssh password login

## Usage:
#  gen-oath-safe <username> totp
## scan the qrcode with google authenticator (or FreeOTP)
## copy last line into secrets/<host>/users.oath (chmod 700)
{
  security.pam.oath = {
    # enabling it will make it a requisite of `all` services
    # enable = true;
    digits = 6;
    usersFile = config.sops.secrets."users.oath".path;
  };
  # I want TFA only active for sshd with password-auth
  security.pam.services.sshd.oathAuth = true;
}
