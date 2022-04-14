# iap_badger.saveInventory()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[Table](http://docs.coronalabs.com/api/type/Table.html)_
| __Keywords__         | inventory, save, serialize
| __See also__         | [iap_badger.loadInventory()](loadInventory.markdown)


## Overview

Saves the inventory to the file specified in [iap_badger.init()](init.markdown).  Whenever a file is saved, random variables will be randomised, and item refactoring occurs automatically.

If **true** is passed to saveInventory(), the inventory file will not be saved to the user's device.  Instead, the function will return a hashed, JSON string representing the user's current inventory (as it would have been saved on the user's device).  This data can then be stored elsewhere (for instance, on the cloud).  This string can be passed to [iap_badger.loadInventory()](loadInventory.markdown) to recover the inventory at a later date.

## Syntax

	iap_badger.saveInventory()
	iap_badger.saveInventory(asString)

##### asString <small>(optional)</small>
_[Table](http://docs.coronalabs.com/api/type/String.html)._ Set to true to return a string containing the inventory file contents instead of saving them on the user's device.


## Examples

Add a product to the inventory and save it to the file inventory.txt


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

--Add an item to the inventory
iap.addToInventory("hat")

--Save the inventory file - this will now contain a hat.
iap.saveInventory()

```

