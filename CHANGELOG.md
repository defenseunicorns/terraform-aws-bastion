# Changelog

## [0.0.8](https://github.com/defenseunicorns/terraform-aws-uds-bastion/compare/v0.0.6...v0.0.8) (2023-09-21)


### Bug Fixes

* move zarf from /usr/local/bin to /usr/bin, which is in root's PATH ([#55](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/55)) ([55c90ac](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/55c90ac2c6d65b48c26567a322f4dbfc17d98ff0))
* require aws provider 4.9.0 or better due to s3 bucket deletion issue ([#51](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/51)) ([ff68809](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/ff6880985547082ebc6a7055e7d79e8c807211dd))


### Miscellaneous Chores

* release 0.0.8 ([3caeb06](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/3caeb0611eca49415e9719f8f6bfe170af222374))

## [0.0.6](https://github.com/defenseunicorns/terraform-aws-uds-bastion/compare/v0.0.5...v0.0.6) (2023-09-19)


### Miscellaneous Chores

* add ability to use update chatops command ([#46](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/46)) ([7db86d3](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/7db86d3b008560a87efd5713a37ef1c87a1a0c95))
* add missing autoformat makefile target ([#50](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/50)) ([9697f8f](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/9697f8f7d567d424d77255d42aeed9f1fc3e62a2))
* Delete .tool-versions file ([#49](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/49)) ([c110a7a](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/c110a7a6302aa48974e8e9b98951063b83f8bbf2))
* **deps:** update all dependencies ([#34](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/34)) ([b12c8e1](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/b12c8e1a6282b38b534bef84eaab133f428ba63c))

## [0.0.5](https://github.com/defenseunicorns/terraform-aws-uds-bastion/compare/v0.0.4...v0.0.5) (2023-08-28)


### Features

* install Zarf to /usr/local/bin so that it appears on $PATH ([#43](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/43)) ([71b0cc0](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/71b0cc038c96569ac22541ba1bdd70c30ea828f3))

## 0.0.4 (2023-08-28)


### Bug Fixes

* fix issues with linux userdata script that were causing errors when trying to install zarf ([#39](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/39)) ([f00479e](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/f00479eb38dcd1f37a3e15cea69bdd7686f8dc70))


### Miscellaneous Chores

* **ci:** configure release-please ([#40](https://github.com/defenseunicorns/terraform-aws-uds-bastion/issues/40)) ([ea6e7d0](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/ea6e7d0bb0101b5ad6ebe5fdbf9efb9c93c5feb9))
* release v0.0.4 ([8a78180](https://github.com/defenseunicorns/terraform-aws-uds-bastion/commit/8a78180ae500d540a142e321f54be093f8cdbcbc))
