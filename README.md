# Terraform playground

This is a terraform playground to be used with docker desktop and kubernetes.

## Init

```powershell
kind create cluster --config ./kind.yaml
```

## Usage

```bash
terraform init; terraform plan; terraform apply -auto-approve;
```

## Debugging

```bash
kubectl get deployments,ingress,services,pods --all-namespaces

kubectl get deployments --all-namespaces
kubectl get ingress --all-namespaces
kubectl get services --all-namespaces
kubectl get pods --all-namespaces
```

## `terraform init` - Only run when:
- **First time** setting up a new Terraform configuration
- **Adding new providers** (like when you add a new provider to providers.tf)
- **Adding new modules** (like when you added the `api-nginx` module)
- **Changing backend configuration** (if you configure remote state storage)
- **Updating provider versions** in your configuration

## `terraform plan` - Run when:
- **Before applying changes** to see what Terraform will do
- **After making configuration changes** to verify your changes look correct
- **Debugging** to understand why something isn't working as expected

## Typical workflow:

1. **First time setup:**
   ```powershell
   terraform init
   terraform plan
   terraform apply
   ```

2. **Making configuration changes** (like editing your nginx config):
   ```powershell
   terraform plan    # Review changes
   terraform apply   # Apply if plan looks good
   ```

3. **Adding new modules or providers:**
   ```powershell
   terraform init    # Initialize new components
   terraform plan    # Review what will be created
   terraform apply   # Apply changes
   ```
