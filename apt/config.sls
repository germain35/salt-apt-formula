{%- from "apt/map.jinja" import apt with context %}

include:
  - apt.install

apt_conf:
  file.managed:
    - name: {{apt.conf_dir | path_join('99salt')}}
    - template: jinja
    - source: salt://apt/files/apt.conf.jinja
    - require:
      - pkg: apt_pkgs
