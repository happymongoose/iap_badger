# iap_badger.init()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | init, initialize
| __See also__         | 


## Overview

This function initializes IAP Badger and loads any previously saved inventory.  For an extended tutorial that explains how to set up and use IAP Badger, and in particular the init function, [click here](tutorial.markdown).

Note: on Google IAP, store initialisation is now asynchronous.  That means this function will return immediately, even though the initialisation process will not yet be complete.  You can continue to send commands to IAP Badger, and it will store your requests in a queue, ready to execute when the user's device is ready.  In simulator mode, a short delay is included between your app calling init() and the store being shown as available, to emulate the effect seen on devices in the real world.


## Syntax

	iap_badger.init( options )

##### options <small>(required)</small>  
_[Table](http://docs.coronalabs.com/api/type/Table.html)_ Table specifying how IAP Badger should handle purchases.  For more information, see below.


###Options

The options table can contain the following values:

**catalogue**: <small>(required)</small> a product and inventory catalogue detailing what products can be purchased and how they should be reflected in the user's inventory.  See [this tutorial](tutorial.markdown) for information about setting up a product catalogue.

**filename**: the name of the file in which to store information about the user's inventory.

**refactorTable**: a table specifying how quantities and items should be obfuscated in the inventory file.  For more information, refer to [this tutorial](tutorial.markdown).

**salt**: a salt to apply to the contents of the inventory file during the hashing process.

**badHashResponse**: how IAP Badger should respond when an inventory file's contents do not correspond to it's hash (ie. the file has been tampered with).  Note: the inventory is always emptied when a bad hash is identified.  Possible values are: *emptyInventory*, if should continue without displaying an error message; *errorMessage*, if IAP should tell the user an error occurred; *error*, if IAP Badger should throw an error message to the console, causing the program to fail (used for debugging purposes); or specify a user defined listener function to call when a bad hash is detected.

**failedListener**: a user defined listener function to call when an in-app purchase fails.

**cancelledListener**: a user defined listener function to call when the user cancels an in-app purchase.

**debugMode**: set to *true* to always run IAP Badger in debug mode, even when running on a device.  (When IAP Badger detects it is running in debug mode on a device, it will display a warning when the init function is called).

**debugStore**: set to *apple*, *google* or *amazon* to indicate which store IAP Badger should emulate whilst running in debug mode.  It will default to "apple".

**doNotLoadInventory**: set to *true* to always start with an empty inventory, regardless of the contents of the inventory file.  Useful for debugging during development.

**verboseDebugOutput** - set to **true** to output lots of debugging information to the console 

**usingOldGoogle** - set to **true** if you're using an old build of Corona (earlier than 2017.3105) and don't need to worry about asynchronous changes to store.init.  Since version 9, IAP Badger can auto-detect this, but it's left if you want to set it manually for testing purposes.

**handleInvalidProductIDs** (optional) - set to true to ignore invalid product IDs during a purchase or restore event.  This can be useful if a product ID for an app has been changed/deleted, but some users bought the product in the past (probably during testing) and the product ID doggedly appears in restore cycles.  IAP Badger will tell the store the item has been successfully processed, but in reality this zombie IAP been ignored.  The default value for this flag false.

**googleConvertOwnedPurchaseEvents** (optional) - Google Play returns 'purchase failed' events when a user attempts to re-purchase a non-consumable they've already paid for in the past.  Since version 18, IAP Badger will convert these failed events into successful ones, mimicking the purchase flow seen in iOS.  To turn off this behaviour, set this flag to false.  By default, it. will be set to true.  (Note: technically, this situation cannot arise if you follow Google's recommendations and initiate [iap_badger.restore()](restore.markdown) when your app starts.  This feature offers back-up functionality that catches the problem when it occurs.)


## Examples


Initializing a simple product catalogue that contains consumable and non-consumable items.

```lua

--Include the plugin
local iap = require 'plugin.iap_badger'

--Create the product catalogue
local catalogue = {

    --Information about the product on the app stores
    products = { 
        
        --A consumable product - a pack of 50 coins that can spent and purchased more than once.
        --Always use this identifier to talk to IAP Badger about the purchase.
        buy50coins = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.
                productNames = { apple="buy50coins", google="50_coins", amazon="COINSx50"},
                --The product type
                productType = "consumable",
                --This function is called when a purchase is complete.
                onPurchase=function() iap.addToInventory("coins", 50) end,
                --The function is called when a refund is made
                onRefund=function() iap.removeFromInventory("coins", 50) end,
        },
                
        --A non-consumable product, that can only be purchased once and shared between devices on the user's account.
        --Always use this identifier to talk to IAP Badger about the purchase.
        removeAds = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.
                productNames = { apple="remove_ads", google="REMOVE_BANNER", amazon="Banner_Remove"},
                --The product type
                productType = "non-consumable",
                --This function is called when a purchase is complete.
                onPurchase=function() iap.setInventoryValue("unlock", true) end,
                --The function is called when a refund is made
                onRefund=function() iap.removeFromInventory("unlock", true) end,
        }
        
    },

    --Information about how to handle the inventory item
    inventoryItems = {
        --Inventory items indicating how many coins the user is holding.
        coins = { productType="consumable" },
        --Inventory item to indicate whether the user has purchased the unlock advertisements IAP
        unlock = { productType="non-consumable" }
    }
}

--This table contains all of the options we need to specify in this example program.
local iapOptions = {
    --The catalogue generated above
    catalogue=catalogue,
    --The filename in which to save the inventory
    filename="inventory.txt"
}

--Initialise IAP badger
iap.init(iapOptions)


```
