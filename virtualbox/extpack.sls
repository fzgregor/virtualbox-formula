{% from "virtualbox/map.jinja" import virtualbox with context %}

virtualbox_ext_pack:
  cmd.run:
    - name: >
            cd /tmp;
            wget -qO - https://www.virtualbox.org/wiki/Downloads |
            grep "vbox-extpack" |
            grep {{virtualbox.version}} |
            sed "s/.\+\(http:\/\/download.virtualbox.org.\+.vbox-extpack\).\+/\1/" |
            xargs wget -O Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack &&
            vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack &&
            rm Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack
    - unless: vboxmanage list extpacks|grep Usable|grep true
    - user: root
    - require:
      - pkg: virtualbox
