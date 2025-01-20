# System Certificates - Firefox

Contrary to popular belief, you can get Firefox to look at the system certificates instead its own hard-coded set.

To do this, you will want to use a package called p11-kit. p11-kit provides a drop-in replacement for `libnssckbi.so`, the shared library that contains the hardcoded set of certificates. The p11-kit version instead reads the certificates from the system certificate store.

Since Firefox ships with its own version of `libnssckbi.so`, you'll need to track it down and replace it instead of the version provided in libnss3:

```shell
sudo mv /usr/lib/firefox/libnssckbi.so /usr/lib/firefox/libnssckbi.so.bak
sudo ln -s /usr/lib/x86_64-linux-gnu/pkcs11/p11-kit-trust.so /usr/lib/firefox/libnssckbi.so
```

Next, delete the `~/.pki` directory to get Firefox to refresh its certificate database (causing it to pull in the system certs) upon restarting Firefox. Note: this will delete any existing certificates in the store, so if have custom ones that you added manually, you might want to back up that folder and then re-import them.

https://support.mozilla.org/en-US/kb/setting-certificate-authorities-firefox Setting security.`enterprise_roots.enabled` to `true`
