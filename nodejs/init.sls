nodejsrepo:
  pkgrepo.managed:
    - human_name: NodeJS PPA
    - name: deb https://deb.nodesource.com/node_0.10 trusty main
    - dist: {{ grains['lsb_distrib_codename'] }}
    - file: /etc/apt/sources.list.d/nodejs.list
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
    - require_in:
      - pkg: nodejs

nodejs:
  pkg:
    - latest
/usr/local/node:
  file.directory:
    - user: root
    - group: gitctl
    - dir_mode: 2775
    - file_mode: 664
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
/usr/local/node/upstart_node.sh:
    file:
        - managed
        - source: salt://nodejs/upstart_node.sh
        - user: root
        - group: root
        - mode: 755
        - template: jinja
        - apacheenv: {{ pillar['apacheenv'] }}
        - require:
          - file: /usr/local/node
upstart-node:
  cmd.wait:
    - cwd: /usr/local/node
    - names:
      - ./upstart_node.sh
    - require:
      - file: /usr/local/node/upstart_node.sh
    - watch:
      - file: /usr/local/node/*
