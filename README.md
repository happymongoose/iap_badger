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


### How to use: non-consumable items


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

IAP Badger essentially handles two separate tasks: handling calls to and from the app stores, and managing an inventory of items that have been purchased.  So in order to function, you need to provide a catalogue that conveys all these two types of information.  An empty catalogue would look like this:

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

The first item in *removeAds* is the *productNames* table.  This contains a list of product identifiers that correspond to how your removeAds product has been set in iTunes Connect, Google Play, Amazon etc.  This table allows your product to have different names in different app stores.  In the example above, our *remove_ads* product has the identifier *remove_ads* by one programmer in iTunes Connect, but another has given it the name *REMOVE_BANNER* in Google Play.  When you tell IAP Badger that you want to purchase *removeAds*, it will automatically work out what the correct identifier is depending on which store you are connecting to.

*(Note that setting up products on Google Play, Amazon, iTunes Connect et al is beyond the scope of this tutorial).*

The *product_type* value can be one of two values: **consumable** or **non-consummable**.  **consumable** items are like gold coins in a game that can be purchased and then spent, or used up.  The user can purchase and re-purchase consumable items to their hearts content.  **non-consummable** items can only be purchased once, and can be restored by the user if they ever delete and re-install the app, or purchase a new device.  The *removeAds* product is non-consummable,.

There now follow two functions.  These functions should work silently, only making changes to the inventory (we'll deal with telling the user about successful purchases later).

 - onPurchase: this function is called following a successful purchase.  In the example above, an item called "unlock" with the value "true" is added to the inventory.
 - onRefund: this function is called following a refund.  In the above, the "unlock" item is removed from the inventory (the *true* value indicates that the item should be completely removed from the inventory).

Now let's add a simple inventory item to the catalogue.  The inventory items simply tell IAP Badger a little about how the items should be handled in the inventory.

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

#####Making a purchase

The following code will handle the purchase of our remove banner item:

```lua

--The callback function
--IAP will call purchaseListener with the name of the product
--Transaction is a table containing the original transaction information table passed by Corona
local function purchaseListener(product, transaction)

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

You can now debug your in app purchases on the simulator.  When the iap.purchase or iap.restore functions are called, you will receive an alert box asking you how you would the app store to respond (eg. successful purchase, cancelled by user, failed transaction).  Your callback functions will receive exactly the same information they will receive in the live environment, so you can test and step through code to make sure it works correctly.

The debug mode can also be set to work on a real device.  If IAP Badger detects it is being run on a device, you will receive a warning when the library is initialised.  This is to make sure you don't accidentally send this version of the code to the app store.


### How to use: consumable items

####Example 2: Purchasing coins (as in game currency)

The example code given above shows how to handle non-consumable items in the player inventory (ie. the user has purchased them, or they haven't.)  Non-consumable items don't really have a quantity as such - they are present or absent.

The following section looks at how to implement consumable items, such as packs of coins that can be spent on in game items.  Once the user has spent all of their coins, they have run out.  Consumable items cannot be restored from the App Store; if the user wants another pack of coins to use in the game, they will need to make another purchase.

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
		--Tell the user the ads have been removed
		native.showAlert("Purchase complete", "You now have 50 more coins.", {"Okay"})
	end
	
end

--Make the purchase
iap.purchase("buy50coins", purchaseListener)


```

In the above example, a text label is updated to show the new quantity of coins the player is now holding.  iap.getInventoryValue("coins") returns the current number of coins the user is carrying - the inventory will be updated before the 'noisy' purchase listener function is called.

#####Restoring

Consumable items cannot be restored from the App Store.  If IAP Badger detects a request to restore a consumable item, this is presumably suspect and will be ignored.


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
local priceFor50Coins = loadProductsCatalogue.buy50coins.localizedPrice
local priceFor100Coins = loadProductsCatalogue.buy100coins.localizedPrice

```

As with all of the other functions in IAP Badger, you should query the table returned by iap.getLoadProductsCatalogue using product identifier specified in your product catalogue (*buy50coins*), **not** the identifier for the item in the App Store (not *buy50coins* or *50_coins*).

You can also set up debug price information in the product catalogue:

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

This can be useful during early development when you are working on the Corona simulator.

####Generating an Amazon test JSON file

IAP Badger can generate the JSON file necessary to test your product on an Amazon device (eg. the Kindle Fire).  To print out the JSON representing your product catalogue to the console, use the following:

```Lua
--The following assumes you have created already set up a product catalogue as in the above examples.
 
--Initialise IAP (the options specified in iapOptions do not impact on this example)
iap.init(iapOptions)

--Print JSON for Amazon devices to the console window
print(iap.generateAmazonJSON())

```

Now copy and paste the console output and save it as a separate file.  This can be loaded onto your Amazon device and be used to test your IAP functionality.



###Security

The default security included with IAP Badger is intended to make it difficult for someone with a rooted device to open your application folder and amend the settings files to gain free access to in-app purchases.  If you include the device UDID as part of the salt in your catalogue, it will also mean a user cannot easily copy settings files from one rooted device to another.  IAP Badger can improve this level of security by refactoring (renaming) the identifiers and quantities held within the inventory, so as to disguise their true meaning.

There are several reasons why an obfuscation, rather than a encryption, approach has been adopted:

- The use of encryption is the USA and France involves registering for additional certificates from the authorities; the number of countries this is applicable to is only going to increase.
- The use of encryption does not protect your application's data from someone who is intent on hacking your code.  In fact, it gives you a false sense of security that your app is safe.
- The approach taken should be enough to deter most casual users from hacking your IAP's - the additional time spent investing in developing over-secure systems to deter a handful of hackers could be better spent building new apps for the world to enjoy.
- IAP purchases are also subject to insecurities in DNS and server re-routing, which are outside the capabilities of the app to detect.

For those who wish to add encryption to their data files, just include the standard Corona openssl library at the top of the IAP Badger source code, and add encryption / decryption to the saveTable and loadTable routines.

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
		}
	
}

```

The above refactor table specifies that the property 'unlock' should be saved as 'lastUserTxRefreshTimer' in the save file.  The value associated with it in the save file will be stored as "ms".

The purpose of the refactorFunction is to convert the boolean value ('true') into something less obvious to the casual user.  The function returns a random value from 1-1000 when 'true' is passed; if 'false' is passed, it returns a random value from 1001-2000.  Because the function returns a range of values for true and false, it is more difficult for the casual user to work out their function by comparing the data files of two rooted devices.

The defactorFunction (if defactor is a word!?) is to reverse the above.  So any value passed between 1-1000 is returned as true; anything else is returned as false.

(Note: the line **name="value"** must appear for each refactored item in the properties table.  Its use is reserved for future versions of IAP Badger, which may include the ability to record subscription dates or other information.)

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
		}
	
}

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

Randomised items in the inventory can be included in the refactor table if you so choose: however, however, any functions you specify to refactor and defactor the values associated with them will be ignored.

###Other useful functions

 - printInventory(): prints a JSON encoded inventory to the console output.
 - emptyInventory(disposeAll): empties the inventory, holding onto any non-consumable items.  If **disposeAll** is set to **true**, everything is removed from the inventory.
 - emptyInventoryOfNonConsumableItems(): removes any non-consumable items from the inventory.
 - inventoryItemCount(): returns the number of different item types in the inventory.
 - isInventoryEmpty(): returns **true** if the inventory is empty.
 - isStoreAvailable(): returns **true** if the store is available on the device.
 - setDebugMode(mode, store): forces debug mode to **true/false**; store=name of store to simulate.

###Full list of options for iap.init() function

 - **catalogue**: a table containing the product catalogue information
 -  **filename**: the filename to use to save the user's inventory
 -  **refactorTable**: a table that describes how IAP badger should refactor (rename) items and values
 -  **salt**: the salt to use to hash the user's inventory, to test whether its contents have been altered
 -  **failedListener**: a user defined function listener for when a purchase has failed (this can be a 'noisy' function)
 -  **cancelledListener**: a user defined function listener for when a purchase has been cancelled by the user (this can be a 'noisy' function)
 - **debugMode**: indicating that IAP should be put in debug mode, even if the app is installed on a device.  When debugMode is being used on a device, a warning message is presented when the iap.init() is called.
 -  **debugStore**: a string to indicate which store IAP Badger should pretend to be (ie. apple, google, amazon)
 -  **doNotLoadInventory**: set true to start with an empty inventory (useful for debugging)
 -  **badHashResponse**: indicates what should happen when a bad hash is discovered on the inventory file.  Can be set to: "errorMessage", which gives the user an error message; "emptyInventory" to empty the inventory and display no warning message at all; "error" to print an error message to the console and empty the inventory; a user defined function, that will be called when a bad hash is detected.

