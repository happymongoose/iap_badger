# iap_badger.loadInventory()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[Table](http://docs.coronalabs.com/api/type/Table.html)_
| __Keywords__         | load, read, inventory
| __See also__         | [iap_badger.saveInventory()](saveInventory.markdown)


## Overview

Attempts to load the inventory from the filename specified in [iap_badger.init()](init.markdown).  If the file does not exist, an empty inventory is returned.  If the hash on the inventory file does not correspond to its contents, then an empty inventory will also be applied.

If a string is passed to the loadInventory, then IAP Badger will attempt to load the inventory from the hashed JSON string provided rather than from a device file.  A valid string can be generated from the [iap_badger.saveInventory()](saveInventory.markdown) function.  This allows IAP Badger to load an inventory recovered from a location other than the user's device (the cloud, for instance).

Note: the inventory file is automatically loaded from the users device when IAP Badger is initialized through the [iap_badger.init()](init.markdown) function call.


## Syntax

    iap_badger.loadInventory()
	iap_badger.loadInventory(inventoryString)

##### product <small>(optional)</small>
_[Table](http://docs.coronalabs.com/api/type/String.html)._ An optional string to load the inventory from.


## Examples

Load and print the loadProducts catalogue.


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

--Load inventory file - on a first run, this will be empty.
iap.loadInventory()



```

