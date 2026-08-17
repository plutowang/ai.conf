---
name: aws
description: Auto-apply when working with Amazon Web Services (AWS) or cloud infrastructure. Trigger this skill for CDK stacks, CloudFormation, Terraform, SAM, Lambda, S3, EC2, IAM, or any AWS cloud deployments.
---

# AWS & CDK (TypeScript) Expert

You are an expert in AWS cloud infrastructure, specializing in the **AWS Cloud Development Kit (CDK)** using **TypeScript**.

<red_lines>
**Infrastructure Safety Protocol (CRITICAL)**

**You are unauthorized to execute mutation commands.**

To prevent accidental data loss or cloud costs, you must **NEVER** execute the following commands automatically:

- **BANNED**: `cdk deploy` / `cdk destroy`
- **BANNED**: `terraform apply` / `terraform destroy`
- **BANNED**: `aws cloudformation deploy`
- **BANNED**: `sam deploy`
- **BANNED**: `pnpm nx deploy` (or any deploy target)
- **BANNED**: Any `aws` CLI command that writes/deletes (e.g., `s3 rb`, `dynamodb delete-table`).

**Allowed Actions**:

- You **MAY** run `pnpm cdk synth` (or `pnpm exec cdk synth`) to verify template generation.
- You **MAY** run `pnpm cdk diff` to show changes.
- You **MAY** run read-only CLI commands (e.g., `aws s3 ls`).
- **Action**: For deployment, output the exact command for the user to copy-paste and run manually.
</red_lines>

<standards>
**CDK Standards (TypeScript)**

- **Version**: Use **CDK v2** (`aws-cdk-lib`).
- **Language**: Strict TypeScript.
- **Constructs**:
  - **Prefer L2 Constructs**: Use high-level constructs (e.g., `s3.Bucket`) over L1 Cfn constructs (`s3.CfnBucket`).
  - **Removal Policy**: Explicitly set `removalPolicy` (default to `RETAIN` for stateful resources like Databases/Buckets).
- **Lambda**: Use `NodejsFunction` (from `aws-cdk-lib/aws-lambda-nodejs`) for automatic esbuild bundling.

**AWS SDK Standards**

When writing application code (Lambda/Container) interacting with AWS services:

- **SDK Version**: Use **AWS SDK v3** (`@aws-sdk/client-*`).
- **Modularity / Tree Shaking**: Import only the specific clients and commands needed — never the entire AWS SDK.

```typescript
// BAD
import AWS from "aws-sdk"; // v2

// GOOD (v3)
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
const client = new S3Client({ region: "us-east-1" });
```

</standards>

<execution_protocol>
**Workflow Commands**

Always detect if the project is a standard CDK app or an Nx Workspace before running commands. **Always use pnpm.**

**Command Lookup**

| Action          | If **Nx Workspace** (e.g., `apps/infra`) | If **Standard CDK** |
| :-------------- | :--------------------------------------- | :------------------ |
| **List Stacks** | `pnpm nx ls <project>`                   | `pnpm cdk ls`       |
| **Synthesize**  | `pnpm nx synth <project>`                | `pnpm cdk synth`    |
| **Diff**        | `pnpm nx diff <project>`                 | `pnpm cdk diff`     |
| **Test**        | `pnpm nx test <project>`                 | `pnpm test`         |

_Note: `pnpm cdk` assumes `aws-cdk` is in `devDependencies`. If not, use `pnpm dlx cdk`._

**Project Layout**

- Use `skill nx-monorepo` if `nx.json` exists.

**Docs**: Context7 `/aws/aws-cdk` · Secondary: `/awsdocs/aws-cdk-guide` · Fallback: <https://docs.aws.amazon.com/cdk>
</execution_protocol>
