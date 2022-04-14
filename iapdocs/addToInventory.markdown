# iap_badger.addToInventory()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | add, inventory, iap
| __See also__         | [iap_badger.removeFromInventory()](removeFromInventory.markdown) [iap_badger.saveInventory()](saveInventory.markdown)


## Overview

This function adds an item to the inventory.

If the item is a consumable, then the number of items held will be increased by the value specified in itemCount.  If no value for itemCount is given, the quantity will be increased by 1.

If the item is a non-consumable, then it can either be present in the inventory or not (ie. it does not have a quantity associated with it).  Adding non-consumable items multiple times will have no effect.

Note: changes won't be written permanently to the device until the [saveInventory()](saveInventory.markdown) function is called.


## Syntax

	iap_badger.addToInventory( itemName )
	iap_badger.addToInventory( itemName, itemCount )

##### itemName <small>(required)</small>
_[String](http://docs.coronalabs.com/api/type/String.html)._ The name of the item that will be added to the inventory.  This must correspond to an entry in the inventoryItems table in the product catalogue passed to [iap_badger.init()](init.markdown).

##### itemCount <small>(required)</small>
_[Number](http://docs.coronalabs.com/api/type/Number.html)._ How many of the item to add to the inventory.  This is ignored for non-consumable products.



## Examples


Adding a non-consumable item to the inventory:

```lua

--Include the plugin
local iap = require 'iap_badger'

--Create the product catalogue
local catalogue = {

    --Information about the product on the app stores
    products = {	
    },

    --Information about how to handle the inventory item
    inventoryItems = {
        unlock = { productType="non-consumable" },
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

--Add an "unlock" item to the inventory
iap.addToInventory("unlock")

--Print out a copy of the inventory to the console
iap.printInventory()

--Further calls to iap.addToInventory("unlock") would not increase the number of 'unlock' items
--being held.  Non-consumable products are either present in the inventory or not.

--Atempt to add another "unlock" item to the inventory - this will not change anything.
iap.addToInventory("unlock")

--Print out a copy of the inventory to the console to prove the inventory is unchanged.
iap.printInventory()

--Save
iap.saveInventory()

```

Adding a consumable items to the inventory:

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
        coins = { productType="consumable" },
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

--Add a single coin to the inventory
iap.addToInventory("coins")

--Print out a copy of the inventory to the console (ie. 1 coin)
iap.printInventory()

--Add another 50 coins to the inventory
iap.addToInventory("coins", 50)

--Print out the latest version of the inventory (ie. 51 coins)
iap.printInventory()

--Save
iap.saveInventory()

```
