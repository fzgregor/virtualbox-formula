{% from "virtualbox/map.jinja" import virtualbox with context %}

unzip:
  pkg.installed

phpvirtualbox:
  cmd.script:
    - name: download_phpvirtualbox.sh {{virtualbox.version}} {{virtualbox.phpvirtualbox_directory}}
    - source: salt://virtualbox/scripts/download_phpvirtualbox.sh
    - user: root
    - unless: test -d {{virtualbox.phpvirtualbox_directory}}
    - require:
      - pkg: unzip
      - pkg: apache-with-php
      - service: apache-with-php
      - file: phpvirtualbox_vhost_file
      - file: phpvirtualbox_vhost_enabled

phpvirtualbox-config:
  file.managed:
    - name: {{virtualbox.phpvirtualbox_directory}}/config.php
    - source: salt://virtualbox/files/phpvirtualbox-config.php
    - template: jinja
    - context:
        username: {{virtualbox.webservice_user}} 
        password: {{virtualbox.webservice_password}}
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
    - name: /etc/apache2/sites-available/phpvirtualbox
    - contents: |
                Alias /phpvirtualbox {{virtualbox.phpvirtualbox_directory}}

                <Directory {{virtualbox.phpvirtualbox_directory}}>
                    DirectoryIndex index.html
                </Directory>
    - require:
      - pkg: apache-with-php

phpvirtualbox_vhost_enabled:
  file.symlink:
    - name: /etc/apache2/sites-enabled/phpvirtualbox
    - target: ../sites-available/phpvirtualbox
    - require:
      - file: phpvirtualbox_vhost_file
      - service: apache-with-php

phpvirtualbox_user_management_initialized:
  cmd.run:
    - name: vboxmanaga setextradata global phpvb/usersSetup 1
    - unless: "vboxmanage getextradata global phpvb/usersSetup | grep 'Value: 1'"
    - user: {{virtualbox.webservice_user}}

{% for user, data in pillar.get('virtualbox').get('phpvirtualbox', {}).get('users', {}).items() %}
phpvirtualbox_{{user}}_password:
  cmd.run:
    {% if data.has_key('sha512hash') %}
      {% set hash = data.get('sha512hash') %}
    {% else %}
      {% set hash = salt['cmd.exec_code']('python', 'import hashlib;print hashlib.sha512("'+data.get('password')+'").hexdigest()') %}
    {% endif %}
    - name: vboxmanage setextradata global phpvb/users/{{user}}/pass {{hash}}
    - unless: vboxmanage getextradata global phpvb/users/{{user}}/pass | grep {{hash}}
    - user: {{virtualbox.webservice_user}}

phpvirtualbox_{{user}}_admin:
  cmd.run:
    {% if data.get('admin') %}
    - name: vboxmanage setextradata global phpvb/users/{{user}}/admin 1
    - unless: vboxmanage getextradata global phpvb/users/{{user}}/admin | grep 1
    {% else %}
    - name: vboxmanage setextradata global phpvb/users/{{user}}/admin
    - onlyif: vboxmanage getextradata global phpvb/users/{{user}}/admin | grep 1
    {% endif %}
    - user: {{virtualbox.webservice_user}} 

{% endfor %}
