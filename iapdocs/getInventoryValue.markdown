# iap_badger.getInventoryValue()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[String](http://docs.coronalabs.com/api/type/String.html)._  _[Boolean](http://docs.coronalabs.com/api/type/Boolean.html)._
| __Keywords__         | inventory, value, get
| __See also__         | [iap_badger.addToInventory()](addToInventory.markdown) [iap_badger.removeFromInventory()](removeFromInventory.markdown) [iap_badger.setInventoryValue()](setInventoryValue.markdown)


## Overview

Returns the value stored for the specified item in the inventory.

If IAP Badger's default inventory handling has been used, this function will return:

* a number for consumable items, indicating how many of the items are being held.
* true if a non-consumable item is present in the inventory.

If the specified item is not currently being held in the inventory, the function will return nil.  (Note: for consumables, this default behaviour can be overridden by setting the reportMissingAsZero flag to true in the product catalogue).

If [iap_badger.setInventoryValue()](setInventoryValue.markdown) has been used to override IAP Badger's default inventory handling, this function could return a different type.


## Syntax

	iap_badger.getInventoryValue( itemName )

##### itemName <small>(required)</small>
_[String](http://docs.coronalabs.com/api/type/String.html)._ The name of the inventory item as specified in the product catalogue passed to [iap_badger.init()](init.markdown).


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
        unlock = { productType="non-consumable" },        
    }
}

--This table contains all of the options we need to specify in this example program.
local iapOptions = {
    --The catalogue generated above
    catalogue=catalogue,
    --The filename in which to save the inventory
    filename="inventory.txt",
    debugStore="apple",
}

--Initialise IAP badger
iap.init(iapOptions)

-------------------------------------------------------------------------------
--Show values for consumable items in inventory (before / after adding an item)

--By default, getInventoryValue returns nil if item is missing
local hatCount = iap.getInventoryValue("hat")
--Hat count will contain a quantity or nil - output text accordingly
if (hatCount) then print("Value for hats:" .. hatCount) else print ("Hat missing from inventory") end
--Add a hat to the inventory
iap.addToInventory("hat")
--Grab the value and print
hatCount = iap.getInventoryValue("hat")
if (hatCount) then print("Value for hats:" .. hatCount) else print ("Hat missing from inventory") end
print ()

--Use the reportZeroAsMissing flag to return 0 if an item is missing instead
--This time, the the quantity will always be a number
print ("Value for shoes: " .. iap.getInventoryValue("shoes"))
iap.addToInventory("shoes")
print ("Value for shoes: " .. iap.getInventoryValue("shoes"))
print ()

-------------------------------------------------------------------------------
--Show values for non-consumable items in inventory (before / after adding an item)

if (iap.getInventoryValue("unlock")) then print ("Unlock is in inventory") else print ("Unlock missing from inventory") end
iap.addToInventory("unlock")
if (iap.getInventoryValue("unlock")) then print ("Unlock is in inventory") else print ("Unlock missing from inventory") end

```



