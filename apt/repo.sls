{%- from "apt/map.jinja" import apt with context %}

include:
  - apt.install

{%- set default_repos = {} %}

{%- if apt.purge_repos %}
apt_purge_repos:
   file.directory:
    - name: {{ apt.sources_dir }}
    - clean: True
{%- endif %}


{%- for name, repo in apt.get('repo', {}).items() %}
  {%- if repo.get('enabled', True) %}

    {%- if repo.pin is defined %}
apt_repo_{{ name }}_pin:
  file.managed:
    - name: {{ apt.preferences_dir | path_join(name) }}
    - source: salt://apt/files/preferences_repo.jinja
    - template: jinja
    - defaults:
        repo_name: {{ name }}
    {%- else %}
apt_repo_{{ name }}_pin:
  file.absent:
    - name: {{ apt.preferences_dir | path_join(name) }}
    {%- endif %}

    {%- if repo.get('default', False) %}
      {%- do default_repos.update({name: repo}) %}
      {%- if repo.get('key', False) %}

apt_repo_{{ name }}_key:
  cmd.wait:
    - name: "echo '{{ repo.key }}' | apt-key add -"
    - watch:
      - file: apt_default_repo_list

      {%- elif repo.key_url|default(False) %}

apt_repo_{{ name }}_key:
  cmd.wait:
    - name: "curl -s {{ repo.key_url }} | apt-key add -"
    - watch:
      - file: apt_default_repo_list

      {%- endif %}
    {%- else %}

apt_repo_{{ name }}:
  pkgrepo.managed:
      {%- if repo.ppa is defined %}
    - ppa: {{ repo.ppa }}
      {%- else %}
    - humanname: {{ name }}
    - name: {{ repo.source }}
        {%- if repo.architectures is defined %}
    - architectures: {{ repo.architectures }}
        {%- endif %}
    - file: {{ apt.sources_dir | path_join(name ~ '.list') }}
    - clean_file: {{ repo.clean|default(True) }}
        {%- if repo.key_id is defined %}
    - keyid: {{ repo.key_id }}
        {%- endif %}
        {%- if repo.key_server is defined %}
    - keyserver: {{ repo.key_server }}
        {%- endif %}
        {%- if repo.key_url is defined %}
    - key_url: {{ repo.key_url }}
        {%- endif %}
    - consolidate: {{ repo.get('consolidate', False) }}
    - clean_file: {{ repo.get('clean_file', False) }}
    - refresh_db: {{ repo.get('refresh_db', True) }}
    - require:
      - pkg: apt_pkgs
        {%- if apt.purge_repos %}
      - file: apt_purge_repos
        {%- endif %}
      {%- endif %}
    {%- endif %}
  {%- else %}

apt_repo_{{ name }}:
  pkgrepo.absent:
    {%- if repo.ppa is defined %}
    - ppa: {{ repo.ppa }}
      {%- if repo.key_id is defined %}
    - keyid_ppa: {{ repo.keyid_ppa }}
      {%- endif %}
    {%- else %}
    - file: {{ apt.sources_dir | path_join(name ~ '.list') }}
      {%- if repo.key_id is defined %}
    - keyid: {{ repo.key_id }}
      {%- endif %}
    {%- endif %}
  file.absent:
    - name: {{ apt.sources_dir | path_join(name ~ '.list') }}

  {%- endif %}
{%- endfor %}


{%- if default_repos|length > 0 %}

apt_default_repo_list:
  file.managed:
    - name: {{ apt.default_sources_file }}
    - source: salt://apt/files/sources.list.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
  {%- if apt.purge_repos %}
    - replace: True
  {%- endif %}
    - defaults:
        default_repos: {{ default_repos }}
    - require:
      - pkg: apt_pkgs

apt_refresh_default_repo:
  module.wait:
    - name: pkg.refresh_db
    - watch:
      - file: apt_default_repo_list

{%- endif %}