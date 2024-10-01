[![Infrastructure As Code with Terraform and Ansible](https://github.com/SergioAnastacio/cmcio-iasc/actions/workflows/main.yml/badge.svg)](https://github.com/SergioAnastacio/cmcio-iasc/actions/workflows/main.yml)
# Proyecto de Ansible y Terraform

## Descripción
Este proyecto utiliza Ansible y Terraform para la gestión y automatización de infraestructura. Terraform se encarga de la provisión de recursos en la nube, mientras que Ansible se utiliza para la configuración y administración de estos recursos.

## Requisitos
- [Terraform](https://www.terraform.io/downloads.html) >= 0.12
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.9
- Proveedor de nube (AWS, Azure, GCP, etc.)

## Estructura del Proyecto
```
cmcio-iasc/
├── ansible/
│   ├── playbooks/
│   └── roles/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

## Uso

### Terraform
1. Inicializa el directorio de trabajo:
    ```sh
    terraform init
    ```
2. Revisa el plan de ejecución:
    ```sh
    terraform plan
    ```
3. Aplica los cambios:
    ```sh
    terraform apply
    ```

### Ansible
1. Ejecuta un playbook:
    ```sh
    ansible-playbook playbooks/mi_playbook.yml
    ```

## Contribuciones
Las contribuciones son bienvenidas. Por favor, abre un issue o un pull request para discutir cualquier cambio.

## Licencia
Este proyecto está licenciado bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.
