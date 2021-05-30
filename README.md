# terraform-example-ecs-fargate
Minimum example of terrarraform - ECS on Fargate

## Architecture
![Architecture](./doc/architecture.drawio.svg)

### ECS detail
ECS has three important IAM Roles.

![ECS description](./doc/ecs_detail.drawio.svg)

## Code structure
```
terraform
├── env
│   └── example
│       ├── aws.tf
│       └── main.tf
└── module
    ├── container
    │   ├── ecs_cluster.tf
    │   ├── ecs_service.tf
    │   ├── ecs_task.tf
    │   └── variables.tf
    ├── loadbalancer
    │   ├── alb.tf
    │   ├── output.tf
    │   └── variables.tf
    └── network
        ├── output.tf
        └── vpc.tf
```
