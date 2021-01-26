resource "azurerm_storage_account" "storage_task_02" {
    name                        = "stgtask02"
    resource_group_name         = azurerm_resource_group.rg_task_02.name
    location                    = var.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Task 02"
    }
}
