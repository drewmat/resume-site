# Resume Website on AWS using Terraform

## 📚 Project Overview
This project automates the deployment of a personal resume website on AWS using Terraform. It provisions secure and scalable infrastructure, making it easy to host and maintain your personal or professional resume site.

---

## ✅ Features
- Infrastructure-as-Code with Terraform
- Static website hosting on AWS S3
- Content delivery with AWS CloudFront
- Domain management via AWS Route 53 (optional)
- HTTPS using AWS Certificate Manager
- Automatic caching

---

## 🛠️ Prerequisites
- Terraform (v1.0 or newer recommended)
- AWS CLI configured with credentials
- An AWS account with permissions for S3, CloudFront, ACM, and Route 53
- A registered domain name (if using custom domain)

---

## 🚀 Project Structure
```
.
├── main.tf            # Primary infrastructure definitions
├── variables.tf       # Input variables for customization
├── s3.tf              # S3 bucket configuration for static site
├── certificate.tf     # HTTPS Certificate
├── cloudfront.tf      # CloudFront distribution setup
├── route53.tf         # DNS records (optional)
└── README.md
```

---

## 🔧 Deployment Steps

1. **Clone the repository**
```bash
git clone https://github.com/drewmat/resume-site.git
cd resume-site
```

2. **Customize Variables**
- Edit `variables.tf` or create a `terraform.tfvars` file to set:
  - Domain name
  - Region
  - Bucket names

3. **Initialize Terraform**
```bash
terraform init
```

4. **Plan the infrastructure**
```bash
terraform plan
```

5. **Apply the configuration**
```bash
terraform apply
```
> ⚠️ Confirm with `yes` when prompted.

6. **Upload Your Website Content**
- Upload your `index.html`, `resume.pdf`, and any static assets to the created S3 bucket.
- Example:
```bash
aws s3 sync ./site-content s3://your-s3-bucket-name
```

---

## 🌎 Access Your Website
Once deployment is complete, Terraform will output the CloudFront URL or your custom domain where your resume site is live.

---

## 🧹 Teardown
To remove all resources:
```bash
terraform destroy
```

---

## 🤝 Contributions
Feel free to fork and submit pull requests for improvements or additional features!

---

## 📄 License
This project is licensed under the MIT License.

---

## 📬 Contact
For questions or suggestions, reach out to [andy.engdahl@gmail.com](mailto:andy.engdahl@gmail.com).

---

## ⭐️ If you found this helpful, please give the repo a star!

