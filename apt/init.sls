{%- from "apt/map.jinja" import apt with context %}

include:
  - apt.install
  {%- if apt.repo is defined %}
  - apt.repo
  {%- endif %}
  {%- if apt.config is defined %}
  - apt.config
  {%- endif %}