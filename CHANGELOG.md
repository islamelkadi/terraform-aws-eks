## [1.1.4](https://github.com/islamelkadi/terraform-aws-eks/compare/v1.1.3...v1.1.4) (2026-03-18)


### Bug Fixes

* consolidate 6 SG rule resources into 2 using static index keys ([38282a1](https://github.com/islamelkadi/terraform-aws-eks/commit/38282a195340ba5fa49556c3533800bb23b77512))

## [1.1.3](https://github.com/islamelkadi/terraform-aws-eks/compare/v1.1.2...v1.1.3) (2026-03-18)


### Bug Fixes

* convert SG rules from count to for_each to resolve unknown value at plan time ([353b487](https://github.com/islamelkadi/terraform-aws-eks/commit/353b48710cc170948b3e586b3013dcbe8423e1fe))

## [1.1.2](https://github.com/islamelkadi/terraform-aws-eks/compare/v1.1.1...v1.1.2) (2026-03-16)


### Bug Fixes

* Resolve security group rule conflicts with separate resources ([ef1f130](https://github.com/islamelkadi/terraform-aws-eks/commit/ef1f13084fcfad384d1925ed81dfceda8bfddf88))


### Documentation

* Update README with new security group configuration options ([59cd401](https://github.com/islamelkadi/terraform-aws-eks/commit/59cd4018483f026b22a3ea9cbe1650001198e9b4))

## [1.1.1](https://github.com/islamelkadi/terraform-aws-eks/compare/v1.1.0...v1.1.1) (2026-03-16)


### Bug Fixes

* Resolve security group rule conflicts in EKS module ([ff8fbe8](https://github.com/islamelkadi/terraform-aws-eks/commit/ff8fbe881945a4a6ab517b1d5cc3529524bcc532))

## [1.1.0](https://github.com/islamelkadi/terraform-aws-eks/compare/v1.0.2...v1.1.0) (2026-03-16)


### Features

* Add flexible security group configuration to EKS module ([09dce47](https://github.com/islamelkadi/terraform-aws-eks/commit/09dce476dc3dfbad4a0eca994a38b25403dae638))

## [1.0.2](https://github.com/islamelkadi/terraform-aws-eks/compare/v1.0.1...v1.0.2) (2026-03-15)


### Bug Fixes

* update VPC module to v1.0.1 to resolve flow logs module path issue ([d5f4a62](https://github.com/islamelkadi/terraform-aws-eks/commit/d5f4a622ee6bce4e07228d2f85bc1fbabd300749))

## [1.0.1](https://github.com/islamelkadi/terraform-aws-eks/compare/v1.0.0...v1.0.1) (2026-03-15)


### Bug Fixes

* Add missing TLS provider constraint and update metadata version ([9717204](https://github.com/islamelkadi/terraform-aws-eks/commit/97172041b52582266b784b1c60c94e8263541b92))

## 1.0.0 (2026-03-15)


### Features

* Add comprehensive EKS example and security improvements ([d73d09d](https://github.com/islamelkadi/terraform-aws-eks/commit/d73d09dadf0d8961a30f17773a2469ed8b308ee4))
