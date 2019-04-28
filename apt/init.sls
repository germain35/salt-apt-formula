{%- from "apt/map.jinja" import apt with context %}

include:
  - apt.install
  - apt.config
  - apt.ssl
  - apt.repo
