#!/bin/bash
set -e # exit with nonzero exit code if anything fails

# clear and re-create the out directory
rm -rf www;
rm -f bionode_members.json
rm -f bionode_hack.json
rm -f _data.json

mkdir www;

# Install dependencies for member.js
npm install;

node $PWD/members.js bionode | "$PWD/bin/jq-linux64" -s '.| {"community": (.[0] - .[1]), "team": .[1] }' > bionode_members.json;
node $PWD/members.js bionode-hack | "$PWD/bin/jq-linux64" -s '. | flatten | unique_by(.login) | {"events": . }' > bionode_hack.json;
"$PWD/bin/jq-linux64" -s '. | add' bionode_members.json bionode_hack.json > _data.json;

rm bionode_members.json bionode_hack.json;

# Need to remove node_modules to avoid a conflict that causes `harp compile` to fail
rm -r node_modules;

# Install Harp globally
npm install -g harp;

# run our compile script, discussed above
harp compile;
