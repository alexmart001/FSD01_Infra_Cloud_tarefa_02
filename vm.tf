# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm_task_02" {
    name                  = "vm_task_02"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg_task_02.name
    network_interface_ids = [azurerm_network_interface.nic_task_02.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvmdb"
    admin_username = var.user
    admin_password = var.password
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storage_task_02.primary_blob_endpoint
    }

    tags = {
        environment = "Task 02"
    }

    depends_on = [  azurerm_resource_group.rg_task_02, 
                azurerm_network_interface.nic_task_02,
                azurerm_storage_account.storage_task_02,
                azurerm_public_ip.publicip_task_02 ]

}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_linux_virtual_machine.vm_task_02]
  create_duration = "30s"
}

resource "null_resource" "upload" {
    provisioner "file" {
        connection {
            type        = "ssh"
            user        = var.user
            password    = var.password
            host        = data.azurerm_public_ip.ip_task_02_data.ip_address
        }
        source = "ansible"
        destination = "/home/azureuser"
    }

    depends_on = [ time_sleep.wait_30_seconds ]
}

resource "null_resource" "deploy" {
    triggers = {
        order = null_resource.upload.id
    }

    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            user        = var.user
            password    = var.password
            host        = data.azurerm_public_ip.ip_task_02_data.ip_address
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y software-properties-common",
            "sudo apt-add-repository --yes --update ppa:ansible/ansible",
            "sudo apt-get -y install python3 ansible=2.9.16-1ppa~bionic",
            "ansible-playbook -i /home/azureuser/ansible/hosts /home/azureuser/ansible/provisioning.yml"
        ]
    }
}