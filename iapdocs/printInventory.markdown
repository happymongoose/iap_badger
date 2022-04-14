# iap_badger.printInventory()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[Table](http://docs.coronalabs.com/api/type/Table.html)_
| __Keywords__         | print, inventory, debug, json
| __See also__         | [iap_badger.loadProductsCatalogue()](getLoadProductsCatalogue.markdown)


## Overview

Prints the contents of the inventory, as a string of JSON text, to the console.

## Syntax

	iap_badger.printInventory()


## Examples

Add items to an inventory and print its contents to the console.


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

--Print the contents of the inventory (which will be empty)
iap.printInventory()

--Add 5 hats to the inventory
iap.addToInventory("hat", 5)

--Print the contents of the inventory (which now contains 5 hats)
iap.printInventory()


```

