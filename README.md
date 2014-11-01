asu-mailbox
===========

University project: CGI script for retreiving, send and deleting mails on Ubuntu with installed Apache server


## Ustawienia i instalacje Apache'a
1. Instalacja apache2 serwer za pomoca polecenia: `sudo apt-get install apache2`
2. Skrypty CGI będą przechowywane w katalogu `/usr/lib/cgi-bin`. Należy zmienić prawa dostępu do tego foleru za pomocą polecenia `chmod 755 /user/lib/cgi-bin` (tak, żeby każdy mógł odczytywać i wykonywać skrypty, ale tylko właściciel mógł je zapisywać.)
3. Ustawić roota jako właściciela tych skryptów za pomocą `sudo chown root.root /usr/lib/cgi-bin` (root.root to grupa.uzytkownik).
4. W pliku `/etc/apache2/sites-available/000-default.conf` dodajemy informację, gdzie będą umieszczone skrypty:
`
ScriptAlias /cgi-bin/ /urs/lib/cgi-bin/
<Directory /usr/lib/cgi-bin/>
Options ExecCGI
</Directory>
`

5. W pliku `etc/apache2/apache2.conf` trzeba określić nazwę serwera, tzn. dodać `ServerName localhost`
6. O ile go nie ma, należy dodać moduł cgi do `/etc/apache2/mods-enabled` komendą `sudo a2enmod cgi`
7. Zrestartować serwer z uprawnieniami sudo (`sudo service apache2 restart`)
8. Doinstalować potrzebne moduły perla: 
`
sudo perl -MCPAN -e shell
install HTML::Template
install Path::Class
`
Przy maszynie wirtualnej pamiętać, aby dostęp do internetu był zapewniony przez bridged a nie nat (żeby można się było dostać z przeglądarki).
_____________________
skopiowanie skrzynki: komenda scp




