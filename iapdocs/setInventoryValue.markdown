# iap_badger.setInventoryValue()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | inventory, set, value
| __See also__         | [iap_badger.addToInventory()](addToInventory.markdown)  [iap_badger.saveInventory()](saveInventory.markdown)


## Overview

This function specifies the value of an item in the inventory.  It's main purpose is to allow an app to piggyback IAP Badger's save and restore functionality, permitting an app to store variables alongside IAP Badger's inventory.  Changes won't be written permanently to the device until the [saveInventory()](saveInventory.markdown) function is called.

Warning: this function should not be used to change the value of inventory items already handled by IAP Badger, or an error may be thrown.



## Syntax

	iap_badger.setInventoryValue( itemName, value )

##### itemName <small>(required)</small>
_[String](http://docs.coronalabs.com/api/type/String.html)._ The name of the item in the inventory whose value will be changed.  This must correspond to an entry in the inventoryItems table in the product catalogue passed to [iap_badger.init()](init.markdown).

##### itemCount <small>(required)</small>
A value to give the item.  This can be any of the standard Corona data types, including tables.



## Examples


Saving additional quantities alongside IAP Badger's inventory information.

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
        --The following inventory item will be handled by IAP Badger
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

iap.printInventory()

--Save the app's high score information alongside the inventory.
iap.setInventoryValue("hiscore", 10000)
iap.setInventoryValue("hiscore_playername", "Jim")

--Save the inventory
iap.saveInventory()

--Next time the inventory is loaded, the high score information as specified above will be available.

```
