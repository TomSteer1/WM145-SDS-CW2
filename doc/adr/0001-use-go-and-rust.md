# 1. Use Go and Rust

Date: 2023-04-06

## Status

Accepted

## Context

After using Javascript for the previous project concerning the notes system we felt the language simply wasn't the best for the job.
We believed that using Rust & Go for the implementations was a better choice due to their reliability and performance benefits. Also, JS has some inherent problems with its inference system and being dynamically typed allowing for some funky and weird behaviour that isn't a concern with Rust and Go.

## Decision

Rewrite the notebook system so it uses Rust and Go instead of using Javascript

## Consequences

- Hopefully, the performance of the notebook system will increase
- Maintenance of the codebase may become more difficult due to Rust's steep learning curve.
