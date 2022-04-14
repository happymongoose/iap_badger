# iap_badger.isStoreAvailable()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | store, available, availability, connected
| __See also__         | 


## Overview

Returns true if the store is available.  The store may not be available due to connectivity issues, or parental controls or other restrictions in place on the device.

In debug mode, or when running on the simulator, IAP Badger will always report the store as being available.


## Syntax

	iap_badger.isStoreAvailable()


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

--Check if the store is available, and print the result to the console
if (iap.isStoreAvailable()) then
    print ("The user can make in-app purchases.")
else
    print ("The user is blocked from making in-app purchases.")
end



```
