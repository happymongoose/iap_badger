# iap_badger.getStoreName()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[String](http://docs.coronalabs.com/api/type/String.html)._
| __Keywords__         | store, name, text, string
| __See also__         | [iap_badger.init()](init.markdown)


## Overview

This function returns the name of the store as a user readable string that is relevant for the current device.

This is useful for when you are sending the user messages about contacting the app store.  For example, on iOS, you may wish to ask the user, 'Buy 50 coins from the App Store?"  But on Android, you would want the string to read, 'Buy 50 coins from Google Play?'

When in debug mode, or on the simulator, IAP Badger will pretend to be the app store specified in the debug settings for [iap_badger.init()](init.markdown).

## Syntax

	iap_badger.getStoreName()

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
    debugStore="apple",
}


--Initialise IAP badger
iap.init(iapOptions)

--The store name that gets printed depends on the user's device.
print ("Would you like to buy 50 coins from the " .. iap.getStoreName() .. "?")



```
