curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo add-apt-repository ppa:staticfloat/juliareleases
sudo add-apt-repository ppa:staticfloat/julia-deps
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install git julia gcc g++ make libgmp-dev nodejs postgresql-9.4
sudo npm install -g bower
sudo su postgres -c "createuser ubuntu --pwprompt --createdb"
git clone git@github.com:czlee/adjumo.git
julia adjumo/julia/installrequirements.jl
