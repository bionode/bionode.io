# Bionode website

Please improve it with pull requests.

# Instructions (this workflow could also probably be improved...)
git clone git@github.com:bionode/bionode.github.io.git
cd bionode.github.io
git clone -b master git@github.com:bionode/bionode.github.io.git source/www
npm install -g harp
harp server source
(edit files and watch changes on http://localhost:9000/)
harp compile source
git commit -am "Commit message"
git push origin dev
cd source/www
git commit -am "Compile 'Commit message'"
git push origin master
