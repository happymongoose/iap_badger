# iap_badger.printLoadProductsCatalogue()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | version
| __See also__         | [iap_badger.loadProducts()](loadProducts.markdown), [iap_badger.getLoadProductsCatalogue()](getLoadProductsCatalogue.markdown), [iap_badger.getLoadProductsFinished()](getLoadProductsFinished.markdown)


## Overview

Following a call to [iap_badger.loadProducts()](loadProducts.markdown), this function prints the contents of the products catalogue to the console in human readable form.  This will display the items available for purchase in your app, plus other information about your in-app products such as purchase price and description.

If the product catalogue hasn't loaded for some reason, this function will also print some diagnostic information to support with debugging.

The product catalogue will only contain information after a successful call is made to [iap_badger.loadProducts()](loadProducts.markdown).  There may be a delay between calling [iap_badger.loadProducts()](loadProducts.markdown) and the information being returned by the relevant app store.



## Syntax

	iap_badger.printLoadProductsCatalogue()




## Examples


Printing out in-app product information as returned by the app store:

```lua

--Include the plugin
local iap = require 'plugin.iap_badger'

--Create the catalogue
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
}

--Initialise IAP badger
iap.init(iapOptions)

local function loadProductsListener()
	iap.printLoadProductsCatalogue()
end

--Load the product table - then call the function loadProductsListener
iap.loadProducts(loadProductsListener)


```
