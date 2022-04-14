# iap_badger.getTargetStore()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[String](http://docs.coronalabs.com/api/type/String.html)._
| __Keywords__         | target, store
| __See also__         | 


## Overview

Returns the name of the target store for the current device, as returned by the default Corona libraries.

Note: on the simulator, this will always return the string 'simulator'.


## Syntax

	iap_badger.getTargetStore()

## Examples

```lua

--Include the plugin
local iap = require 'plugin.iap_badger'

--Create the product catalogue
local catalogue = {

    --Information about the product on the app stores
    products = { 
        
        --buy50coins is the product identifier.
        --Always use this identifier to talk to IAP Badger about the purchase.
        buy50coins = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.
                productNames = { apple="buy50coins", google="50_coins", amazon="COINSx50"},
                --The product type
                productType = "consumable",
                
        },
                
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

--Print the name of the store relevant to the current device
print (iap.getTargetStore())


```
