{% from "virtualbox/map.jinja" import virtualbox with context %}

vbox_webservice:
  user.present:
    - name: {{virtualbox.webservice_user}}
    - password: {{salt['cmd.exec_code']('python', 'import crypt; import base64; print crypt.crypt("'+virtualbox.webservice_password+'", "$6$"+base64.b64encode("'+virtualbox.webservice_user+'")[0:16]+"$")')}}
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
