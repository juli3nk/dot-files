alias dpkg-last='ls -tl /var/lib/dpkg/info/ | awk '\''BEGIN { OFS=" "; } { print $6, $7, $8, "\t", $9 }'\'''
