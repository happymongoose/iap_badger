# iap_badger.isInInventory()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | inventory, item
| __See also__         | 


## Overview

Returns true if the specified item is currently being held in the inventory.


## Syntax

	iap_badger.inventoryItemCount(itemName)

##### itemName <small>(required)</small>
_[String](http://docs.coronalabs.com/api/type/String.html)._ The name of the item to check.  This must correspond to an entry in the inventoryItems table in the product catalogue passed to [iap_badger.init()](init.markdown).


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
        shoes = { productType="consumable" },
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

--The following line will print, "No hat available".
if (iap.isInInventory("hat")) then print ("You've got a hat") else print ("No hat available") end
--Add a hat to the inventory
iap.addToInventory("hat")
--Now it will print, "You've got a hat".
if (iap.isInInventory("hat")) then print ("You've got a hat") else print ("No hat available") end

print()

--The following line will print, "No shoes available".
if (iap.isInInventory("shoes")) then print ("You have some shoes") else print ("No shoes available") end
--Add 3 shoes to the inventory
iap.addToInventory("shoes", 3)
--Now it will print, "You have some shoes".
if (iap.isInInventory("shoes")) then print ("You have some shoes") else print ("No shoes available") end



```
