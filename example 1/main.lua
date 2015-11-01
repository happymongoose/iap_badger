
--Example1.lua
--
--Simple example of using IAP Badger to purchase an IAP for removing advertisements from an app.
--Also includes a restore products function

---------------------------------
-- 
-- Declarations
--
---------------------------------

--Progress spinner
local spinner=nil
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
    if (spinner) then 
        spinner:removeSelf()
        spinner=nil
    end
    
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
    --doNotLoadInventory=true,
    debugMode=true,
    
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
    spinner:removeSelf()
    spinner=nil
    --Remove the ads
    removeAds()
    --Save the inventory change
    iap.saveInventory()
    --Give the user a message saying the purchase was successful
    native.showAlert("Info", "Your purchase was successful", {"Okay"})
end

--Purchase function
--Most of the code in this function places a spinner on screen to prevent any further user interaction with
--the screen.  The actual code to initiate the purchase is the single line iap.purchase("removeAds"...)
buyUnlock=function()
    
    --Place a progress spinner on screen and tell the user the app is contating the store
    local spinnerBackground = display.newRect(160,240,360,600)
    spinnerBackground:setFillColor(1,1,1,0.75)
    --Spinner consumes all taps so the user cannot tap the purchase button twice
    spinnerBackground:addEventListener("tap", function() return true end)
    local spinnerText = display.newText("Contacting " .. iap.getStoreName() .. "...", 160,180, native.systemFont, 18)
    spinnerText:setFillColor(0,0,0)
    --Add a little spinning rectangle
    local spinnerRect = display.newRect(160,260,35,35)
    spinnerRect:setFillColor(0.25,0.25,0.25)
    transition.to(spinnerRect, { time=4000, rotation=360, iterations=999999, transition=easing.inOutQuad})
    --Create a group and add all these objects to it
    spinner=display.newGroup()
    spinner:insert(spinnerBackground)
    spinner:insert(spinnerText)
    spinner:insert(spinnerRect)
    
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
        spinner:removeSelf()
        spinner=nil        
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
    
    --Place a progress spinner on screen and tell the user the app is contating the store
    local spinnerBackground = display.newRect(160,240,360,600)
    spinnerBackground:setFillColor(1,1,1,0.75)
    --Spinner consumes all taps so the user cannot tap the purchase button twice
    spinnerBackground:addEventListener("tap", function() return true end)
    local spinnerText = display.newText("Contacting " .. iap.getStoreName() .. "...", 160,180, native.systemFont, 18)
    spinnerText:setFillColor(0,0,0)
    --Add a little spinning rectangle
    local spinnerRect = display.newRect(160,260,35,35)
    spinnerRect:setFillColor(0.25,0.25,0.25)
    transition.to(spinnerRect, { time=4000, rotation=360, iterations=999999, transition=easing.inOutQuad})
    --Create a group and add all these objects to it
    spinner=display.newGroup()
    spinner:insert(spinnerBackground)
    spinner:insert(spinnerText)
    spinner:insert(spinnerRect)
    
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

