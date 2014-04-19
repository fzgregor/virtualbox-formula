{% from "virtualbox/map.jinja" import virtualbox with context %}

vbox_webservice:
  {% set pw_salt = salt['cmd.exec_code']('python', 'import base64; print base64.b64encode("'+virtualbox.webservice.user+'")[0:16];') %}
  {% set pw_hash = salt['cmd.exec_code']('python', 'import crypt; import base64; print crypt.crypt("'+virtualbox.webservice.password+'", "$6$'+pw_salt+'$")') %}
  user.present:
    - name: {{virtualbox.webservice.user}}
    - password: {{pw_hash}}
    {% if virtualbox.webservice.has_key('uid') %}
    - uid: {{virtualbox.webservice.uid}}
    {% endif %}
    - system: True
    - home: {{virtualbox.webservice.home}}
    - shell: /bin/false
    - groups:
      - vboxusers
    - require:
      - pkg: virtualbox

  file.managed:
    - name: /etc/default/virtualbox
    - user: root
    - group: root
    - mode: 644
    - contents: |
                # this file is managed by salt
                # any manual change will be reverted
                VBOXWEB_USER={{virtualbox.webservice.user}}
    - require:
      - user: vbox_webservice
      - pkg: virtualbox

  service.running:
    - name: vboxweb-service
    - reload: True
    - enable: True
    - sig: vboxwebsrv
    - require:
      - file: vbox_webservice
