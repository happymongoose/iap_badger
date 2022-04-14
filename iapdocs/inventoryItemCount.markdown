# iap_badger.inventoryItemCount()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | inventory, item, count, categories
| __See also__         | 


## Overview

Returns how many different categories of item are currently being held in the inventory.


## Syntax

	iap_badger.inventoryItemCount()


## Examples


```lua

--Include the plugin
local iap = require 'plugin.iap_badger'

--Create the product catalogue
local catalogue = {

    --Information about the product on the app stores
    products = {    
    },

    --Information about how to handle the inventory item
    inventoryItems = {
        hat = { productType="consumable" },
        shoes = { productType="consumable", reportMissingAsZero=true },
    }
}

--This table contains all of the options we need to specify in this example program.
local iapOptions = {
    --The catalogue generated above
    catalogue=catalogue,
    --The filename in which to save the inventory
    filename="inventory.txt",
}

--Initialise IAP badger
iap.init(iapOptions)

--Add a hat to the inventory
iap.addToInventory("hat")
--Returns an inventory item count of 1 (there is only 1 type of object in the inventory)
print (iap.inventoryItemCount())

--Add 3 shoes to the inventory
iap.addToInventory("shoes", 3)
--Returns an inventory item count of 2 (there are now 2 types of object in the inventory, although there are 4 objects being held in total).
print (iap.inventoryItemCount())


```
