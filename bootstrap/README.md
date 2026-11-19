# 🚀 Terraform Bootstrap Module (Remote State & Lock Table)

> Provisions the **Amazon S3 remote state bucket** and **DynamoDB state locking table** required for team collaboration, pipeline concurrency protection, and CI/CD automation.

---

## 🏛️ What This Provisions
1. **Amazon S3 Bucket**: Encrypted (AES256), versioned (for instant disaster recovery), and 100% blocked from public access.
2. **Amazon DynamoDB Table**: Serverless (`PAY_PER_REQUEST` billing mode, zero idle cost) with primary partition key `LockID`.

---

## ⚡ How to Apply the Bootstrap (One-Time Execution)

### Step 1: Navigate to the Bootstrap Directory
```bash
cd hospital_terraform/bootstrap
```

### Step 2: Initialize & Apply
```bash
terraform init
terraform apply -auto-approve
```

### Step 3: Copy the Generated Backend Output
The command outputs:
* `state_bucket_name`: `hospital-system-tfstate-<YOUR_ACCOUNT_ID>`
* `dynamodb_table_name`: `hospital-system-terraform-locks`
* `backend_config_instruction`: Ready-to-use Terraform backend snippet.

### Step 4: Enable the Remote Backend in `hospital_terraform/terraform/`
Create or edit `hospital_terraform/terraform/backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "hospital-system-tfstate-<YOUR_ACCOUNT_ID>"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hospital-system-terraform-locks"
    encrypt        = true
  }
}
```

Then initialize the main infrastructure with state migration:
```bash
cd ../terraform
terraform init
```
All future state snapshots are now securely encrypted in S3 with concurrent locking in DynamoDB!
