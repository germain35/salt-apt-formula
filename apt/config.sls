{%- from "apt/map.jinja" import apt with context %}

include:
  - apt.install
{%- if apt.repo is defined %}
  - apt.repo
{%- endif %}

{%- for key, config in apt.get('config', {}).items() %}

apt_conf_{{ key }}:
  file.managed:
    - name: {{apt.conf_dir | path_join('99' ~ key ~ '-salt')}}
    - template: jinja
    - source: salt://apt/files/apt.conf.jinja
    - defaults:
        config: {{ config|yaml }}
    - require:
      - pkg: apt_pkgs

{%- endfor %}