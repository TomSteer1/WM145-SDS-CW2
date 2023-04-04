# ACME Automotive Finance's internal notes system

A simple notes system for use internally within a company, all notes are stored in a central SQLite3 database


This repo contains 3 implementations of the notes system. The orginial, using javascript an implementation in Rust using the Rocket.rs framework & an implementation using GO

## Dependencies
- [Rust (rustup, rustc, cargo)](https://www.rust-lang.org/tools/install)
- [Go](https://go.dev/learn/)
- [NodeJS & npm](https://nodejs.org/en/)
- [Docker (Only if planning to run through docker)](https://www.docker.com/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform (easiest to use package manager)](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


## Getting started

### In the cloud
- Install terraform and the AWS CLI
- Set up the AWS CLI
```bash
aws configure
# When prompted enter your acces key, secret key, and region
# More info can be found here --> https://docs.aws.amazon.com/cli/latest/reference/configure/
```

- Clone the repo and navigate to the terraform directory
```bash
 git clone https://github.com/oSharpey/sds-cw2
 cd sds-cw2/terraform
```

- To launch the cloud infrustructre run:
```bash
terraform init
terraform plan # this lets you check the resources that will be created
terraform apply # --auto-approve if you feel like
```

- To tear down the infrustructre run:
```bash
terraform destroy # --auto-approve if you feel like
```

Navigate to the URL of the implementation of your choice
- https://rust.tomsteer.host
- https://js.tomsteer.host
- https://go.tomsteer.host


### Running & Building locally
#### Rust
- Clone the repo
``` bash
git clone https://github.com/oSharpey/sds-cw2
cd sds-cw2
```

- Navigate to the rust-notebook directory
- Build and run the binary
``` bash
cd rust-notebook/
cargo run  # For full debug info
# OR
cargo run --release  # For optimised release version
```
Go to http://localhost:8080 and enjoy!

---
#### GO
- Clone the repo
``` bash
git clone https://github.com/oSharpey/sds-cw2
cd sds-cw2
```
- Navigate to the go-notebook/app directory
- Build and run the binary
``` bash
cd go-notebook/app
go run main.go
```
Go to http://localhost:8080 and enjoy!

---

#### JavaScript
- Clone the repo
``` bash
git clone https://github.com/oSharpey/sds-cw2
cd sds-cw2
```
- Navigate to the js-notebook/app directory
- Install dependencies
- Run the server
``` bash
cd js-notebook/app
npm i
npm start
```
Go to http://localhost:8080 and enjoy!

### Running through docker
#### Pulling the package from the repo
- Download your chosen implementation
``` bash
docker pull ghcr.io/osharpey/go-notes:latest
docker pull ghcr.io/osharpey/js-notes:latest
docker pull ghcr.io/osharpey/rust-notes:latest
```
- List all the images on your system
- Run the docker container with the image id of your chosen package

``` bash
docker images
docker run <image id>
```
Go to http://localhost:8080 and enjoy!

---

#### Building the docker image locally
- Clone the repo
``` bash
git clone https://github.com/oSharpey/sds-cw2
cd sds-cw2
```
- Navigate to the directory containing the docker file of the implementaion you want to build
- Build the docker image
- Run the container

``` bash
cd <dir>  # rust-notebook/ js-notebook/ go-notebook
docker build .  # optionally add '-t <name>' to add a tag to the image
docker run <image id>  # run with the docker image id of the image you just built
```

---
# To-Do
- [ ] Architecture Diagram
- [ ] ADRs
- [x] Funcional locally
- [x] Deploy to cloud
- [x] Scripted Cloud Creation
- [x] Automation
  - [x] Testing
  - [x] Building
  - [x] Deploying
- [x] Tear down command
- [ ] Message Logging
  - [x] Implement Message Logging
  - [ ] Design Message Logging algorithm 
