#!/bin/bash
files=$(ls -1 */package.json)
for i in $files; do
jobs=$(sed -n  '/scripts/,/[}]/p' $i | sed -n '/[{]/,/[}]/p' | egrep -v '[{}]' | cut -d":" -f1 | egrep -o "[[:alnum:]][-[:alnum:]_]{0,61}[[:alnum:]]")
for j in $jobs; do
init_file="start on (local-filesystems and runlevel [235])
stop on runlevel [016]

description \"node.js $j server\"
author      \"Josh Boon hfmsupport@hungryfishmedia.com\"
env scriptlog=\"/var/log/node_$j\"
limit nofile 1000000 1000000
start on startup
stop on shutdown

script
    export HOME=\"$(pwd)/$(ls -1 $i | cut -d"/" -f1)\"

    echo \$\$ > /var/run/node_$j.pid
    cd \$HOME
    export APPLICATION_ENV={{apacheenv}}
    exec npm run-script $j  >>\$scriptlog 2>&1
end script

pre-start script
    # Date format same as (new Date()).toISOString() for consistency
    echo \"[\`date -u +%Y-%m-%dT%T.%3NZ\`] (sys) Starting\" >>\$scriptlog
end script

post-stop script
    rm \$pid
    echo \"[\`date -u +%Y-%m-%dT%T.%3NZ\`] (sys) Stopping\" >>\$scriptlog
end script"
echo "$init_file" >|/etc/init/node_"$j".conf
done
done


