# iap_badger
A unified approach to in-app purchases with Corona SDK


## Purpose:

Although Corona SDK offers an IAP API that is quite similar across the app stores, there are differences depending on whether you are connecting to Apple's App Store, Google Play or through Amazon.  I wanted to produce a unified approach to IAP processing, that meant I could write one piece of code that would function whatever the device.  The result is IAP badger.


### General features:

* a unified approach to calling store and IAP whether you're on the App Store, Google Play, or wherever
* simplified calling and testing of IAP functions - just provide IAP Badger with a list of products and some simple callbacks for when items are purchased / restored or refunded
* a testing mode, so your IAP functions can be tested on the simulator or a real device without having to contact an actual app store.
* simplified product maintenance (adding/removing products from the inventory)
* handling of loading / saving of items that have been purchased
* products can have different names across the range of stores (so an upgrade called 'COIN_UPGRADE' in iTunes  Connect could be called 'coins_purchased' in Google Play) without the need for additional code
* different product types available (consumable or non-consumable)


### Inventory / security features:

* customise the filename used to save the contents of the inventory
* inventory file contents can be hashed to prevent unauthorised changes (specify a 'salt' in the init() function).
* a customisable 'salt' can be applied to the contents so no two Corona apps produce the same hash for the same inventory contents.  (Empty inventories are saved without a hash, to make it more difficult to reverse engineer the salt.)
* product names can be refactored (renamed) in the save file to disguise their true function
* quantities / values can also be disguised / obfuscated
* fake items can be added to the inventory, whose values change randomly with each save, to help disguise the function of other quantities being saved at the same time.
* IAP badger can generate a Amazon test JSON file for you, to help with testing on Amazon hardware


### How to use:


#### Example 1: remove advertisements from an app

In this simple example, we will look at a program that has a single product: an item that indicates the user has paid to remove advertisements from an app.

#####Including the library
To use the library, start with the following code:

```lua

--Load and create the IAP Badger object.
--In this example, it is created as a global object available from anywhere within the program.
iap = require("iap_badger")

```

Note that if you are connecting to Google Play, you will need to set up your **build.settings** to include the Google IAP v3 plugin.

```lua

    plugins =
    {
        --Google in app billing v3
        ["plugin.google.iap.v3"] =
        {
            -- required
            publisherId = "com.coronalabs",
            supportedPlatforms = { android = true },
        },  
	}

```

#####Setting up the catalogue

IAP Badger essentially handles two separate tasks: handling calls to and from the app stores, and managing an inventory of items that have been purchased.  So in order to function, you need to provide a catalogue that conveys these two types of information.  An empty catalogue would look like this:

```lua

local catalogue = {
	--An empty product table
	products = {},
	--An empty inventory items table
	inventoryItems = {}
}
```

Let's add our single product to the products table: an IAP product to remove banner advertisements from the app.

```lua

local catalogue = {

	--Information about the product on the app stores
	products = {
	
		--removeAds is the product identifier.
		--Always use this identifier to talk to IAP Badger about the purchase.
		removeAds = {
			
			--A list of product names or identifiers specific to apple's App Store or Google Play.
			productNames = { apple="remove_ads", google="REMOVE_BANNER",
				amazon="BANNERremoval" },
			
			--The product type
			productType = "non-consumable",
			
			--This function is called when a purchase is complete.
			onPurchase=function() iap.setInventoryValue("unlock", true) end,
			
			--The function is called when a refund is made
			onRefund=function() iap.removeFromInventory("unlock", true) end,

		}
	},
	
	--An empty inventory items table
	inventoryItems = {}
}
```

In this example, we create a product called *removeAds*.  In the future, whenever our code talks to IAP Badger, we will refer to the product as *removeAds*, regardless of what you have named the product in iTunes Connect or Google Play Developer Console.

The first item in *removeAds* is the *productNames* table.  This contains a list of product identifiers that correspond to how your removeAds product has been set in iTunes Connect, Google Play, Amazon etc.  This table allows your product to have different names in different app stores.  In the example above, our *remove_ads* product has been given the identifier *remove_ads* by one programmer in iTunes Connect, but another has given it the name *REMOVE_BANNER* in Google Play.  When you tell IAP Badger that you want to purchase *removeAds*, it will automatically work out what the correct identifier is depending on which store you are connecting to.

*(Note that setting up products on Google Play, Amazon, iTunes Connect et al is beyond the scope of this tutorial).*

The *product_type* value can be one of two values: **consumable** or **non-consummable**.  **consumable** items are like gold coins in a game that can be purchased and then spent, or used up.  The user can purchase and re-purchase consumable items to their hearts content.  **non-consummable** items can only be purchased once, and can be restored by the user if they ever delete and re-install the app, or purchase a new device.  The *removeAds* product is non-consummable,.

There now follow two functions.  These functions should work silently, only making changes to the inventory (we'll deal with telling the user about successful purchases later).

 - onPurchase: this function is called following a successful purchase.  In the example above, an item called "unlock" with the value "true" is added to the inventory.
 - onRefund: this function is called following a refund.  In the above, the "unlock" item is removed from the inventory (the *true* value indicates that the item should be completely removed from the inventory, rather than having its quantity set to zero).

Now let's add a simple inventory item to the catalogue.  The inventory items table tells IAP Badger how the items should be handled in the inventory when they are manipulated, or a load/save operation is carried out.

```lua

local catalogue = {
	--Information about the product on the app stores
	products = {	
	
		--removeAds is the product identifier.
		--Always use this identifier to talk to IAP Badger about the purchase.
		removeAds = {
			
			--A list of product names or identifiers specific to apple's App Store or Google Play.
			productNames = { apple="remove_ads", google="REMOVE_BANNER" },
			
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
		unlock = { productType="non-consumable" }
	}

```

And that's the catalogue set up.

#####Initialise IAP Badger

The next thing to do is initialise IAP Badger.  This can be done with:

```lua

local iapOptions = {
	--The catalogue generated above
    catalogue=catalogue,
    --The filename in which to save the inventory
    filename="goodies.txt",
    --Salt for the hashing algorithm
    salt = "something tr1cky to gue55!",
}
--Initialise IAP
iap.init(iapOptions)
```

When IAP Badger saves the inventory, it prepends a hash to secure the contents.  If the user attempts to alter the contents of the file, IAP Badger will detect the change and refuse to load the table.  Enter a value known only to you in **salt** to make the hash difficult to crack by malicious users - it can be anything, a string concatenated to random number and the device UDID, whatever you like.  Be aware that once you have chosen the salt and gone into production, however, the salt should not be changed.

#####Making a purchase

The following code will handle the purchase of our remove banner item:

```lua

--The callback function
--IAP will call purchaseListener with the name of the product
local function purchaseListener(product)

	--Check the product name...
	--(not really necessary with a one-product catalogue...)
	if (product=="removeAds") then
		--Remove the ads
		removeAds()
		--Tell the user the ads have been removed
		native.showAlert("Purchase complete", "The ads have now been removed.", {"Okay"})
	end
	
end

--Make the purchase
iap.purchase("removeAds", purchaseListener)


```

The *iap.purchase* function calls IAP Badger with the name of the product to buy - remember, this will be its identifier in the product catalogue, **not** the identifier used on iTunes Connect or Google Play.  It also supplies the name of the function to call if the purchase is successful.

**Why two callback functions?** You may have noticed there are two callback functions: one within the catalogue, and one named explicitly from the *iap.purchase* function.

* The function identified within the product catalogue should work silently, handling inventory changes - this is partially because it can be called during a product restore cycle, as well as during a purchase.
* The function identified in the *iap.purchase* function can be as noisy as you like, sending all sorts of messages to the user, playing congratulatory sounds and making screen changes.  

Remember: product catalogue callbacks make silent inventory changes - that's all.

#####Product restores

The product restore cycle works in a very similar way.  There is only one slight difference - in your callback function, IAP Badger will let you know whether this is the first item that has been restored.

```lua

--If this function is called, the app store never replied to the request
--for a restore (which probably means there were no products to restore)
local function restoreTimeout()
    
    --Hide the spinner
    spinner.hide()
    
    --Tell user something went wrong
    alert("Restore failed", "No response from App Store", {"Okay"})
    
end

--This function is called on a successful restore.
--If event.firstRestoreCallback is set to true, then this is the first time the function
--has been called.
local function restoreListener(productName, event)
    
    --If this is the first transaction...
    if (event.firstRestoreCallback) then         
        --Hide the spinner
        spinner.hide()    
        --Tell user purchases have been restored
        native.showAlert("Restore", "Your items are being restored", {"Okay"})
    end
    
    --Remove ads
    if (productName=="removeAds") then removeAds() end
    
end

--Put a progress spinner on screen to let the user know the program is communicating with the app store.
spinner.show()
--Restore purchases
iap.restore(false, restoreListener, restoreTimeout)

```


*iap.restore* requires three parameters.  The first is a boolean to indicate whether non-consumable items should be completely removed from the inventory before the restore is made (normally not necessary - but this can be useful for debugging).  The second is the restore callback when a successful restore has been made.  The third is a timeout callback.

The restore callback should check the contents of event.firstRestoreCallback - this will be set to true if this is the first item to be restored.  If it is the case, the callback function should remove any progress spinners and tell the user their products are being restored.  For apps with many products, the callback function may be called a number of times, so this kind of 'noisy' action should only be carried out once.  The app store never tells IAP Badger how many products are due to be restored, and whether this is the last product to be restored, so this approach lets the user know that a restore is going to be successful.

The timeout callback is necessary because there is no guarantee that the app store will ever reply to a restore request (in fact, if the user has never bought a product for this app, it never will).  The timeout function is called after a given duration to tell your app that nothing is forthcoming, and you should tell the user that the restore failed.

So in summary:

* in your restore function, tell the user their products are being restored when event.firstRestoreCallback is set to true and remove any progress spinners from the screen.
* in your timeout function, let them know the restore failed.

#####Saving and loading

IAP Badger will automatically load the inventory when the *init* function is called.

To save the inventory, call the following when your app is suspended or quits:

```lua
--Save inventory
iap.saveInventory()

```



**And that's it.**

By providing IAP Badger with the catalogue, a purchase callback and two restore callbacks, the library will handle all API calls to Apple, Amazon and Google Play.  It will handle loading and saving inventories, initialising the app stores and varying product identifiers automatically.

###Testing and debugging on the simulator

Once you have your catalogue set up, testing on the simulator (or a device) is easy.  To debug the example above on the simulator, add two lines to the options passed to iap.init:

```lua

local iapOptions = {
	--The catalogue generated above
    catalogue=catalogue,
    --The filename in which to save the inventory
    filename="goodies.txt",
    --Salt for the hashing algorithm
    salt = "something tr1cky to gue55!",

	--***New stuff below
	
	--Debugging mode
	debugMode = true
	--If on the simulator, pretend to be the following store:
	debugStore = "apple"
}

--Initialise IAP
iap.init(iapOptions)
```

You can now debug your in app purchases on the simulator.  When the iap.purchase or iap.restore functions are called, you will receive an alert box asking you how you would the app store to respond (eg. successful purchase, cancelled by user, failed transaction).  Your callback functions will receive exactly the same information they will receive in the live environment, so you can test and step through code to make sure it works correctly.

The debug mode can also be set to work on a real device.  If IAP Badger detects it is being run on a device, you will receive a warning when the library is initialised.  This is to make sure you don't accidentally send this version of the code to the app store.


There is more, but I have tired fingers now...

