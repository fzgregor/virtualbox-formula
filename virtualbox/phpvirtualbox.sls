{% from "virtualbox/map.jinja" import virtualbox with context %}

include:
  - .webservice

unzip:
  pkg.installed

phpvirtualbox:
  cmd.script:
    - name: download_phpvirtualbox.sh {{virtualbox.version}} {{virtualbox.phpvirtualbox.directory}}
    - source: salt://virtualbox/scripts/download_phpvirtualbox.sh
    - user: root
    - unless: test -d {{virtualbox.phpvirtualbox.directory}}
    - require:
      - pkg: virtualbox
      - pkg: unzip
      - pkg: apache-with-php
      - service: apache-with-php
      - file: phpvirtualbox_vhost_file
      - file: phpvirtualbox_vhost_enabled

phpvirtualbox-config:
  file.managed:
    - name: {{virtualbox.phpvirtualbox.directory}}/config.php
    - source: salt://virtualbox/files/phpvirtualbox-config.php
    - template: jinja
    - context:
        username: {{virtualbox.webservice.user}} 
        password: {{virtualbox.webservice.password}}
    - require:
      - cmd: phpvirtualbox

apache-with-php:
  pkg.installed:
    - name: libapache2-mod-php5

  service.running:
    - name: apache2
    - running: True
    - reload: True
    - watch:
      - file: phpvirtualbox_vhost_file
      - pkg: apache-with-php

phpvirtualbox_vhost_file:
  file.managed:
    - name: /etc/apache2/sites-available/phpvirtualbox.conf
    - contents: |
                Alias /phpvirtualbox {{virtualbox.phpvirtualbox.directory}}

                <Directory {{virtualbox.phpvirtualbox.directory}}>
                    DirectoryIndex index.html
                </Directory>
    - require:
      - pkg: apache-with-php

phpvirtualbox_vhost_enabled:
  file.symlink:
    - name: /etc/apache2/sites-enabled/phpvirtualbox.conf
    - target: ../sites-available/phpvirtualbox.conf
    - require:
      - file: phpvirtualbox_vhost_file
      - service: apache-with-php

phpvirtualbox_user_management_initialized:
  cmd.run:
    - name: vboxmanage setextradata global phpvb/usersSetup 1
    - unless: "vboxmanage getextradata global phpvb/usersSetup | grep 'Value: 1'"
    - user: {{virtualbox.webservice.user}}

{% for user, data in pillar.get('virtualbox', {}).get('phpvirtualbox', {}).get('users', {}).items() %}
phpvirtualbox_{{user}}_password:
  cmd.run:
    {% if data.has_key('sha512hash') %}
      {% set hash = data.get('sha512hash') %}
    {% else %}
      {% set hash = salt['cmd.exec_code']('python', 'import hashlib;print hashlib.sha512("'+data.get('password')+'").hexdigest()') %}
    {% endif %}
    - name: vboxmanage setextradata global phpvb/users/{{user}}/pass {{hash}}
    - unless: vboxmanage getextradata global phpvb/users/{{user}}/pass | grep {{hash}}
    - user: {{virtualbox.webservice.user}}
    - require:
      - pkg: virtualbox

phpvirtualbox_{{user}}_admin:
  cmd.run:
    {% if data.get('admin') %}
    - name: vboxmanage setextradata global phpvb/users/{{user}}/admin 1
    - unless: vboxmanage getextradata global phpvb/users/{{user}}/admin | grep 1
    {% else %}
    - name: vboxmanage setextradata global phpvb/users/{{user}}/admin
    - onlyif: vboxmanage getextradata global phpvb/users/{{user}}/admin | grep 1
    {% endif %}
    - user: {{virtualbox.webservice.user}} 
    - require:
      - pkg: virtualbox

{% endfor %}
