# 2. Use AWS

Date: 2023-04-06

## Status

Accepted

## Context

After running the docker containers locally, we identified a need for a more automated way to redeploy the notebook instances whenever we update the code. There was also a need to futureproof our infrastructure in case traffic to the site increases. Using AWS and terraform allows the provisioning of infrastructure to be automated through github actions. AWS is also very easily scalable incase demand increases.

## Decision

Host the notebook system on AWS infrastructure and use terraform to provision and destroy this infrastructure using GitHub actions.

## Consequences

- Easy to scale compared to using your own servers
- Deployment can be easily automated
- AWS may cost more in the long term depending on how much usage increases by
- Could introduce security issues with accidental leaks of AWS access keys.

