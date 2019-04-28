{%- from "apt/map.jinja" import apt with context %}

include:
  - apt.install

apt_ssl_dir:
  file.directory:
    - name: {{ apt.ssl_dir }}
    - user: root
    - group: root
    - mode: 755

{%- for certificate, params in apt.get('certificates', {}).items() %}
apt_key_{{certificate}}:
  file.managed:
    - name: {{ apt.ssl_dir }}/{{certificate}}.key
    {%- if params.key.source is defined %}
    - source: {{ params.key.source }}
      {%- if params.key.source_hash is defined %}
    - source_hash: {{ params.key.source_hash }}
      {%- else %}
    - skip_verify: True
      {%- endif %}
    {% else %}
    - contents_pillar: apt:certificates:{{certificate}}:key:contents
    {%- endif %}
    - user: {{apt.user}}
    - group: {{apt.group}}
    - mode: 600
    - require:
      - file: apt_ssl_dir

apt_crt_{{certificate}}:
  file.managed:
    - name: {{ apt.ssl_dir }}/{{certificate}}.crt
    {%- if params.crt.source is defined %}
    - source: {{ params.crt.source }}
      {%- if params.crt.source_hash is defined %}
    - source_hash: {{ params.crt.source_hash }}
      {%- else %}
    - skip_verify: True
      {%- endif %}
    {%- else %}
    - contents_pillar: apt:certificates:{{certificate}}:crt:contents
    {%- endif %}
    - user: {{apt.user}}
    - group: {{apt.group}}
    - mode: 644
    - require:
      - file: apt_ssl_dir

    {%- if params.get('ca', False) %}
apt_ca_{{certificate}}:
  file.managed:
    - name: {{ apt.ssl_dir }}/{{certificate}}-ca.crt
    {%- if params.ca.source is defined %}
    - source: {{ params.ca.source }}
      {%- if params.ca.source_hash is defined %}
    - source_hash: {{ params.ca.source_hash }}
      {%- else %}
    - skip_verify: True
      {%- endif %}
    {% else %}
    - contents_pillar: apt:certificates:{{certificate}}:ca:contents
    {%- endif %}
    - user: {{apt.user}}
    - group: {{apt.group}}
    - mode: 644
    - require:
      - file: apt_ssl_dir
    {%- endif %}
{%- endfor %}
