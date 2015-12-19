# Setting up an Amazon EC2 instance

## Launch a new instance
- Launch an **Ubuntu Server** instance (not Amazon Linux).
- Don't forget to configure an appropriate security group, it should allow both
  SSH and HTTP

## Summary
``` bash
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo add-apt-repository ppa:staticfloat/juliareleases
sudo add-apt-repository ppa:staticfloat/julia-deps
sudo apt-get update
sudo apt-get install git julia gcc g++ make libgmp-dev nodejs
sudo npm install -g bower
git clone git@github.com:czlee/adjumo.git
```

In Julia:
``` julia
for p in ["JuMP", "ArgParse", "Formatting", "JSON", "Cbc", "GLPKMathProgInterface"]; Pkg.add(p); end
for p in ["JuliaDB/DBI", "JuliaDB/PostgreSQL"]; Pkg.clone("https://github.com/$p.jl.git"); end
```

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
