# iap_badger.purchase()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | purchase, iap, product, buy, transaction, in, app, purchase
| __See also__         | [iap_badger.restore()](restore.markdown) [iap_badger.init()](init.markdown) [iap_badger.setCancelledListener()](setCancelledListener.markdown) [iap_badger.setFailedListener()](setFailedListener.markdown)


## Overview

This function initiates an IAP purchase.  For an extended tutorial that explains how to set up and use IAP Badger, and in particular the purchase function, [click here](tutorial.markdown).

Call the purchase function with the identifier of the product you wish to purchase, as presented in the product catalogue passed to [iap_badger.init()](init.markdown).  IAP Badger will initiate a purchase with the appropriate app store.  Upon a successful purchase, the specified listener function will be called.  If the purchase fails, or is cancelled by the user, a message will be presented to the user.  This functionality can be overridden using the [iap_badger.setCancelledListener()](setCancelledListener.markdown) and [iap_badger.setFailedListener()](setFailedListener.markdown) functions.  Alternative listeners can also be specified in [iap_badger.init()](init.markdown).

Once a successful purchase has been detected, IAP Badger will firstly call the listener specified in the catalogue for this product, which should 'silently' update the user's inventory and make any other changes necessary (ie. without giving the user any on screen messages or sounds).

After this function has been called, IAP Badger will then call the listener function specified in onPurchase, with the name of the product that has been purchased, and the original transaction information as provided by Corona SDK (for those that need it).  This function should be 'noisy', telling the user that their purchase has been successful.  The listener function you supply to onPurchase should take the form:

```lua

--The callback function
--IAP will call purchaseListener with the name of the product
--Transaction is a table containing the original transaction information table passed by Corona
local function purchaseListener(product, transaction)

	--Handle transactions here.
	

end

```

###Google Play (consuming products)

IAP Badger will automatically consume products specified as 'consumable' in your product catalogue - this means your app does not need to make calls to store.consumePurchase following a purchase.

Consumption does not occur immediately - during testing, this was found to crash devices.  Product consumption is a placed on a very short timer (10ms), making the IAP available for re-purchase very shortly after purchasing.

IAP Badger does not do this for 'non-consumable products' - preventing accidental repurchase by the user.


## Syntax

	iap_badger.purchase( product, listener )

##### product <small>(required)</small>
_[Table](http://docs.coronalabs.com/api/type/String.html)._ The name of the item that will be added to the inventory.  This must correspond to an entry in the inventoryItems table in the product catalogue passed to [iap_badger.init()](init.markdown).

##### listener <small>(required)</small>
_[Listener](http://docs.coronalabs.com/api/type/Listener.html)._ A listener function to call after the purchase is successful.



## Examples

### Example 1

The simplest possible code for handling a purchase.  

This code just handles the purchase - it makes no attempt to save any record of it to the user's device.


```lua

--Load IAP Badger
local iap = require("iap_badger")

--Create the catalogue
local catalogue = {

    --Information about the product on the app stores
    products = {     
        --removeAds is the product identifier.
        removeAds = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.
                productNames = { apple="remove_ads", google="REMOVE_BANNER", amazon="Banner_Remove"},
                --The product type
                productType = "non-consumable"
        }
    }
}


--This table contains all of the options we need to specify in this example program.
local iapOptions = { catalogue=catalogue }

--Initialise IAP badger
iap.init(iapOptions)

--Called when the relevant app store has completed the purchase
--Make a record of the purchase using whatever method you like
local function purchaseListener(product )
    print "Purchase made"
end

iap.purchase("removeAds", purchaseListener)

```

### Examples 2

This code handles the purchase and saves a record of it using IAP Badger's inventory management system.


```lua

--Load IAP Badger
local iap = require("plugin.iap_badger")

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
                productType = "non-consumable",
                --This function is called when a purchase is complete.
                onPurchase=function() iap.setInventoryValue("unlock", true) end,
        }
    },

    --Information about how to handle the inventory item
    inventoryItems = {
        unlock = { productType="non-consumable" }
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

---------------------------------
-- 
-- Making purchases
--
---------------------------------

--Called when the relevant app store has completed the purchase
--At this point, "unlock" has already been added to the user inventory.
local function purchaseListener(product )
    --Tell the user their purchase was successful
    native.showAlert("Purchase complete", "Your unlock purchase was successful.")
end

--Tell IAP badger to initiate a purchase
iap.purchase("removeAds", purchaseListener)
    

```

