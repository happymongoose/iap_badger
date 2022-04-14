# iap_badger: Plugin API Docs

*I don't make any charge for the use of IAP Badger - consider it my gift to you!  If you do find this module helpful, it would be amazing if you could download and rate one of [our games](http://happymongoosegames.co.uk) (they're all free to download).*

|                      | &nbsp;
| -------------------- | ---------------------------------------------------------------
| __Type__             | [Library](http://docs.coronalabs.com/api/type/Library.html)
| __Solar2D plugins__  | [iap_badger](https://www.solar2dplugins.com/plugins/iap-badger)
| __Keywords__         | iap, in app purchase, store, transaction, monetization, trolley, cart
| __See also__         | [Solar2D store API](http://docs.coronalabs.com/api/library/store/index.html), [Google IAP](http://store.coronalabs.com/plugin/google-iap), [Amazon IAP](http://docs.coronalabs.com/plugin/amazon.iap/index.html)

###For a step-by-step tutorial that explains how to set up and use IAP Badger, [click here](tutorial.markdown).
(If this is your first time using the library, you should definitely read it.)

## What is IAP Badger? (And what will it do for you?)

It's a simplified approach to in-app purchases with Solar2D SDK.

Although Solar2D SDK offers an IAP API that is quite similar across the app stores, there are differences depending on whether you are connecting to Apple's App Store, Google Play or through Amazon.  This can result in spaghetti code that is difficult to maintain.

The main benefit of using IAP Badger is you can forget all that.  You write one, simple piece of code that functions across all the app stores.

In terms of program flow and event handling, IAP Badger makes all of the stores appear to follow Apple's purchase and restore model.  For instance, it will automatically handle the consumption of consumable products on Google Play.

## Health warning...

I'm currently in the process of updating this documentation so it references Solar2D rather than Corona SDK.  This is still a work in progress, so in the short term, there may be some references that are out of date.

However... whilst references and links out to Corona SDK's website may be out-dated, the concepts in the documentation are still correct.


## Overview

The iap_badger plugin can be used in your [Solar2D](https://coronalabs.com/products/corona-sdk/) project.  It provides:

* A simplified set of functions for processing in app purchases (IAP)
* The ability to write a single piece of IAP code that works across Apple's App Store, Google Play and Amazon.
* Makes Google and Amazon stores appear to follow the purchase/restore model adopted by Apple.
* A built-in inventory system with basic security for load/saving purchases (if you want it)
* Products can have different names across the range of stores (so an upgrade called 'COIN_UPGRADE' in iTunes  Connect could be called 'coins_purchased' in Google Play) without the need for additional code
* A testing mode, so your IAP functions can be tested on the simulator or a real device without having to contact an actual app store.

To get to the simplest possible code for making an IAP purchase, scroll down to **Sample code (simplest possible IAP purchase)**.

IAP Badger is wrapper class written in pure lua for Solar2D's store libraries and the Google and Amazon plug-ins.

To find our about latest changes, and to ask questions about IAP Badger, [use this forum on Solar2D's website](https://forums.solar2d.com/t/iap-badger-a-unified-approach-to-in-app-purchases/149194).


## Syntax

	local iap = require "plugin.iap_badger"

### Functions

##### [iap_badger.addToInventory()](addToInventory.markdown)
##### [iap_badger.consumeAllPurchases()](consumeAllPurchases.markdown)
##### [iap_badger.emptyInventory()](emptyInventory.markdown)
##### [iap_badger.emptyInventoryOfNonConsumableItems()](emptyInventoryOfNonConsumableItems.markdown)
##### [iap_badger.getInventoryValue()](getInventoryValue.markdown)
##### [iap_badger.getLoadProductsCatalogue()](getLoadProductsCatalogue.markdown)
##### [iap_badger.getLoadProductsFinished()](getLoadProductsFinished.markdown)
##### [iap_badger.getStoreName()](getStoreName.markdown)
##### [iap_badger.getVersion()](getVersion.markdown)
##### [iap_badger.getTargetStore()](getTargetStore.markdown)
##### [iap_badger.init()](init.markdown)
##### [iap_badger.inventoryItemCount()](inventoryItemCount.markdown)
##### [iap_badger.isInInventory()](isInInventory.markdown)
##### [iap_badger.isInventoryEmpty()](isInventoryEmpty.markdown)
##### [iap_badger.isStoreAvailable()](isStoreAvailable.markdown)
##### [iap_badger.loadInventory()](loadInventory.markdown)
##### [iap_badger.loadProducts()](loadProducts.markdown)
##### [iap_badger.printInventory()](printInventory.markdown)
##### [iap_badger.printLoadProductsCatalogue()](printLoadProductsCatalogue.markdown)
##### [iap_badger.purchase()](purchase.markdown)
##### [iap_badger.removeFromInventory()](removeFromInventory.markdown)
##### [iap_badger.restore()](restore.markdown)
##### [iap_badger.saveInventory()](saveInventory.markdown)
##### [iap_badger.setCancelledListener()](setCancelledListener.markdown)
##### [iap_badger.setFailedListener()](setFailedListener.markdown)
##### [iap_badger.setInventoryValue()](setInventoryValue.markdown)


### Properties


## Project Configuration

### Solar2D Plugin

To use the library, add an entry for IAP Badger to your 'build.settings' file.

Solar2D will automatically make sure you are using the latest version of the library when you compile your code.

To do this:

* Visit [IAP Badger's Solar2D plugin page](https://www.solar2dplugins.com/plugins/iap-badger)
* Click the 'build.settings' button
* Copy the code snippet
* Paste it into the plugins section of your build.settings file

Then to use the plugin in your code, use:

```lua

local iap = require("plugin.iap_badger")

```


Note: there is also a version of IAP Badger held on a repository at [Github](https://github.com/happymongoose/iap_badger).  If you use include IAP Badger using this approach, download and include the IAP Badger library with the rest of your project files.  If you take this approach, you'll need to manually check you're using the latest version of the software. The code is provided under an MIT license, so you're free to fork it and do what you like with it.


## Platform-specific Notes

###iOS

I'm going to include this point here, because it comes up in support requests a lot.

Before you can start testing your in-app purchases on real devices, **you must have agreed to all of the contracts and agreements in iTunes Connect**.  And even then you may have to wait a while before your account starts working correctly.

You cannot test IAPs on the XCode simulator.  You **have to use a real device**.

To test on a real device, you need to build your app with **a development provisioning profile for that specific app.** ie. you cannot use a general ad hoc development provisioning profile.  This is true whether you're testing a sandbox user or a real one.


###Google Play

[Read this page](https://docs.coronalabs.com/plugin/google-iap-v3/) from Solar2D for more information about setting up IAP for Google Play devices.  I definitely recommend you do this.

First, you will need to [enable the Google IAP plug-in](https://marketplace.coronalabs.com/plugin/google-iap) for your Solar2D account.

You will need to include a new reference in your **build.settings** file to include the Google IAP v3 plugin for your app.

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

You will also need to enable the **BILLING** permission in **build.settings**.

```lua

    android =
    {
        usesPermissions =
        {
            "com.android.vending.BILLING",
        },
    },

```

Your app's key must be added to the license table in **config.lua**.  You will find the key for your app in Google Play Console.

```lua

	application =
	{
	    license =
	    {
	        google =
	        {
	            key = "Your key",
	        },
	    },
	}

```

When working on Google, changes you make in the Developer Console (such as publishing an in-app product) can take several hours to propagate around their servers.  Don't expect to add/change products and see immediate changes on your device.

Throughout the documentation, I'll refer to two product types: consumable and non-consumable.  Technically, these don't actually exist in Google Play - it only offers **managed products** and **subscriptions**.  You should choose the managed product type.  IAP Badger will implement consumable and non-consumable functionality for you.

*Promo codes*

In Google Play, be aware that the user can enter promo codes into the Google Play app.  These products will be handled in your product's restore cycle.  

This is not a problem for non-consumable products; however, IAP Badger ignores any attempt to restore a consumable (in most cases, it doesn't make sense).

Promo codes are an exception to this rule, though.  To override the default behaviour of ignoring restores for individual consumable products, add an **allowRestore** flag to your product in the product catalogue.

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


###Amazon

[Read this page](https://docs.coronalabs.com/plugin/amazon-iap-v2/index.html) from Solar2D for more information about setting up IAP for Amazon devices (I definitely recommend you do this).  To test your IAPs, you will need to install the [Amazon App Tester](https://developer.amazon.com/public/apis/earn/in-app-purchasing/docs-v2/installing-and-configuring-app-tester) on your testing device.

First, you will need to [enable the Amazon IAP plug-in](https://marketplace.coronalabs.com/plugin/amazon-iap) for your Solar2D account.

You will also need to include a new reference in your **build.settings** file to include the Amazon IAP v2 plugin for your app.


```lua

    plugins =
    {
        --Amazon IAP
        ["plugin.amazon.iap"] =
        {
            publisherId = "com.coronalabs",
            supportedPlatforms = { ["android-kindle"]=true }
        },

	}

```

###How to implement IAP quickly

The IAP Badger library is robust, has been tested in the real world and is used a range of Solar2D apps.

However, there are many things that can go wrong when you're adding IAP to your app.  There are many, tiny little ducks to get lined up in a row before anything works - and **everything** has to be lined up perfectly.  This is frustrating, is a massive time-sink and can make debugging difficult.

Learn from my mistakes.  To implement IAP in the quickest possible time, use the following workflow.

**Stage 1**

Any problems in Stage 1 are related to how your code is interacting with IAP Badger.

* Before you even go near a real device, get your in-app purchases up and running in the simulator (the tutorial will show you how).  This will ensure that your code is responding correctly to the IAP Badger library first **before** worrying about real app stores.
* Now test your code on a real device using **debug mode**.  This makes sure your code is happy on a device **before** it starts talking to the app store.

**Stage 2**

Any problems in Stage 2 are related to other factors, such as device setup / user accounts / developer console setup.

The flow is basically:

* Set up your IAPs in the relevant developer console.
* Prepare your device and testing accounts (usually you can't test a purchase with your developer account).
* Test on a real device, contacting a real app store, with a test account.
* Finally, test on a real device, with a real user account and a real credit card.

Stage 2 is all about following tutorials for setting up IAP in each developer console slowly and meticulously.  Don't assume anything, read everything twice and don't miss out a single step.  Put aside three times as much time as you'll think you'll need.

Tutorials about setting up in-app products in the developer consoles can be found here:

* iOS: [IAP configuration guide](https://help.apple.com/itunes-connect/developer/#/devb57be10e7), [the setup section of Solar2D's IAP guide](https://docs.coronalabs.com/guide/monetization/IAP/index.html#setup), [Solar2D's guide to creating certificates/provisioning profiles](https://docs.coronalabs.com/guide/distribution/iOSBuild/index.html)
* Google Play: [administering IAP](https://developer.android.com/google/play/billing/billing_admin.html), [testing in-app purchases](https://developer.android.com/google/play/billing/billing_testing.html)
* Amazon: [creating new in-app purchases](https://developer.amazon.com/public/apis/earn/in-app-purchasing/docs-v2/submitting-iap-items), [testing in-app purchases](https://developer.amazon.com/public/apis/earn/in-app-purchasing/docs-v2/testing-iap)

At the risk of repeating myself: read them, read them again, then read them another 15 times.  You'll need to follow every single step, super-meticulously, to get IAP to work.

In terms of debugging, setting **verboseDebugOutput** to true when you initialise IAP Badger ([see the init function](init.markdown)) can give you lots of extra information about what may be going wrong if you have any problems.

Be aware that you'll need to hook up your device by USB to read any debug information.  It's also useful to know that Solar2D prints out separate error messages about store code that are only accessible by this method (they're not available to either your app or IAP Badger).

* On iOS devices, use XCode to read debug messages.
* on Google Play or Amazon devices, use **adb logcat**.

It is beyond the scope of this documentation to explain how to set up XCode or how to install and use **adb logcat** (Google the web for a tutorial).

Last bit of help for those who are stuck:

On IOS:

* make sure you're signing your app with the correct provisioning profile.
* make sure you're using a development provisioning profile specific to your app (ie. you cannot use a general ad hoc provisioning profile)
* make sure you've agreed to all the contracts in iTunes Connect console
* make sure you're testing with a test user, not your developer account - this will involve: on your device, signing out of the App Store from your developer account (you do this from the device's settings menu); signing back into the App Store as your test user.  Read the above tutorials to find out how to set up a test user.
* trying to test on an XCode simulator? Forget it.  You need to be testing on a real device, whether testing a sandbox user or a real one.

On Google Play:

* make sure you've included your app's key in your **config.lua** file.
* make sure you've published/released your in-app products
* remember changes in the console can take a couple of hours of to hit your device
* if you're iterating quickly, make sure your build version number isn't greater than the one last uploaded to Google Play console
* make sure you're testing with a test user, not your developer account - this will involve: adding your test account to the Google Play app on your device; when testing, making sure your test account is selected as the active one in the Google Play app.  Read the above tutorials to find out how to set up a test user.

On Amazon:

* nothing to say really; it's least painful of all the ecosystems.  Can't recommend it enough.


## Resources

### Sample code (simplest possible IAP purchase)

The follow piece of code gives the simplest possible example of how to handle the purchase of a in-app product.

It will correctly handle an IAP for a product called "removeAds" across iOS, Google Play and Amazon.  This IAP can have different product IDs in each app store - IAP Badger automatically works out the correct product ID for the user's device at runtime.

For simplicity, in the catalogue, these are all grouped together into one over-arching name - "removeAds".  In IAP Badger, when referring to an in-app product, your code should **always use the catalogue name** (in this case, "removeAds").

Likewise, IAP Badger will always provide information about an IAP using its catalogue name, regardless of what device the app is running on.

**The only time you ever use the product ID from a specific app store is in the productNames table for your IAP.**



```lua

--Load IAP Badger
local iap = require("iap_badger")

--Create the catalogue
local catalogue = {

    --Information about the product on the app stores
    products = {     
        --removeAds is the product identifier.  This is how it will be referred to in calls to IAP Badger.
        removeAds = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.  Can be different from the product identifier specified in the line above.
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
local iapOptions = { catalogue=catalogue }

--Initialise IAP badger
iap.init(iapOptions)

--Called when the relevant app store has completed the purchase
--Make a record of the purchase using whatever method you like
local function purchaseListener(product)
    print "Purchase made"
end

iap.purchase("removeAds", purchaseListener)

```

For other short pieces of example code you can rip out and use in your app, see individual functions in the documentation (and [the tutorial](tutorial.markdown)).



### Sample Code (full)

The following pieces of code are full examples of how to code IAP purchases, including restore products, that you can use to base your own code on.  The examples here include full user interface code, including presenting the user with spinners and removing them from the screen.  Simpler examples are presented in the documentation for individual functions.

In both of the examples below, debugMode has been set to true, so the device will not attempt to make real purchases from the app store.

Both of these examples assume you are using the plug-in version of IAP Badger on Solar2D's servers (rather than manually including the library from Github).


####Example 2

Using IAP Badger to purchase an IAP for removing advertisements from an app, including all UI code.  Also includes a restore products function.

The full example project can be downloaded [here](http://happymongoosegames.co.uk/iapdocs/example%202.zip).

```Lua



--Example2.lua
--
--Simple example of using IAP Badger to purchase an IAP for removing advertisements from an app.
--Also includes a restore products function

---------------------------------
--
-- Declarations
--
---------------------------------

--Buy button group
local buyGroup=nil
--Advertisment group
local adGroup=nil

--Forward declaration for buyUnlock function
local buyUnlock=nil


---------------------------------
--
-- IAP Badger initialisation
--
---------------------------------

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
                --The function is called when a refund is made
                onRefund=function() iap.removeFromInventory("unlock", true) end,
        }
    },

    --Information about how to handle the inventory item
    inventoryItems = {
        unlock = { productType="non-consumable" }
    }
}

--Called when any purchase fails
local function failedListener()
    --If the spinner is on screen, remove it
    native.setActivityIndicator( false )

end

--This table contains all of the options we need to specify in this example program.
local iapOptions = {
    --The catalogue generated above
    catalogue=catalogue,
    --The filename in which to save the inventory
    filename="example1.txt",
    --Salt for the hashing algorithm
    salt = "something tr1cky to gue55!",

    --Listeners for failed and cancelled transactions will just remove the spinner from the screen
    failedListener=failedListener,
    cancelledListener=failedListener,
    --Once the product has been purchased, it will remain in the inventory.  Uncomment the following line
    --to test the purchase functions again in future.  It's also useful for testing restore purchases.
    --doNotLoadInventory=true
}

--Initialise IAP badger
iap.init(iapOptions)

---------------------------------
--
-- Making purchases
--
---------------------------------

--The functionality for removing the ads from the screen has been put in a separate
--function because it will be called from the purchaseListener and the restoreListener
--functions
local function removeAds()    
    --Remove the advertisement (need to check it's there first - if this function
    --is called from a product restore, it may not have been created)
    if (adGroup) then
        adGroup:removeSelf()
        adGroup=nil
    end
    --Change the button text
    buyGroup.text.text="Game unlocked"
    buyGroup:removeEventListener("tap", buyUnlock)
end

--Called when the relevant app store has completed the purchase
local function purchaseListener(product )
    --Remove the spinner
    native.setActivityIndicator( false )
    --Remove the ads
    removeAds()
    --Save the inventory change
    iap.saveInventory()
end

--Purchase function
--Places a spinner on screen to prevent any further user interaction with
--the screen.  The actual code to initiate the purchase is the single line iap.purchase("removeAds"...)
buyUnlock=function()

    --Place a progress spinner on screen and tell the user the app is contating the store
    native.setActivityIndicator( true )

    --Tell IAP to initiate a purchase
    iap.purchase("removeAds", purchaseListener)

end

---------------------------------
--
-- Restoring purchases
--
---------------------------------

local function restoreListener(productName, event)

    --If this is the first product to be restored, remove the spinner
    --(Not really necessary in a one-product app, but I'll leave this as template
    --code for those of you writing apps with multi-products).
    if (event.firstRestoreCallback) then
        --Remove the spinner from the screen
        native.setActivityIndicator( false )
        --Tell the user their items are being restore
        native.showAlert("Restore", "Your items are being restored", {"Okay"})
    end

    --Remove the ads
    if (productName=="removeAds") then removeAds() end

    --Save any inventory changes
    iap.saveInventory()

end

--Restore function
--Most of the code in this function places a spinner on screen to prevent any further user interaction with
--the screen.  The actual code to initiate the purchase is the single line iap.restore(false, ...)
local function restorePurchases()

    --Place a progress spinner on screen
    native.setActivityIndicator( true )

    --Tell IAP to initiate a purchase
    --Use the failedListener from onPurchase, which just clears away the spinner from the screen.
    --You could have a separate function that tells the user "Unable to contact the app store" or
    --similar on a timeout.
    --On the simulator, or in debug mode, this function attempts to restore all of the non-consumable
    --items in the catalogue.
    iap.restore(false, restoreListener, failedListener)

end


---------------------------------
--
-- Main game code
--
---------------------------------

--Remove status bar
display.setStatusBar( display.HiddenStatusBar )

--Background
local background = display.newRect(160,240,360,600)
background:setFillColor({type="gradient", color1={ 0,0,0 }, color2={ 0,0,0.4 }, direction="down"})

--Draw "buy" button
    --Create button background
    local buyBackground = display.newRect(160, 400, 150, 50)
    buyBackground.stroke = { 0.5, 0.5, 0.5 }
    buyBackground.strokeWidth = 2
    --Create "buy IAP" text object
    local buyText = display.newText("Remove ads", buyBackground.x, buyBackground.y, native.systemFont, 18)
    buyText:setFillColor(0,0,0)
    --Place objects into a group
    buyGroup = display.newGroup()
    buyGroup:insert(buyBackground)
    buyGroup:insert(buyText)
    buyGroup.text=buyText

--If the user has purchased the game before, change the button
if (iap.getInventoryValue("unlock")==true) then
    buyText.text="Game unlocked"
else
    --Otherwise add a tap listener to the button that unlocks the game
    buyGroup:addEventListener("tap", buyUnlock)
end

--Draw "restore" button
    --Create button background
    local restoreBackground = display.newRect(160, 330, 180, 50)
    restoreBackground.stroke = { 0.5, 0.5, 0.5 }
    restoreBackground.strokeWidth = 2
    --Create "buy IAP" text object
    local restoreText = display.newText("Restore purchases", restoreBackground.x, restoreBackground.y, native.systemFont, 18)
    restoreText:setFillColor(0,0,0)
    --Add event listener
    restoreText:addEventListener("tap", restorePurchases)

--If the user hasn't unlocked the game, display an advertisement across the top of the screen
if (iap.getInventoryValue("unlock")~=true) then
    --Create button background
    local adBackground = display.newRect(160, 75, 300, 75)
    adBackground:setFillColor( 1, 1, 0 )
    adBackground.stroke = { 0.5, 0.5, 0.5 }
    adBackground.strokeWidth = 2
    --Create "buy IAP" text object
    local adText = display.newText("Advertisment here", adBackground.x, adBackground.y, native.systemFont, 18)
    adText:setFillColor(0,0,0)
    --Assemble objects into a group
    adGroup = display.newGroup()
    adGroup:insert(adBackground)
    adGroup:insert(adText)
end




```

####Example 3

Using IAP Badger to purchase a two consumable in-app products (coin packs of different sizes), including full UI.

The full example project can be downloaded [here](http://happymongoosegames.co.uk/iapdocs/example%203.zip).


```Lua

--Example3.lua
--
--Simple example of using IAP Badger to purchase an IAP for buying coins.

---------------------------------
--
-- IAP Badger initialisation
--
---------------------------------

--Load IAP Badger
local iap = require("plugin.iap_badger")

--Text object indicating how many coins the user is currently holding
local coinText=nil

--Forward declaration
local buyCoins10=nil

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
        },

        --buy100coins is the product identifier.
        --Always use this identifier to talk to IAP Badger about the purchase.
        buy100coins = {
                --A list of product names or identifiers specific to apple's App Store or Google Play.
                productNames = { apple="buy100coins", google="100_coins", amazon="COINSx100"},
                --The product type
                productType = "consumable",
                --This function is called when a purchase is complete.
                onPurchase=function() iap.addToInventory("coins", 100) end,
                --The function is called when a refund is made
                onRefund=function() iap.removeFromInventory("coins", 100) end,
        },
    },

    --Information about how to handle the inventory item
    inventoryItems = {
        coins = { productType="consumable" }
    }
}

--Called when a purchase fails
local function failedListener()

  native.setActivityIndicator( false )

end

local iapOptions = {
    --The catalogue generated above
    catalogue=catalogue,
    --The filename in which to save the inventory
    filename="example2.txt",
    --Salt for the hashing algorithm
    salt = "something tr1cky to gue55!",

    --Listeners for failed and cancelled transactions will just remove the spinner from the screen
    failedListener=failedListener,
    cancelledListener=failedListener,
    --Once the product has been purchased, it will remain in the inventory.  Uncomment the following line
    --to test the purchase functions again in future.
    --doNotLoadInventory=true
    debugMode=true
}

--Initialise IAP badger
iap.init(iapOptions)

local function purchaseListener(product)
    --Remove the spinner
    native.setActivityIndicator( false )

    --Any changes to the value in 'coins' in the inventory has been taken care of.
    --Update the text object to reflect how many coins are now in the user's inventory
    coinText.text = iap.getInventoryValue("coins") .. " coins"

    --Save the inventory change
    iap.saveInventory()

    --Tell user their purchase was successful
    native.showAlert("Info", "Your purchase was successful", {"Okay"})

end

--Purchase function
buyCoins=function(event)

    --Place a progress spinner on screen and tell the user the app is contating the store
    native.setActivityIndicator( true )

    --Tell IAP to initiate a purchase - the product name will be stored in target.product
    iap.purchase(event.target.product, purchaseListener)

end

---------------------------------
--
-- Main game code
--
---------------------------------

--Remove status bar
display.setStatusBar( display.HiddenStatusBar )

--Background
local background = display.newRect(160,240,360,600)
background:setFillColor({type="gradient", color1={ 0,0,0 }, color2={ 0,0,0.4 }, direction="down"})

--Draw "buy 50 coins" button
    --Create button background
    local buy50Background = display.newRect(240, 400, 150, 50)
    buy50Background.stroke = { 0.5, 0.5, 0.5 }
    buy50Background.strokeWidth = 2
    --Create "buy IAP" text object
    local buy50Text = display.newText("Buy 50 coins", buy50Background.x, buy50Background.y, native.systemFont, 18)
    buy50Text:setFillColor(0,0,0)

    --Store the name of the product this button relates to
    buy50Background.product="buy50coins"
    --Create tap listener
    buy50Background:addEventListener("tap", buyCoins)

--Draw "buy 100 coins" button
    --Create button background
    local buy100Background = display.newRect(80, 400, 150, 50)
    buy100Background.stroke = { 0.5, 0.5, 0.5 }
    buy100Background.strokeWidth = 2
    --Create "buy IAP" text object
    local buy100Text = display.newText("Buy 100 coins", buy100Background.x, buy100Background.y, native.systemFont, 18)
    buy100Text:setFillColor(0,0,0)

    --Store the name of the product this button relates to
    buy100Background.product="buy100coins"
    --Create tap listener
    buy100Background:addEventListener("tap", buyCoins)

--Text indicating how many coins the player currently holds

--Get how many coins are currently being held by the player
local coinsHeld = iap.getInventoryValue("coins")
--If no coins are held in the inventory, nil will be returned - this equates to no coins
if (not coinsHeld) then coinsHeld=0 end

coinText = display.newText(coinsHeld .. " coins", 160, 20, native.systemFont, 18)
coinText:setFillColor(1,1,0)

```

### Support

More support is available from the Happy Mongoose Company:

* [E-mail](mailto://simon@happymongoose.co.uk)
* [Plugin Publisher](http://www.happymongoose.co.uk)


## Compatibility

| Platform                     | Supported
| ---------------------------- | ----------------------------
| iOS                          | Yes
| Android                      | Yes
| Android (GameStick)          | No
| Android (Kindle)             | Yes
| Android (NOOK)               | No
| Android (Ouya)               | No
| Mac App                      | No
| Win32 App                    | No
| Windows Phone 8              | No
| Solar2D Simulator (Mac)      | Yes
| Solar2D Simulator (Win)      | Yes


## Licence

This code is released under an MIT license, so you're free to do what you want with it.

**The MIT License (MIT)**

```
Copyright (c) 2015-2020 The Happy Mongoose Company Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Change log / updates

### Solar2D

Version 18 (July 21st 2020)
* ported to Solar2D marketplace
* updated documentation

### Corona SDK

Version 18 (Aug 12th 2019)
* purchases on Google Store that fail because the user already owns the specified item are now converted into standard purchase events (to replicate behaviour on iOS).  This can be turned on/off with the googleConvertOwnedPurchaseEvents flag during initialisation
* On Android, warnings given if no build store has been selected in the Solar2D build dialog

Version 17 (Can't remember!)
* corrected declaration of emptyInventoryOfNonConsumableItems

Version 16 (Oct 14th 2018)
* documentation updated - more detailed added to setCancelledListener and setFailedListener descriptions

Version 16 (Aug 2nd 2018)
* documentation change - simplified example code

Version 16 (May 27th 2018)
* fixed checkProductExists bug (thanks to bogomazon)

Version 15 (November 12th 2017)
* Bug fixes
* Library no longer crashes when the user attempts to purchase/restore and they're not logged into the App Store on an iOS device

Version 14 (November 11th 2017)
* Fixed bug introduced in version 12 on Android devices that mishandled failed/cancelled events
* Better handling (and improved consistency between devices) of transaction receipts

Version 13 (October 12th 2017)
* Fixed bug introduced in version 12 that would make cancelled or failed restores in debug mode fail
* Fixed bug introduced in version 12 that would affect standard restores in debug mode

Version 12 (October 7th 2017)
* added switch to ignore unknown product codes on purchase/restore - **handleInvalidProductIDs**
* downgraded invalid product IDs from an error that halts execution to a printed error to terminal
* added switch in catalogue to allow restore of individual consumable products (set **allowRestore** to true) - note that this item will now be included when running a restore cycle in debug mode
* removed some of instructional comments from the source code (out of date and better documentation available on http://happymongoose.co.uk anyway
* improved some debug output detail on verboseDebugOutput
* fixed incorrect error messages on consumption events on Google Play

Version 11 (August 10th 2017)
* fixed loadProducts not working correctly on simulator (when not passed a callback function)

Version 10 (August 9th 2017)
* fixed crash bug introduced by verboseDebugOutput when testing cancelled/failed restores on the simulator

Version 9 (August 6th 2017):
* library now automatically checks Solar2D build version to see how to interact with Google IAP v3 (so no need to explicitly set usingOldGoogle flag unless you want to)
* added verboseDebugOutput flag to init function (set this to true to get loads of debugging info about your app).

Version 8 (July 26th 2017):
* updated for Google IAP update (store.init now asynchronous)
* added getVersion, consumeAllPurchases and printLoadProductsCatalogue() functions
* improved handling of loadProducts in debug mode or on the simulator, so it better simulates the delay experienced on a real device
* updated documentation and tutorial to reflect latest changes

Version 7:
* decoupled inventory handling from IAP handling

Version 6:
* loadProducts - fixed user listener not being called correctly (again)
* loadProducts - for convenience, the user listener is now called with (raw product data, loadProductsCatalogue) on device;
*                   ({}, loadProductsCatalogue) on simulator.

Version 5:
* fix to getLoadProductsFinished when running in debug mode

Version 4:
* removed reference to stores.availableStores.apple

Version 3:
* fixed store loading (defaulting to Apple) on non-iOS devices

Version 2:
* support added for Amazon IAP v2
* removed generateAmazonJSON() function as it is no longer required (JSON testing file can now be downloaded from Amazon's website)
* fixed null productID passed on fake cancelled/failed restore events
* changes to loadInventory and saveInventory to add ability to load and save directly from a string instead of a device file (to allow for cloud saving etc.)
* added getLoadProductsFinished() - returns true if loadProducts has received information back from the store, false if loadProducts still waiting, nil if loadProducts never called
