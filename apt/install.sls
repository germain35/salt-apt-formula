{%- from "apt/map.jinja" import apt with context %}

apt_pkgs:
  pkg.installed:
    - pkgs: {{ apt.pkgs }}