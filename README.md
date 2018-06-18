## Building The AMI

```bash
cd packer
packer build sysbench.json
```

If you want to delete the AMI, make sure to also delete the ELB snapshot associated with it.

## Managing The Infrastructure

- Initialization
    ```bash
    cd terraform
    terraform init
    ```
- Deployment
    ```bash
    terraform apply -var 'apply_immediately=true'
    ```
- Destruction
    ```bash
    terraform destroy
    ```    