# Setting up an Amazon EC2 instance

## Launch a new instance
- Launch an **Ubuntu Server** instance (not Amazon Linux).
- Don't forget to configure an appropriate security group, it should allow both
  SSH and HTTP

## Short version
``` bash
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
julia adjumo/julia/installrequirements.jl (gurobi | cbc | glpk) [psql]
```

In the last line, choose your solver. If it's Gurobi, install Gurobi before
running the last line.

## Long method
### Install basic tools
```
sudo apt-get install git
```

### Install Julia and required packages
#### Julia
``` bash
sudo add-apt-repository ppa:staticfloat/juliareleases
sudo add-apt-repository ppa:staticfloat/julia-deps
sudo apt-get update
sudo apt-get install julia
```

#### Non-Julia dependencies for CBC and GLPK
``` bash
sudo apt-get install gcc
sudo apt-get install g++
sudo apt-get install make
sudo apt-get install libgmp-dev
```

#### Required packages
In Julia:
``` julia
Pkg.add("JuMP")
Pkg.add("ArgParse")
Pkg.add("Formatting")
Pkg.add("Cbc")
Pkg.add("GLPKMathProgInterface")
Pkg.clone("https://github.com/JuliaDB/PostgreSQL.jl.git")
Pkg.clone("https://github.com/JuliaDB/DBI.jl.git")
```

### Install required front-end packages
#### Node
``` bash
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install nodejs
```

#### Bower
``` bash
sudo npm install -g bower
```

### Clone repository
``` bash
git clone git@github.com:czlee/adjumo.git
```
or
``` bash
git clone https://github.com/czlee/adjumo.git
```

### Install PostgreSQL 9.4
Required only for Tabbie1 data.

Create the file /etc/apt/sources.list.d/pgdg.list, and place in it the following text:
```
deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
```
Import the repository signing key, update package lists and install:
``` bash
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get install postgresql-9.4
```

Create a user, with the same name as the current user:
```
sudo su postgres -c "createuser ubuntu --pwprompt --createdb"
```
