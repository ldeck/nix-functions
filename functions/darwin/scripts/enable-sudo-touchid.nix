{ pkgs }:

# Enable touchid to be used with sudo if not already.
# NB: sometimes this gets disabled by system updates and needs to be re-applied.

pkgs.writeShellScriptBin "enable-sudo-touchid" ''
  primary=$(cat /etc/pam.d/sudo | head -2 | tail -1 | awk '{$1=$1}1' OFS=",")
  if [ "auth,sufficient,pam_tid.so" != "$primary" ]; then
    newsudo=$(mktemp)
    awk 'NR==2{print "auth       sufficient     pam_tid.so"}7' /etc/pam.d/sudo > $newsudo
    sudo mv $newsudo /etc/pam.d/sudo
  fi
''
