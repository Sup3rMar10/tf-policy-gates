# tf-policy-gates

A Terraform pipeline with **policy as code**: the plan is converted to JSON and checked against [OPA/Rego](https://www.openpolicyagent.org/) rules by [Conftest](https://www.conftest.dev/) before anything could be applied. The rules are unit-tested, and a **negative test** proves the gate really rejects a bad plan.

A local file stands in for a real resource, with two rules a security team might write:

1. A file must not be world-writable (`file_permission` last digit 2, 3, 6 or 7).
2. A file must stay under `./out/`.

## Flow

```
terraform plan -out  ->  terraform show -json  ->  conftest test --policy policy
                                                       |
   conftest verify (unit tests for the rules)          v
   bad.tfvars plan MUST be rejected              pass / fail the pipeline
```

## What was checked (2026-10-16)

- **Locally (Docker conftest v0.71.1):** the 4 policy unit tests pass; the good plan passes; the bad plan fails with both messages (`file_permission 0777 is world-writable`, `filename ./../escape.conf is outside ./out/`).
- **On GitHub Actions:** the same steps run and the workflow **succeeded**, including the negative test.

## Why this shape

- **Check the plan, not the source.** The plan has real, resolved values (after variables and modules), so rules cannot be dodged by indirection.
- **Test the policies.** A policy nobody has tested may silently allow everything. `policy/main_test.rego` holds the unit tests; the negative test checks the end-to-end gate.
- **Gate before apply.** Policy runs after plan and before any apply step.

## Honest limits

- The rules target `local_file` only because that runs with no cloud. Real rules would target types like `aws_security_group` or `aws_s3_bucket` and look at their plan attributes.
- No exceptions or waiver mechanism, no severity levels (everything is `deny`), no cost or drift policy.
- Conftest runs from a Docker image pinned by tag, not digest.
- It is not a replacement for scanners such as Trivy or Checkov, which come with prebuilt rule sets; they complement custom policy.

MIT licensed.
