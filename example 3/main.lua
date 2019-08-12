--Example2.lua
--
--Simple example of using IAP Badger to purchase an IAP for buying coins.


---------------------------------
-- 
-- IAP Badger initialisation
--
---------------------------------

--Load IAP Badger
local iap = require("iap_badger")

--Progress spinner
local spinner=nil
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
    
    --If the spinner is on screen, remove it
    if (spinner) then 
        spinner:removeSelf()
        spinner=nil
    end
    
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
    --doNotLoadInventory=true,
    debugMode=true,
}

--Initialise IAP badger
iap.init(iapOptions)


local function purchaseListener(product)
    --Remove the spinner
    spinner:removeSelf()
    spinner=nil
    
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



