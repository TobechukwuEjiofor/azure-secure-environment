# Project Brief (Closed Out): Secure Azure Environment for Bridgeline Pay

**Status:** Complete. Built, tested, destroyed, rebuilt from a fresh clone, and destroyed again.

## Goal

Rebuild a fictional fintech's insecure, portal-built Azure environment as Terraform code, and answer a partner bank's five security questions with evidence.

## Delivered

- A three-tier Azure environment of 34 resources in `uksouth`: network and subnets, NSGs, a bastion, a private app VM, a public load balancer, a private PostgreSQL database, a Key Vault and remote Terraform state
- A bootstrap configuration for the state storage account
- `evidence.sh`, which prints proof for each acceptance test
- A README, a Hashnode post and this brief

## Acceptance results

All seven passed: load balancer serves the page; direct SSH to the app VM fails and bastion SSH works; the bastion allows one admin IP only; the app VM reaches the database and the bastion cannot; no password in any commit and the VM fetches it from Key Vault; destroy and fresh-clone rebuild; state remote and locked.

## Known limitations

- Allow-lists depend on one admin IP, which changes
- No HTTPS or domain
- Single instances, no redundancy
- Key Vault public endpoint behind a firewall, not a private endpoint
- Shared-key access still enabled on the state storage account
- The generated database password is also stored in the state file
- `psql` installed by hand for testing

## Cost and cleanup

The environment is destroyed (`az group exists` returned `false`). Only the state storage account (`rg-azsecure-tfstate`) remains, at a very small cost.

## Before making the repo public

1. Run `git grep -n "<first 8 characters of your subscription ID>"` and confirm it prints nothing.
2. Confirm no `.tfvars`, `.tfstate` or `.tfplan` files are tracked.
3. Blur public IPs in any screenshots.
4. Optionally remove stale IPs from the state storage firewall.
