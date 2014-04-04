{% from "virtualbox/map.jinja" import virtualbox with context %}

vbox_webservice:
  user.present:
    - name: {{virtualbox.webservice_user}}
    - password: {{virtualbox.webservice_password}}
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
                VBOXWEB_USER={{virtualbox.webservice_user}}
    - require:
      - user: vbox_webservice
      - pkg: virtualbox

  {% if virtualbox.webservice_machine_directory %} 
  cmd.run:
    - name: vboxmanage setproperty machinefolder {{virtualbox.webservice_machine_directory}}
    - root: {{virtualbox.webservice_user}}
    - require:
      - user: vbox_webservice
  {% endif %}

  service.running:
    - name: vboxweb-service
    - reload: True
    - enable: True
    - sig: vboxwebsrv
    - require:
      - file: vbox_webservice
