# iap_badger.getLoadProductsFinished()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | version
| __See also__         | [iap_badger.getLoadProductsCatalogue()](getLoadProductsCatalogue.markdown), [iap_badger.printLoadProductsCatalogue()](printLoadProductsCatalogue.markdown), [iap_badger.loadProducts()](loadProducts.markdown)


## Overview

Following a call to [iap_badger.loadProducts()](loadProducts.markdown), this function returns true if the product catalogue has been completely downloaded by the relevant app store.  The download product catalogue contains information about IAPs that are available for purchase, as well as their description and price.



## Syntax

	iap_badger.getLoadProductsFinished()




## Examples


Querying the library version currently in use:


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
                --This function is called when a purchase is complete.
                onPurchase=function() iap.addToInventory("coins", 50) end,
                --The function is called when a refund is made
                onRefund=function() iap.removeFromInventory("coins", 50) end,
                
                --Simulator / debug information about app store pricing etc.
                simulatorPrice = "£0.79",
                simulatorDescription = "A packy of 50 shiny coins.  Spend them wisely.",
                simulatorTitle = "50 coins",
                
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

local function loadProductsListener()

    --This will return true - the listener is called once the product catalogue is ready
    if (iap.getLoadProductsFinished()) then print "Product catalogue ready" else print "Product catalogue still being downloaded" end
	
end

--Initialise IAP badger
iap.init(iapOptions)

--Load the product catalogue from the relevant app store - when this is complete, print out a sample message
iap.loadProducts(loadProductsListener)

--This will return false - there will be a delay between calling loadProducts and the process of downloading the IAP data being completed
if (iap.getLoadProductsFinished()) then print "Product catalogue ready" else print "Product catalogue still being downloaded" end




```
