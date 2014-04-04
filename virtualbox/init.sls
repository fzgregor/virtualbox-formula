{% from "virtualbox/map.jinja" import virtualbox with context %}

virtualbox:
  pkgrepo.managed:
    - name: deb http://download.virtualbox.org/virtualbox/debian {{ grains['lsb_distrib_codename'] }} contrib
    - comps: contrib
    - dist: {{ grains['lsb_distrib_codename'] }}
    - file: /etc/apt/sources.list.d/oracle-virtualbox.list
    - key_url: http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc
    - require_in: 
      - pkg: virtualbox

  pkg.installed:
    - name: virtualbox-{{virtualbox.version}}
