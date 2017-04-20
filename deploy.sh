#!/bin/bash
set -e # exit with nonzero exit code if anything fails

# clear and re-create the out directory
rm -rf www || exit 0;
mkdir www;

rm _data.json

node members.js bionode | jq -s '.| {"community": (.[0] - .[1]), "team": .[1] }' > bionode_members.json
node members.js bionode-hack | jq -s '. | flatten | unique_by(.login) | {"events": . }' > bionode_hack.json

jq -s '. | add' bionode_members.json bionode_hack.json > _data.json

rm bionode_members.json bionode_hack.json

# Need to remove node_modules to avoid a conflict that causes `harp compile` to fail
rm -r node_modules

# run our compile script, discussed above
harp compile
# go to the out directory and create a *new* Git repo
cd www
git init

# inside this git repo we'll pretend to be a new user
git config user.name "Travis CI"
git config user.email "travis@bmpvieira.com"

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy to GitHub Pages"

# Force push from the current repo's dev branch to the remote github.io
# repo's master branch. (All previous history on the master branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:master > /dev/null 2>&1
