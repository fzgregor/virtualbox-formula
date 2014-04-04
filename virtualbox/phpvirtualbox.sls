{% from "virtualbox/map.jinja" import virtualbox with context %}

unzip:
  pkg.installed

phpvirtualbox:
  cmd.script:
    - name: download_phpvirtualbox.sh {{virtualbox.version}} {{virtualbox.phpvirtualbox_directory}}
    - source: salt://virtualbox/scripts/download_phpvirtualbox.sh
    - user: root
    - required: pkg.unzip
    - unless: test -d {{virtualbox.phpvirtualbox_directory}}

apache-with-php:
  pkg.installed:
    - name: libapache2-mod-php5

phpvirtualbox_vhost_file:
  file.managed:
    - name: /etc/apache2/sites-available/phpvirtualbox
    - contents: |
                <VirtualHost *:80>
                    DocumentRoot {{virtualbox.phpvirtualbox_directory}}
                    ServerName localhost
                </VirtualHost>

phpvirtualbox_vhost_enabled:
  file.symlink:
    - name: /etc/apache2/sites-enabled/phpvirtualbox
    - target: /etc/apache2/sites-available/phpvirtualbox

