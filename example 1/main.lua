
--Example1.lua
--
--Simplest possible example of using IAP Badger to purchase an IAP.

---------------------------------
-- 
-- IAP Badger initialisation
--
---------------------------------

--Load IAP Badger
local iap = require("iap_badger")

--Create the catalogue
local catalogue = {

    --Information about the product on the app stores
    products = {	    
        --removeAds is the product identifier.
        --Always use this identifier to talk to IAP Badger about the purchase.
        removeAds = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.
                productNames = { apple="remove_ads", google="REMOVE_BANNER", amazon="Banner_Remove"},
                --The product type
                productType = "non-consumable"
        }
    }

}

--This table contains all of the options we need to specify in this example program.
local iapOptions = {
    --The catalogue generated above
    catalogue=catalogue,
}

--Initialise IAP badger
iap.init(iapOptions)

--Called when the relevant app store has completed the purchase
--Make a record of the purchase using whatever method you like
local function purchaseListener(product )
    print "Purchase made"
end


---------------------------------
-- 
-- Main game code
--
---------------------------------

iap.purchase("removeAds", purchaseListener)

