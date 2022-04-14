# iap_badger.removeFromInventory()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | remove, item, inventory 
| __See also__         | [iap_badger.addToInventory()](addToInventory.markdown) [iap_badger.saveInventory()](saveInventory.markdown)


## Overview

This function removes an item from the inventory.

If the item is a consumable, then the number of items held will be decreased by the value specified in itemCount.  If no value for itemCount is given, the quantity will be decreased by 1.  If an item's quantity reaches 0, then it is removed from the inventory.  If itemCount is specified, and reducing this many units will reduce the item's quantity to below below 0, IAP Badger will throw an error.

By default, non-consumables cannot be removed from the inventory, as they represent purchases that cannot be taken away from the user.  To override this functionality, set itemCount to true.

Note: changes won't be written permanently to the device until the [saveInventory()](saveInventory.markdown) function is called.


## Syntax

	iap_badger.removeFromInventory( itemName )
	iap_badger.removeFromInventory( itemName, itemCount )

##### itemName <small>(required)</small>
_[String](http://docs.coronalabs.com/api/type/String.html)._ The name of the item that will removed from the inventory.  This must correspond to an entry in the inventoryItems table in the product catalogue passed to [iap_badger.init()](init.markdown).

##### itemCount <small>(required)</small>
_[Number](http://docs.coronalabs.com/api/type/Number.html)._ How many of the item to remove from the inventory.  Set to true to override defaults and remove a non-consumable product.



## Examples


Removing a non-consumable item from the inventory:

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

--Remove the "unlock" item
--By default, this will fail, because non-consumables should not be taken away from the user.  Call removeFromInventory with itemCount set to true to override this functionality.
iap.removeFromInventory("unlock", true)

--Print out a copy of the inventory to the console - it will now be empty
iap.printInventory()

--Save
iap.saveInventory()


```

Removing consumable items to the inventory:

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

--Add 10 coins to the inventory
iap.addToInventory("coins", 10)

--Print out a copy of the inventory to the console (ie. 10 coins)
iap.printInventory()

--Remove 1 coin from the inventory
iap.removeFromInventory("coins")

--Print out the latest version of the inventory (ie. 9 coins)
iap.printInventory()

--Remove 5 coin from the inventory
iap.removeFromInventory("coins",5)

--Print out the latest version of the inventory (ie. 4 coins)
iap.printInventory()

--Save
iap.saveInventory()


```
