# iap_badger.getLoadProductsCatalogue()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[Table](http://docs.coronalabs.com/api/type/Table.html)_
| __Keywords__         | iap, currency, price, title, description, app, store, products, catalogue
| __See also__         | [iap_badger.loadProducts()](loadProducts.markdown), [iap_badger.printLoadProductsCatalogue()](printLoadProductsCatalogue.markdown), [iap_badger.getLoadProductsFinished()](getLoadProductsFinished.markdown)


## Overview

This function returns the product catalogue that was previous loaded by [iap_badger.loadProducts()](loadProducts.markdown).  This catalogue contains information about your app's IAP products as defined in the relevant app store console.  The table will include the product's name and description in the user's local language, and the price in the user's currency (use the table keys **title**, **description** and **localizedPrice**).

When working on the simulator, or in debug mode, the function will return the information hard-coded into the products table (see example below).

There may be a short delay between calling [iap_badger.loadProducts()](loadProducts.markdown) and the product catalogue becoming available on a real device.

For convenience, IAP Badger also provides the [iap_badger.printLoadProductsCatalogue()](printLoadProductsCatalogue.markdown) function for printing out the contents of the product catalogue to the console (for use during testing).

Note: if the relevant app store hasn't returned any product information yet, this function will return an empty {} table.  Your app can manually check whether the product catalogue download is complete by calling the function [iap_badger.getLoadProductsFinished()](getLoadProductsFinished).



## Syntax

	iap_badger.getLoadProductsCatalogue()
	iap_badger.getLoadProductsCatalogue(listener)
	
##### listener <small>(optional)</small>
_[Listener](http://docs.coronalabs.com/api/type/Listener.html)._ A listener function to call once the product catalogue has been downloaded from the app store.



## Examples

Load and print the loadProducts catalogue.


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

	--Grab the product information catalogue
	local products=iap.getLoadProductsCatalogue()

	--Example of how to ask the user if they would like to purchase a product at a given price.
	print ("Would you like to buy a " .. products.buy50coins.title .. " for " .. products.buy50coins.localizedPrice .. "?")
	
	--Print out catalogue
	iap.printLoadProductsCatalogue()
	
end

--Initialise IAP badger
iap.init(iapOptions)

--Load the product catalogue from the relevant app store - when this is complete, print out a sample message
iap.loadProducts(loadProductsListener)


```

