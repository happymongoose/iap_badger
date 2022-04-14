## Purpose:

Although Solar2D offers an IAP API that is quite similar across the app stores, there are differences depending on whether you are connecting to Apple's App Store, Google Play or through Amazon.  This can result in spaghetti code that is difficult to maintain.

The main benefit of using IAP Badger is you can forget all that.  You write one, simple piece of code that functions across all the app stores.

In terms of program flow and event handling, IAP Badger makes all of the stores appear to follow Apple's purchase and restore model.  For instance, it will automatically handle the consumption of consumable products on Google Play.


### Example 1 - quickstart

IAP Badger provides two core elements:

* IAP handling
* an inventory facility for recording those purchases

In this quickstart example, we will only concern ourselves with IAP handling (ie. the process of handling an in-app purchase once the user presses a 'buy' button or something similar in our app).  The code will correctly process an IAP purchase across iOS, Google Play and Amazon, despite the fact they have been given different identifiers in each console.

Begin by passing IAP Badger a product catalogue table - a description of each of the in-app products available, and their associated identifiers on iTunes Connect, Google Play Console and Amazon's console.  IAP Badger automatically works out the correct product ID for the user's device at runtime.

For simplicity, in the catalogue, these are all grouped together into one over-arching name - "removeAds".  In IAP Badger, when referring to an in-app product, your code should **always use the catalogue name** (in this case, "removeAds").

Likewise, IAP Badger will always provide information about an IAP using its catalogue name, regardless of what device the app is running on.

**The only time you ever use the product ID from a specific app store is in the productNames table for your IAP.**

Finally, call iap.purchase() and IAP Badger will take care of the rest.



```lua


--Example1.lua
--
--Simplest possible example of using IAP Badger to purchase an IAP.

--Load IAP Badger
local iap = require("iap_badger")

--Create the catalogue
local catalogue = {

    --Information about the product on the app stores
    products = {     
        --removeAds is the product identifier.
        removeAds = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.
                productNames = {
                	apple="full product ID as entered in iTunes Connect",
                	google="full product ID as entered in Google Play console",
                	amazon="full product ID as entered into Amazon's console"
                },
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


iap.purchase("removeAds", purchaseListener)

```

In the above example, IAP Badger does not make a record of the purchase on the user's device (this is the purpose of the inventory management system).

For those that want to handle inventory management themselves, note the above code does not need to:

* include an **inventory** table in the product catalogue
* include **onPurchase** or **onRefund** functions for the items in its product catalogue
* a **filename** or **salt** to the init function.

The following sections now go into more detail about how to set up your catalogue and use IAP Badger's inventory system for recording purchase information.


### How to use: non-consumable items


#### Example 2: remove advertisements from an app

[Download the code for example 2.](iapdocs/example%202.zip)

In this simple example, we will look at a program that has a single product: an item that indicates the user has paid to remove advertisements from an app.


#####Setting up the catalogue

IAP Badger essentially handles two separate tasks: handling calls to and from the app stores, and managing an inventory of items that have been purchased.  So in order to function, you need to provide a catalogue that conveys these two types of information.  An empty catalogue would look like this:

```lua

local catalogue = {
	--An empty product table
	products = {}
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
	}

}
```

In this example, we create a product called *removeAds*.  In the future, whenever our code talks to IAP Badger, we will refer to the product as *removeAds*, regardless of what we've named the product in iTunes Connect or Google Play Developer Console.

The first item in *removeAds* is the *productNames* table.  This contains a list of product identifiers that correspond to how your removeAds product has been set in iTunes Connect, Google Play, Amazon etc.  This table allows your product to have different names in different app stores.  In the example above, our *remove_ads* product has been given the identifier *remove_ads* in iTunes Connect, but has the name *REMOVE_BANNER* in Google Play.  When you tell IAP Badger that you want to purchase *removeAds*, it will automatically work out the correct identifier based on the user's device.

*(Note that setting up products on Google Play, Amazon, iTunes Connect et al is beyond the scope of this tutorial).*

However, tutorials about setting up in-app products in the developer consoles can be found here:

* iOS: [IAP configuration guide](https://help.apple.com/itunes-connect/developer/#/devb57be10e7)
* Google Play: [administering IAP](https://developer.android.com/google/play/billing/billing_admin.html), [testing in-app purchases](https://developer.android.com/google/play/billing/billing_testing.html)
* Amazon: [creating new in-app purchases](https://developer.amazon.com/public/apis/earn/in-app-purchasing/docs-v2/submitting-iap-items), [testing in-app purchases](https://developer.amazon.com/public/apis/earn/in-app-purchasing/docs-v2/testing-iap)

(Read them, read them again, then read them another 15 times.  Seriously.  You'll need to follow every single step, super-meticulously, to get IAP to work.)

The *product_type* value can be one of two values: **consumable** or **non-consummable**.  **consumable** items are like gold coins in a game that can be purchased and then spent, or used up.  The user can purchase and re-purchase consumable items to their hearts content.  **non-consummable** items can only be purchased once, and can be restored by the user if they ever delete and re-install the app, or purchase a new device.  The *removeAds* product is non-consummable.

* On Google Play, there are only two types of product: managed products and subscriptions.  You should choose the managed product type.  IAP Badger will implement consumable and non-consumable functionality for you.

There now follow two functions.  Their purpose is to make a permanent record of a user purchase (or refund).  In this example, we're going to use IAP Badger's build in inventory system to record that the user has bought the 'removeAds' product.  If you were going to implement your own save file, this is where you would write out that information to the user's device.

The purchase and refund functions in the product catalogue should work silently - that is, they don't send any on-screen messages to the user.  Their sole purpose is to handle background changes related to the saving/updating of purchase information (we'll deal with telling the user about successful purchases later).  

 - onPurchase: this function is called following a successful purchase.  In the example above, an item called "unlock" with the value "true" is added to the inventory.
 - onRefund: this function is called following a refund.  In the above, the "unlock" item is removed from the inventory (the *true* value indicates that the item should be completely removed from the inventory).

Let's add a simple inventory item to the catalogue.  The inventory items simply tell IAP Badger a little about how the items should be handled in the inventory.

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

When IAP Badger saves the inventory, it prepends a hash to secure the contents.  If the user attempts to alter the contents of the file, IAP Badger will detect the change and refuse to load the table.  Enter a value known only to you in **salt** to make the hash difficult to crack by malicious users - it can be anything, a string concatenated to random number and the device UDID, whatever you like.  Be aware that once you have chosen the salt and gone into production, however, the salt cannot be easily changed.

If you're going to use your own code to make a record of purchases (rather than IAP Badger's inventory system), you can leave out the filename and salt entries.


#####Making a purchase

The following code will handle the purchase of our remove banner item:

```lua

--The callback function
--IAP will call purchaseListener with the name of the product
--Transaction is a table containing the original transaction information table passed by Solar2D
local function purchaseListener(product, transaction)

	--Check the product name...
	--(not really necessary with a one-product catalogue...)
	if (product=="removeAds") then
		--Remove the ads
		removeAds()
		--Save the inventory
		iap_badger.saveInventory()
		--Tell the user the ads have been removed
		native.showAlert("Purchase complete", "The ads have now been removed.", {"Okay"})
	end

end

--Make the purchase
iap.purchase("removeAds", purchaseListener)


```

The *iap.purchase* function calls IAP Badger with the name of the product to buy - remember, this will be its identifier in the product catalogue, **not** the identifier used on iTunes Connect or Google Play.  It also supplies the name of the function to call if the purchase is successful.

**Why two callback functions?** You may have noticed there are two callback functions: one within the catalogue, and one named explicitly from the *iap.purchase* function.

Here are the rules for making everything play nicely:

* The function identified within the product catalogue should work silently, handling inventory changes.
* The function identified in the *iap.purchase* function can be as noisy as you like, sending all sorts of messages to the user, playing congratulatory sounds and making screen changes.  

So - why?

The listener function in your catalogue will get called after a purchase is made **AND** during the restore cycle (more on that next).  During a restore cycle, the app store could send you a bundle of products to restore, one immediately after the other.  So, if every listener in your catalogue says "Thank you" to the user, that means that when the user initiates a restore, they could receive 3,4,5... messages, one after another, all saying thank you for your purchase.

Additionally, on iOS, you can also purchase more than one product at a time - if you permitted this, you would also end up sending the user multiple "Thank you" messages.  Which is very polite, but it also looks like your code is broken.

Remember: keep product catalogue callbacks for silent inventory changes.

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

The restore callback should check the contents of event.firstRestoreCallback - this will be set to true if this is the first item to be restored.  If it is the case, the callback function should remove any progress spinners and tell the user their products are being restored.  For apps with many products, the callback function may be called a number of times, so this kind of 'noisy' action should only be carried out once.  The app store never tells IAP Badger how many products are due to be restored, and whether this is the last product to be restored, so this approach lets the user now that a restore is in operation.

The timeout callback is necessary because there is no guarantee that the app store will ever reply to a restore request (in fact, if the user has never bought a product for this app, it never will).  The timeout function is called after a given duration to tell your app that nothing is forthcoming, and you should tell the user the restore failed.

So in summary:

* in your restore function, tell the user their products are being restored when event.firstRestoreCallback is set to true and remove any progress spinners from the screen.
* in your timeout function, let them know the restore failed.


#####Saving and loading

IAP Badger will automatically load the inventory when the *init* function is called.

To save the inventory, call:

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

You can now debug your in app purchases on the simulator.  When the iap.purchase or iap.restore functions are called, you will receive an alert box asking you how you would the app store to respond (eg. successful purchase, cancelled by user, failed transaction).  Your callback functions will receive exactly the same information they will receive in the live environment, so you can test and step through code to make sure it works correctly.  If you choose to restore products in debug mode, then IAP Badger will attempt to restore every non-consumable product in the catalogue.

The debug mode can also be set to work on a real device.  If IAP Badger detects it is being run on a device, you will receive a warning when the library is initialised.  This is to make sure you don't accidentally send this version of the code to the app store.

Be aware that some of Solar2D's IAP functions are asynchronous - that means that they return immediately, even though they haven't finished yet.  A good example of this is the loadProducts function, which requests a list of prices and descriptions for your in-app products in the user's local language and currency from the app store.  The information from the app store doesn't arrive instantaneously - it may take several seconds to be transmitted across the network.

To help you test and develop robust apps, IAP Badger will simulate many of these delays when you are on the simulator (or running in debug mode).

There is an additional function that can be useful to track down errors - verbose debug output.  When this is turned on, IAP Badger will send a metric tonne of information to the console about what is happening and where.  Here's an example of turning on verbose debug output:

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
	debugStore = "apple",

	--Turn on verbose debug output
	verboseDebugOutput=true

}

--Initialise IAP
iap.init(iapOptions)
```

You do not need to be in debug mode to use verbose debug output.


####Debug mode vs production / release mode

In debug mode, IAP Badger never contacts a real store for information or to initiate a purchase; this is true for both the simulator and the device.  Instead, it creates a set of faked messages and events so you can check everything in your app works without the complication of checking for errors in how your products are set up in iTunes Connect, Google Play Console etc.

Once debug mode is functioning correctly, it is time to put IAP Badger in standard mode and check your IAP's on a real device.  You do this by commenting out any reference to **debugMode** in the iapOptions table you pass to **iap.init**.

In release mode, IAP Badger does start connecting to real stores and making real purchases/restores etc.  At this point, it will become apparent if there are any problems with the way your products are set up in iTunes Connect, Google Play or Amazon.  In release mode, IAP Badger will not print out any error messages to the console.  Instead, if your code is not working, you will need to check for any error messages from Solar2D's store code by looking in your device's error log (ie. through xCode for iOS or using **adb logcat** for Android).  It is worth remembering that changes you make to Apple, Amazon's and Google's console can take several hours to percolate around the world.

Note: if you code is working on a device in debug mode, but fails in release mode, it is most likely the problem is with how your products are set up in Apple, Amazon's or Google's console.

A suggested workflow would be:

1.  Check code is working on the simulator in debug mode (debugMode=true)
2.  Check code is working on the device in debug mode (debugMode=true)
3.  Check code is working on the device in release mode (debugMode=nil)


####Releasing your app

Once everything is working, make sure you comment out / remove any reference to **debugMode**, **debugStore** and **doNotLoadInventory** in the iapOptions table your pass to **iap.init**.


### How to use: consumable items

####Example 3: Purchasing coins (as in game currency)

[Download the code for example 3.](iapdocs/example%203.zip)

The example code given above shows how to handle non-consumable items in the player inventory (ie. the user has purchased them, or they haven't.) Non-consumable items don't really have a quantity as such - they are present or absent.

The following section looks at how to implement consumable items, such as packs of coins that can be spent on in game items.  Once the user has spent all of their coins, they have run out.  Consumable items cannot be restored from the App Store; if the user wants another pack of coins to use in the game, they will need to make another purchase.  For fully implemented code, look at main.lua in the code download.

The code for handling consumable items is very similar to non-consumable items.  Here's how to set up a consumable item in the product catalogue.



```lua
    local catalogue = {

    	products= {

    		buy50coins = {

    			--Specify product identifiers on the App Store.
    			productNames = { apple="buy50coins", google="50_coins",
    				amazon="COINSx50" },

			    --Product type
			    productType="consumable",

    			--Listener for when a purchase is made (silent function)
    			onPurchase = function()
    				iap.addToInventory("coins", 50)
    			end,

    			--Listener for when a refund is made (silent function)
    			onRefund = function()
	    			iap.removeFromInventory("coins", 50)
	    		end,

    		}
    	}

    }
```

The key differences in the product catalogue are:

 - The product type is identified as "consumable".
 - In the purchase listener, the iap.addToInventory function specifies a quantity to add (ie. 50 coins).
 - In the refund listener, the iap.removeFromInventory function also specifies a quantity to remove.

Now let's add the inventory item.

```lua

    local catalogue = {

	    inventoryItems = {

			--Create an item to hold the current number of coins being held by the player.
			coins = {
				productType="consumable"
			}

	    },

    	products= {

    		buy50coins = {

    			--Specify product identifiers on the App Store.
    			productNames = { apple="buy50coins", google="50_coins",
    				amazon="COINSx50" },

			    --Product type
			    productType="consumable",

    			--Listener for when a purchase is made (silent function)
    			onPurchase = function()
    				iap.addToInventory("coins", 50)
    			end,

    			--Listener for when a refund is made (silent function)
    			onRefund = function()
	    			iap.removeFromInventory("coins", 50)
	    		end,

    		}
    	}

    }


```

And that's it.

#####Initialising a purchase

The rest of the code for handling purchases is the same as for non-consumable products - you simply call iap.purchase() with a listener function that gets called when the process is complete.

```lua

--The callback function
--IAP will call purchaseListener with the name of the product
local function purchaseListener(product)

	--Check the product name...
	--(not really necessary with a one-product catalogue...)
	if (product=="buy50coins") then
		--Update the coin counter text to show how many coins the user is carrying.
		coinText.text = iap.getInventoryValue("coins") .. " coins"
		--Save the inventory
		iap_badger.saveInventory()
		--Tell the user the ads have been removed
		native.showAlert("Purchase complete", "You now have 50 more coins.", {"Okay"})
	end

end

--Make the purchase
iap.purchase("buy50coins", purchaseListener)


```

In the above example, a text label is updated to show the new quantity of coins the player is now holding.  iap.getInventoryValue("coins") returns the current number of coins the user is carrying - the inventory will be updated before the 'noisy' purchase listener function is called.

#####Restoring

By default, consumable items cannot be restored from the App Store.  If IAP Badger detects a request to restore a consumable item, this is presumably suspect and will be ignored.

This may not be desirable in certain circumstances: for example, redeeming a promo code in Google Play (your app may get told to add the consumable during the restore cycle).

To override the default behaviour of ignoring restores for individual consumable products, add an **allowRestore** flag to your product in the product catalogue.

For example:

```

local catalogue = {

    --Information about the product on the app stores
    products = {     
        --promoCoins is the product identifier.
        promoCoins = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.
                productNames = {
                	google="uk.co.happymongoose.promocoins",
                },
                --The product type
                productType = "consumable"
                --Allow this consumable to be restored - I want to use it for a promo code
                allowRestore=true
        }
    }
}

```

Including **allowRestore** with non-promo products could be a terrible idea... use carefully.  Also be aware that, in debug/testing mode, this product will now be included as part of any call to iap.restore().


##### Saving and loading

As for consumable items, IAP Badger will automatically handle the inventory management when iap.saveInventory() is called.  

#####Changing quantities during the game

The functions iap.addToInventory and iap.removeFromInventory can be called at any time to increase or decrease quantities of an item.  Additionally, iap.setInventoryValue("product", value) can be called to set the quantity of an item to a specific value.

For example, during the game, the user may want to spend their coins on purchasing an extra life.  To take account of this spending, make a call to iap.removeFromInventory, specifying how many coins have been spent.

For example:

```Lua

local function purchaseExtraLives()

	--Give the player an extra life
	lives = lives + 1

	--Deduct 10 coins from the player's wallet
	iap.removeFromInventory("coins", 50)

end

```

#####Additional product packs

It may be the case that you have different size coin packs available for purchase for your app - for example, the user could purchase a 50 coins or 100 coins.  To implement this, just add an additional product to the product catalogue.

```Lua

    local catalogue = {

	    inventoryItems = {

			--Create an item to hold the current number of coins being held by the player.
			coins = {
				productType="consumable"
			}

	    },

    	products= {

	    	--The 50 coin pack
    		buy50coins = {

    			--Specify product identifiers on the App Store.
    			productNames = { apple="buy50coins", google="50_coins",
    				amazon="COINSx50" },

			    --Product type
			    productType="consumable",

    			--Listener for when a purchase is made (silent function)
    			onPurchase = function()
    				iap.addToInventory("coins", 50)
    			end,

    			--Listener for when a refund is made (silent function)
    			onRefund = function()
	    			iap.removeFromInventory("coins", 50)
	    		end,

    		},

	    	--The 100 coin pack
    		buy100coins = {

    			--Specify product identifiers on the App Store.
    			productNames = { apple="buy100coins", google="100_coins",
    				amazon="COINSx100" },

			    --Product type
			    productType="consumable",

    			--Listener for when a purchase is made (silent function)
    			onPurchase = function()
    				iap.addToInventory("coins", 100)
    			end,

    			--Listener for when a refund is made (silent function)
    			onRefund = function()
	    			iap.removeFromInventory("coins", 100)
	    		end,

    		}
    	}

    }

```


###App Store information

####Getting product price information

IAP Badger can contact the appropriate App Store and request product pricing information in the user's local currency.  This requires two calls: one to request that IAP Badger downloads a copy of the product catalogue from the App Store, and another to give your code a copy of it.

Initially, make a call to **iap.loadProducts()** to download the product catalogue.  It is advisable to do this as early as possible, just after calling **iap.init()**, as there is a delay between making the call and receiving the product information.   Currently, pricing information can only be requested on the Apple App Store and through Google Play.  If a request is made to iap.loadProducts on a store that does not support pricing requests (such as Amazon), it will be ignored.

Once the pricing information has been received, you can then ask IAP Badger to give you a copy in table form.  This table be queried to find the price of an item in the user's local currency.  The following example retrieves the price for a 50 coin and 100 coin pack for the consumable items discussed above.

```Lua

--Request a copy of the loadProducts catalogue (delivered from the appropriate App Store)
local lpCatalogue = iap.getLoadProductsCatalogue()

--Get the localized price for 50 coins and 100 coins.
--Use the identifier specified in your product catalogue.
local priceFor50Coins = lpCatalogue.buy50coins.localizedPrice
local priceFor100Coins = lpCatalogue.buy100coins.localizedPrice

```

As with all of the other functions in IAP Badger, you should query the table returned by iap.getLoadProductsCatalogue using product identifier specified in your product catalogue (*buy50coins*), **not** the identifier for the item in the App Store (not *buy50coins* or *50_coins*).  Useful information returned for the item in the product catalogue is:

**title** The product's title.

**description** The product's description.

**localizedPrice** The product's price in the user's local currency.



You can also set up debug price information in the product catalogue.  IAP Badger will use these to create a simulated product catalogue following a call to loadProducts on the simulator or in debug mode (this gives you some sample text to play with during the development process).

```Lua

local catalogue = {

	inventoryItems = {
		--Inventory items go here...
	},

	products = {

	    	--The 100 coin pack
    		buy100coins = {

    			--Specify product identifiers on the App Store.
    			productNames = { apple="buy100coins", google="100_coins",
    				amazon="COINSx100" },

			    --Product type
			    productType="consumable",

			    --Simulator information for product pricing
				simulatorPrice = "£0.79",
				simulatorDescription = "A pack of 100 shiny gold coins.",
				simulatorTitle = "100 coins",

    			--Listener for when a purchase is made (silent function)
    			onPurchase = function()
    				iap.addToInventory("coins", 100)
    			end,

    			--Listener for when a refund is made (silent function)
    			onRefund = function()
	    			iap.removeFromInventory("coins", 100)
	    		end,
		   }
	}


}


```

This can be useful during early development when you are working on the Solar2D simulator.

Note: when working in debug mode or on the simulator, IAP Badger will fake a delay between calling iap.loadProducts and returning a product catalogue, to simulate the delay your app will experience on a real device.

Here is some example code for loading the product catalogue and printing a copy of it to the console:

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


###Security

The default security included with IAP Badger is intended to make it difficult for someone with a rooted device to open your application folder and amend the settings files to gain free access to in-app purchases.  If you include the device UDID as part of the salt in your catalogue, it will also mean a user cannot easily copy settings files from one rooted device to another.  IAP Badger can improve this level of security by refactoring (renaming) the identifiers and quantities held within the inventory, so as to disguise their true meaning.

There are several reasons why an obfuscation, rather than a encryption, approach has been adopted:

- The use of encryption in the USA and France involves registering for additional certificates from the authorities; the number of countries this is applicable to is only going to increase.
- The use of encryption does not protect your application's data from someone who is intent on hacking your code.  In fact, it gives you a false sense of security that your app is safe.
- The approach taken should be enough to deter most casual users from hacking your IAP's - the additional time spent investing in developing over-secure systems to deter a handful of hackers could be better spent building new apps for the world to enjoy.
- IAP purchases are also subject to insecurities in DNS and server re-routing, which are outside the capabilities of the app to detect.

For those who wish to add encryption to their data files, just include the standard Solar2D openssl library at the top of the IAP Badger source code, and add encryption / decryption to the saveTable and loadTable routines.

####Refactoring (renaming)

IAP Badger can accept a refactoring table that is used to disguise the name and quantity of each item in the inventory.  Once the refactoring table has been passed, the calling program only needs to worry about the real names and quantities for each item.

#####Refactoring simple boolean values

Let's go back to our very first example: a program to indicate whether the user has paid to remove advertisements from an app.  In the product catalogue, the saved inventory was described by the following table:

```Lua
	--Information about how to handle the inventory item
	inventoryItems = {
		unlock = { productType="non-consumable" }
	}
```

IAP Badged saves the inventory file as JSON on the user's device.  The (abbreviated) output from the inventory file for the unlock item would look something like this:

```JSON
"unlock":{"value":true}
```

If a user were to root / jailbreak their device, and look at that file, it would be clear what the purpose of the contents were.  By adding some refactor information, we can alter how that information is saved to the file to disguise its true purpose.  For instance, it is a lot harder for the casual user to work out that the following obfuscated line has exactly the same purpose - to remove advertisements from the app.

```JSON
"lastUserTxRefreshTimer":{"ms":628}
```

We can get IAP Badger to disguise the true nature of quantities in the save file by providing a **refactor table**.  Once this has been done, IAP Badger will automatically handle all the refactoring of fields and quantities for us - our code only has to address the real field names and values used in the inventory.

The refactor table tells IAP Badger exactly how to obfuscate the items and quantities for the items in the inventory.  (Incidentally, not every item in the inventory has to have an entry in the refactor table.)

Here is an example for the above unlock property.

```Lua
local refactorTable = {

	--Table for the inventory item 'unlock'
	{
		--The name of the inventory item
		name="unlock",
		--The name to save/load the item in the inventory data file
		refactoredName="lastUserTxRefreshTimer",

		--The properties table explains how to save the value associated with this inventory item.

		properties = {

			--There is only one item in the property table at the moment: "value"
			{		
				--Do not change!  This line must always be present.
				name="value",
				--The name to use in the save file
				refactoredName="ms",

				--The function used to hide the property's true value
				refactorFunction=function(value)
					if (value==true) then return math.random(1,1000) else return math.random(1001, 2000) end
				end,

				--The function retrieve's the property's true value
				defactorFunction=function(value)
					if (value>=1) and (value<=1000) then return true else return false end
				end
			} --End of property 'value'

		} --End of properties table

	} --End of item 'unlock'

} --End of refactor table

```

The above refactor table specifies that the property 'unlock' should be saved as 'lastUserTxRefreshTimer' in the save file.  The value associated with it in the save file will be stored as "ms".

The purpose of the refactorFunction is to convert the boolean value ('true') into something less obvious to the casual user.  The function returns a random value from 1-1000 when 'true' is passed; if 'false' is passed, it returns a random value from 1001-2000.  Because the function returns a range of values for true and false, it is more difficult for the casual user to work out their function by comparing the data files of two rooted devices.

The defactorFunction (if defactor is a word!?) is to reverse the above.  So any value passed between 1-1000 is returned as true; anything else is returned as false.

(Note 1: the line **name="value"** must appear for each refactored item in the properties table.  Its use is reserved for future versions of IAP Badger, which may include the ability to record subscription dates or other information.)

Once the refactor table has been defined, it is passed as an option to iap.init():

```Lua
local iapOptions = {
	--The catalogue for this app (defined previously)
	catalogue=catalogue,
	--Filename to save the inventory under
	filename="inventory.txt",
	--Salt
	salt = "someSalt" . system.getInfo("deviceID"),
	--Refactor table
	refactorTable = refactorTable
}

--Initialise IAP badger
iap.init(iapOptions)

--IAP badger will now handle all the refactoring / defactoring automatically...

```

#####Refactoring more complex values

Refactoring boolean values is simple enough, but how about a more complex value like an integer that represents how many coins have been purchased?

In the inventory file, the original JSON might look like this:

```JSON
"coins":{"value":250}
```

Let's convert it into something less obvious, like this:

```JSON
"reload_zHash":{"frame":-17750}
```

Here, the item 'coins' has been renamed to the relatively obscure 'reload_zHash', 'value converted to 'frame' and the quantity disguised by multiplying it by -71.

The refactor table required would like this:

```Lua
local refactorTable = {

    --Table for the inventory item 'coins'
    {
        --The name of the inventory item
        name="coins",
        --The name to save/load the item in the inventory data file
        refactoredName="reload_zHash",

        --The properties table explains how to save the value associated with this inventory item.

        properties = {  

			--There is only one item in the property table at the moment: "value"
            {
                --Do not change!  This line must always be present.
                name="value",
                --The name to use in the save file
                refactoredName="frame",

                --The function used to hide the property's true value
                refactorFunction=function(value)
                    return value*-71
                end,

                --The function retrieve's the property's true value
                defactorFunction=function(value)
                    return value/-71
                end

            } --End of property "value"

        } --End of properties table

    } --End of inventory item

} --End of refactor table

```

This is obviously a simple example of how the number of coins could be disguised.  A more realistic example would involve several steps of arithmetic in the refactor function, and the reverse/opposite steps in the defactor function.

Again, IAP Badger will automatically carry out the refactoring of the item and value on each save and load.  The calling code only has to query to real names and quantities for each item.

####Fake inventory file items

If all that appears in the inventory item is one line indicating the number of coins the user has purchased, even with obfuscation, the purpose of the value can become obvious.  IAP Badger also provides functions to include random, fake inventory items that are added to the file, and whose values are randomised with each save.

Again, this helps disguise the true nature of each value and quantity.  These fake inventory items are described in the main catalogue, and can be of the type "random-integer", "random-decimal" and "random-hex".  Here is an example of a catalogue with one real 'unlock' item, and three fake items listed along with it:

```Lua
local catalogue = {

	inventoryItems = {
		--A standard, non-consumable unlock item as describe previously
		unlock = { productType="non-consumable" },

		--Some fake products to save along with it
		pixelGammaAdjust = {
			productType="random-integer",
			randomLow=1,
			randomHigh=50,
		},
		timeGammaAdjust = {
			productType="random-decimal",
			randomLow=1,
			randomHigh=10,
		}
		fakeHash = {
			productType="random-hex",
			randomLow=10000,
			randomHigh=20000
		}
	},

	products = {...}
}


```

In the above examples, pixelGammaAdjust is a random integer between 1 and 50, whose value is changed every time the inventory file is saved.  timeGammaAdjust is a random decimal number between 1 and 10, and fakeHash is a random hexadecimal value between 10000 and 20000 (specified here as decimals).

Fake items are not automatically added to the user's inventory.  This gives you the capacity to add and remove fake inventory items as your app progresses.  They are added like any other inventory items, using the **iap.addToInventory** function.

So, using a single example from the above catalogue, you would call **iap.addToInventory("fakeHash")** to add the **fakeHash** item to the user's inventory.

A good time to add fake items is when your app is run for the first time, or if your code detects the user's inventory is completely empty.

IAP Badger will automatically randomise the values for fake items each time the inventory is saved.

Randomised items in the inventory can be included in the refactor table if you so choose: however, any functions you specify to refactor and defactor the values associated with them will be ignored.
