# Time

## Chrony
Chrony is a flexible implementation of the Network Time Protocol (NTP). It is used to synchronize the system clock from different NTP servers, reference clocks or via manual input.

It can also be used NTPv4 server to provide time service to other servers in the same network. It is meant to operate flawlessly under different conditions such as intermittent network connection, heavily loaded networks, changing temperatures which may affect the clock of ordinary computers.

Chrony comes with two programs:

* chronyc – command line interface for chrony
* chronyd – daemon that can be started at boot time

### Check Chrony Synchronization in Linux

To check if chrony is actually synchronized, we will use it’s command line program chronyc, which has the tracking option which will provide relevant information.

```shell
$ chronyc tracking
```

The listed files provide the following information:

    Reference ID – the reference ID and name to which the computer is currently synced.
    Stratum – number of hops to a computer with an attached reference clock.
    Ref time – this is the UTC time at which the last measurement from the reference source was made.
    System time – delay of system clock from synchronized server.
    Last offset – estimated offset of the last clock update.
    RMS offset – long term average of the offset value.
    Frequency – this is the rate by which the system’s clock would be wrong if chronyd is not correcting it. It is provided in ppm (parts per million).
    Residual freq – residual frequency indicated the difference between the measurements from reference source and the frequency currently being used.
    Skew – estimated error bound of the frequency.
    Root delay – total of the network path delays to the stratum computer, from which the computer is being synced.
    Leap status – this is the leap status which can have one of the following values – normal, insert second, delete second or not synchronized.

To check information about chrony’s sources, you can issue the following command.

```shell
$ chronyc sources
```

Configure Chrony in Linux

The configuration file of chrony is located at `/etc/chrony.conf` or `/etc/chrony/chrony.conf` and sample configuration file may look something like this:

```conf
server 0.rhel.pool.ntp.org iburst
server 1.rhel.pool.ntp.org iburst
server 2.rhel.pool.ntp.org iburst
server 3.rhel.pool.ntp.org iburst

stratumweight 0
driftfile /var/lib/chrony/drift
makestep 10 3
logdir /var/log/chrony
```

The above configuration provide the following information:

* server – this directive used to describe a NTP server to sync from.
* stratumweight – how much distance should be added per stratum to the sync source. The default value is 0.0001.
* driftfile – location and name of the file containing drift data.
* Makestep – this directive causes chrony to gradually correct any time offset by speeding or slowing down the clock as required.
* logdir – path to chrony’s log file.

If you want to step the system clock immediately and ignoring any adjustments currently being in progress, you can use the following command:

```shell
$ chronyc makestep
```

Si l’on souhaite limiter Chrony à la machine locale on doit indiquer dans le fichier de configuration les lignes suivantes :

```conf
allow 127/8
bindcmdaddress 127.0.0.1
```

Il est également possible de transformer le serveur Linux en serveur NTP. Pour se faire, le port UDP/123 réservé au protocole NTP doit être ouvert et il suffit ensuite d’ajouter les lignes ci-dessous au fichier de configuration :

```coonf
allow 127/8
allow 10/8
allow 172.16/12
allow 192.168/16
bindcmdaddress 0.0.0.0
```

### V. Sécurisation de chrony

Étant donné que l’accès via chronyc autorise à modifier le daemon chronyd à l’instar de la modification directe au travers du fichier de configuration, l’accès à chronyc doit être restreinte. On peut ainsi spécifier des mots de passe en ASCII ou hexadécimal, dans un fichier de clé afin de limiter l’utilisation de la commande chronyc.

Une directive est utilisée pour restreindre l’utilisation de commandes opérationnelles et est désignée comme étant la commande clé. Dans la configuration par défaut de chronyc, une commande clé de commande aléatoire est automatiquement générée à l’initialisation du service. On ne devrait donc pas à avoir à la spécifier ou à la modifier manuellement.

    REMARQUE : il existe d’autres directives dans le fichier clé pouvant être utilisées comme clé NTP afin d’authentifier les paquets reçus de serveurs ou d’unités NTP distantes.

Les deux membres d’un échange NTP doivent partager une clé avec un identifiant (que l’on retrouve dans le champ Reference ID), un type de hachage et un mot de passe identique, au sein de leur fichier de clé. Cela nécessite alors la génération manuelle des clés. Il faut également les copier au moyen d’une méthode sécurisée telle que SSH.

En résumé, si l’identifiant clé est 25, alors les systèmes agissants en tant que client doivent disposer d’une ligne dans leur fichier de configuration sous le format suivant :

server A.B.C.D key 25
peer A.B.C.D key 25

L’emplacement du fichier de clé est généralement mentionné dans le fichier /etc/chrony.conf. L’entrée par défaut est spécifiée sous la forme :

keyfile /etc/chrony.keys

Le numéro de la clé de commande est également mentionné dans le fichier de configuration via la directive commandkey. Cela mentionne la clé que le daemon chronyd utilisera pour l’authentification des commandes utilisateurs :

commandkey 1

Voici un exemple du format que le fichier /etc/chrony.keys peut prendre :

En début de ligne on retrouve l’ID de la clé (ici 1), suivi du mode de hachage (SHA1) et du format de la clé en hexadécimal. Cette clé est générée aléatoirement lorsque le daemon a été initialisé pour la première fois. Une entrée manuelle dans le fichier de clé, utilisée pour authentifier les paquets de certains serveurs ou référence NTP peut être aussi simple que la ligne suivante :

25 MyKey

25 est bien sûr l’identifiant clé et ‘MyKey’ est la clé d’authentification secrète. Par défaut, le hachage utilisé est MD5 et le format de la clé est présenté sous forme ASCII.

De plus, par défaut, le daemon chronyd est configuré pour écouter les commandes en provenance de localhost (127.0.0.1 et/ou ::1 en IPv6), sur le port 323. Ainsi, pour accéder à chronyd à distance via la commande chronyc, toutes les directives bindcmdaddress devront être supprimées du fichier de configuration, afin de permettre l’écoute sur toutes les interfaces pour l’ensemble des interfaces.

Toutefois, la directive cmdallow devra être activée pour autoriser uniquement les commandes en provenance de l’adresse IP distante. On peut également sélectionner un réseau ou un sous-réseau distant. Bien sûr, le port 323 doit être ouvert au niveau des pare-feu pour autoriser les connexions d’un système distant.

    REMARQUE : la directive allow permet l’accès NTP et la directive cmdallow active la réception des commandes distantes. Il ne faut les confondre. Toutefois, on peut activer une option via le mode interactif chronyc. Mais, pour rendre les modifications permanentes, il faut modifier le fichier /etc/chrony.conf et redémarrer le service.

L’utilisation de ce service doit être autorisé en exécutant les commandes authhash et password suivante :

chronyc> authhash SHA1
chronyc> password HEX:7A2A67C0DBC1F0F16651B233EAC17361E81EA765

Si la commande chronyc est utilisée pour configure le daemon local chronyd, ces commandes peuvent être passées directement via l’option -a.
