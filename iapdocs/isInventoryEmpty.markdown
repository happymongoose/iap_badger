# iap_badger.isInventoryEmpty()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | inventory, empty, clear
| __See also__         | 


## Overview

Returns true if the inventory is empty.


## Syntax

	iap_badger.isInventoryEmpty()


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

--The following line will print, "Empty"
if (iap.isInventoryEmpty()) then print ("Empty") else print ("Carrying something") end
--Add a hat to the inventory
iap.addToInventory("hat")
--Now it will print, "Carrying something"
if (iap.isInventoryEmpty()) then print ("Empty") else print ("Carrying something") end

```
