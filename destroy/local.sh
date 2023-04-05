#!/bin/bash
docker run --rm -it -v "$(pwd):/vol" -v "/home/tom/.aws:/home/aws-nuke/.aws" rebuy/aws-nuke -c /vol/nukeconfig.yml --profile "wm145-01" -q --no-dry-run 
