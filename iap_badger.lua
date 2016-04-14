
--Create library
local public={}

--Store library
local store=require("store")
public.store=store

--[[

IAP badger - the trolley of the future.
Version 2

Currently supports: iOS App Store / Google Play / Amazon / simulator

General features:
* a unified approach to calling store and IAP whether you're on the App Store, Google Play, or wherever
* simplified calling and testing of IAP functions, just provide a list of products and some simple callbacks for when items are purchased / restored or
  refunded
* simplified product maintenance (adding/removing products from the inventory)
* handles loading / saving of items that have been purchased
* put IAP badger in debug mode to test IAP functions in your app (purchase / restore) without having to contact real stores
* products can have different names across the range of stores (so an upgrade called 'COIN_UPGRADE' in iTunes  Connect could be called 
  'coins_purchased' in Google Play)
* different product types available (consumable or non-consumable)

Inventory / security features:
* customise the filename used to save the contents of the inventory
* inventory file contents can be hashed to prevent unauthorised changes (specify a 'salt' in the init() function).
* a customisable 'salt' can be applied to the contents so no two Corona apps produce the same hash for the same inventory contents.  (Empty inventories
  are saved without a hash, to make it more difficult to reverse engineer the salt.)
* product names can be refactored (renamed) in the save file to disguise their true function
* quantities / values can also be disguised / obfuscated
* 'random items' can be added to the inventory, whose values change randomly with each save, to help disguise the function of other quantities 
  being saved at the same time.
* IAP badger can generate a Amazon test JSON file for you, to help with testing on Amazon hardware


Thought for the day: with all the security measures imaginable, anyone who wants to jailbreak/root their device so they can then
    disassemble/hack your app is going to do so.  No amount of data / code obfuscation will stop them.  Accept it and move on.
    
    
Changelog

Version 2:
* support added for Amazon IAP v2
* removed generateAmazonJSON() function as it is no longer required (JSON testing file can now be downloaded from Amazon's website)
* fixed null productID passed on fake cancelled/failed restore events
* changes to loadInventory and saveInventory to add ability to load and save directly from a string instead of a device file (to allow for cloud saving etc.)
* added getLoadProductsFinished() - returns true if loadProducts has received information back from the store, false if loadProducts still waiting, nil if loadProducts never called

This code is released under an MIT license, so you're free to do what you want with it -
though it would be great that if you forked or improved it, those improvements were
given back to the community :)

    The MIT License (MIT)

    Copyright (c) 2015/16 The Happy Mongoose Company Ltd.

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


--]]

--[[

Catalogue   

This is a list of items that can exist in the inventory, and the products that the user can buy.  For an example, the inventory
could contain diamonds, that are consumable items.  The user can buy products such as a pack of 10 diamonds, 50 diamonds or 100 diamond.
Products can have different names on different app stores.

Inventory items:
    --productType (required) legal types are: consumable, non-consumable, random-integer, random-decimal, random-hex.
            consumable items exist in a boolean state (they have been purchased, or they haven't).  If the item in in the inventory,
                it returns true to queries about it's value; if it's not in the inventory, it returns nil.
            non-consumable items exists as quantities.  If the item ever reaches a quantity of '0' it is completely removed from the inventory -
                this means queries about its quantity will return 'nil' rather than 0.
            random-integer, random-decimal and random-hex will just throw out random values every time the 
                table is saved.  Their use is solely to disguise the function of other variables in the inventory - add as many/few
                of these you like, but ignore their quantities once added to the inventory.
    --randomLow, randomHigh (for random items only): for random-integer, random-decimal and random-hex, these are the low/high bounds to
                use when generating the random number at save time.

Product catalogue options:
    --productType (required) legal types are: consumable and non-consumable
            consumable items exist in a boolean state (they have been purchased, or they haven't).  If the item in in the inventory,
                it returns true to queries about it's value; if it's not in the inventory, it returns nil.
            non-consumable items exists as quantities.  If the item ever reaches a quantity of '0' it is completely removed from the inventory -
                this means queries about its quantity will return 'nil' rather than 0.
    --onPurchase (required for all app stores): function to call when the item is purchased or restored (IAP badger treats them as the same).
            However, as the basic Corona transaction event is passed, if you need to distinguish between the two, look at transaction.state. 
            The callback function must take the form:
            function purchaseListener(itemName, event)
                itemName = name of item purchased as listed in the product catalogue
                transaction = original transaction info as passed from Corona.  However, one item has been added: firstRestoreCallback.
                        If this is the first item received following a restore call, transaction.firstRestoreCallback will be set to true.  Use this
                        as an indicator that you should remove any spinners / waiting messages you may have up on screen.
    --onRefund (required for some app stores): function to call when the item is purchased.  Must take the form:
            function refundListener(itemName, event)
                itemName = name of item refunded as listed in the product catalogue
                transaction = original transaction info as passed from Corona
    --productNames table (required): a list of names that identify the product in each of the app stores.  For instance, the IAP name of a coin_upgrade in
            iTunes connect may be 'COIN_UPGRADE', but in Google Play as 'coin_purchase', or in Amazon as 'COIN001'.  Use the name
            of the store as it appears in the store.target function (eg. either "amazon", "apple", "gameStick", "google",
            "nook" or "samsung" at the time of writing.)
    --simulatorPrice (optional): the price that will be returned for this product in the loadProducts() function when using the simulator.
    --simulatorDescription (optional): the description that will be returned for this product in the loadProducts() function when using the simulator.
    --reportMissingAsZero (optional): if the item is missing from the inventory, it's value will be returned at 0 (rather than nil)
Here are a few examples:

iap = require("iap_badger")
local catalogue = {

    --Inventory items that appear in inventory
    inventoryItems = {
        unlock = {
            productType="non-consumable"
        },
        coins = {
            productType="consumable"
        },
        pixelGammaAdjustment = {
            productType="random-integer",
            randomLow=1,
            randomHigh=10
        },
        timeGammaAdjustment = {
            productType="random-decimal",
            randomLow=1,
            randomHigh=10
        },
        fakeHash = {
            productType="random-hex",
            randomLow=10000,
            randomHigh=20000
        }
    },
    
    --Products that the user can buy through IAP.  Requires productNames, onPurchase, onRefund and productType to be set
    products = {
        buyUpgrade = {
            productNames = {
                apple="add_sub_upgrade",
                google="add_sub_upgrade"
            },
            onPurchase=function() 
                iap.setInventoryValue("unlock", true)
            end,
            onRefund=function() 
                iap.removeFromInventory("unlock", true)
            end,
            productType="non-consumable"
        },
        buy50coins = {
            productNames = {
                apple="mul_div_upgrade",
                google="mul_div_upgrade"
            },
            onPurchase=function() 
                iap.addToInventory("coins", 50)
            end,
            onRefund=function() 
                iap.removeFromInventory("coins", 50)
            end,
            productType="consumable"
        },
    }
    
}

    Handling restores
    -----------------
    
    Following a restore call, Corona will receive back a number of restore callbacks indicating products the user has 
    previously purchased.  The only problem is that the IAP systems do not indicate that 'this product is the last in the list'.
    
    All restore events initially call the onPurchase callback.  All code in the onPurchase callback should be 'quiet' (ie.
    not pass any messages to the user about the purchase being succesful).  Save that sort of message for the post restore listener that
    you identified when you called iap_bader.restore.
    
    The first call to this function should remove any "waiting" messages / spinners from the screen if the
    transaction.firstRestoreCallback flag is set to true.  It can ignore any further calls when firstRestoreCallback is set to nil.
    The implication of this is that further restore messages could be in the pipeline, and they will continue to work silently
    over the next few seconds as the information finds its way across the internet.  This is imperfect, but the best that can currently
    be achieved.

    To avoid race conditions between restores and purchases, do not allow your user (or your code) to make a purchase
    before either the successful postRestoreListener or timeoutFunction is called following your restore request.     
--]]

local catalogue=nil

--[[
Destination table for info

This is a table that indicates which of the above products has been purchased.  For example:
    inventory = {
        upgrade1 = { value = true },
        upgrade2 = { value = 1 },
    }
If a product does not exist in the inventory, it has not been purchased
--]]
local inventory=nil
public.inventory=inventory

--[[
This bit is entirely optional.

The refactoring table contains options for disguising the nature of the product.  If a refactorTable is provided,
the products name and quantity will be disguised in the save table; the code will take care of naming and renaming each item, 
so the calling program only has to worry about the 'true' name of the item.  (Eg. we have an product called 'unlock_program', but don't want to 
leave such an obvious description lying around the game's file system.  In the file system, you could save the product under
the name 'crash_record', and the inventory code will take care of this - the calling code only has to worry about
querying for 'unlock_program'.  Quantities can also be refactored to, so the value 1 may be stored as '27'.)

To help hide the function of specific variables, random variables can be included that will change their
value every time the inventory is saved.  This may help hide the function of certain variables if someone attempts
to reverse engineer the file (by looking at what happens before and after a purchase is made).

None of this is perfect - if anyone wants to disassemble your code and crack your game, they will; however, refactoring
rather than encrypting helps to avoid some of the difficulties associated with using encryption to save/load information
(such as having to apply for export certificates in the USA and France before your app can be legally purchased).

The refactor table is a table containing an entry for every item of the inventory you want to refactor.  So it must be
given in the form

table = {
    {
        item1,
        item2,
        item3...
    }
}

Each item describes how to refactor/rename an item in the inventory.  Each item takes the form:

item = {
    name="real name",
    refactoredName="hidden name"
    
    --The below is optional
    property={
        property1,
        property2,
        property3...
    }
}

The properties table is a list of properties that describe each object in the inventory.  At the moment, the only property 
implemented is 'value', which describes how many of the item are stored in the inventory 
(this may be expanded later to store start/stop dates for subscriptions etc.)  Properties can be refactored as well - and
the properties table .  The values that are stored can also be disguised. 

property = {
    name="value",
    refactoredName="hidden property name",
    refactorFunction=function() end
    defactorFunction=funciton() end
}

random-integer, random-decimal and random-hex entries can all be refactored as well.  This may be preferable: by default,
these items have their property value listed as 'value' also, when they could be changed into 'n-ary', 'hash-value' or
something equally indecipherable.

I appreciate this all sounds very complicated.  Here's an example for those that learn by doing:


refactorTable={
    {
        --Item 1 - an upgrade
        {
            name="upgrade1",
            refactoredName="a",
            properties={
                {
                    name="value",
                    refactoredName="height",
                    --Disguise the value
                    refactorFunction=function(value) return (value*6)+4 end,
                    --The defactor function 'un-disguises' the value (it is always the inverse of the refactor function)
                    defactorFunction=function(value) return (value-4)/6 end
                }
            }
        },

        --Item 2 - an unlock
        {
            name="unlock",
            refactoredName="b",
            properties={
                {
                    name="value",
                    refactoredName="width",
                    refactorFunction=function(value) if (value==true) then return math.random(1,100) else return math.random(101,200) end,
                    defactorFunction=function(value) if (value>=1) and (value<=100) then return true else return false end
                }
            }
        },

        --A random var
        {
            name="fakeHash",
            refactoredName="hash",
            properties = {
                {
                    name="value",
                    refactoredName="cyc10"
                    --Don't need refactor functions for the value as they are automatically randomised anyway
                }
        }
    }
    }    
    
    The original save file would look something like this:
    upgrade1 = { value=10 }
    unlock = { value=true }
    fakeHash = { value=<random> }
    
    The refactored save file would look like:
    a = { height = 64 }
    b = { width = 57 }
    hash = { cyc10 = 0x38273 }
    
    This helps disguise the true nature of the variables store in the file system.
--]]
local refactorTable=nil
public.refactorTable=refactorTable


--Filename for inventory
local filename=nil
public.filename=filename

--Salt used to hash contents (if required by user)
local salt=nil
--Requires crypto library
local crypto = require("crypto")
            
--Is the store available?
local storeAvailable=false
    --Get function
    local function isStoreAvailable() return storeAvailable end
    public.isStoreAvailable=isStoreAvailable

--Forward references
local storeTransactionCallback
local fakeRestore
local fakeRestoreListener
local fakePurchase

--Restore purchases timer
local restorePurchasesTimer=nil
--Transaction failed / cancelled listeners
local transactionFailedListener=nil
local transactionCancelledListener=nil

--Info about last transaction 
local previouslyRestoredTransactions=nil

--Target store
local targetStore=nil
--Debug mode
local debugMode=false
--Store to debug as
local debugStore="apple"

--Standard response to bad hash
local badHashResponse="errorMessage"

--A convenience function - returns a user friendly name for the current app store
local storeNames = { apple="the App Store", google="Google Play", amazon="Amazon", none="a simulated app store"}
local storeName = nil

--Function to call after storeTransactionCallback (optional parameter to purchase function)
local postStoreTransactionCallbackListener=nil
local postRestoreCallbackListener=nil
local fakeRestoreTimeoutFunction=nil
local fakeRestoreTimeoutTime=nil

--Flag to indicate if this is the first item following a restore call
local firstRestoredItem=nil
--Action type - either "purchase" or "restore".  Used for faking Google purchase or restore
local actionType=nil

--List of products / prices returned by the loadProducts function.  If no product catalogue is available,
--the loadProductsCatalogue will contain "false" after the loadProducts function has been called (nil beforehand)
local loadProductsCatalogue=nil
    --Accessor function for getting at the catalogue
    local function getLoadProductsCatalogue() return loadProductsCatalogue end
    public.getLoadProductsCatalogue = getLoadProductsCatalogue

local loadProductsFinished=nil
    local function getLoadProductsFinished() return loadProductsFinished end
    public.getLoadProductsFinished = getLoadProductsFinished
    
--Returns number of items in table
local function tableCount(src)
	local count = 0
	if( not src ) then return count end
	for k,v in pairs(src) do 
		count = count + 1
	end
	return count
end

-- ***********************************************************************************************************

--Load/Save functions, based on Rob Miracle's simple table load-save functions.
--Inventory adds a layer of protection to the load/save functions.

local json = require("json")
local DefaultLocation = system.DocumentsDirectory
local RealDefaultLocation = DefaultLocation
local ValidLocations = {
   [system.DocumentsDirectory] = true,
   [system.CachesDirectory] = true,
   [system.TemporaryDirectory] = true
}

local function tableIsEmpty (self)
    if (self==nil) then return true end
    for _, _ in pairs(self) do
        return false
    end
    return true
end

local function saveToString(t)
    
    local contents = json.encode(t)
    --If a salt was specified, add a hash to the start of the data.
    --Only include a salt if a non-empty table was provided
    if (salt~=nil) and (tableIsEmpty(t)==false) then
        --Create hash
        local hash = crypto.digest(crypto.md5, salt .. contents)
        --Append to contents
        contents = hash .. contents
    end
        
    return contents
    
end

local function saveTable(t, filename, location)
    if location and (not ValidLocations[location]) then
     error("Attempted to save a table to an invalid location", 2)
    elseif not location then
      location = DefaultLocation
    end
    
    local path = system.pathForFile( filename, location)
    local file = io.open(path, "w")
    if file then
        local contents = saveToString(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end
 
local function loadInventoryFromString(contents)
    
    --If the contents start with a hash...
    if (contents:sub(1,1)~="{") then
        --Find the start of the contents...
        local delimeter = contents:find("{")  
        --If no contents were found, return an empty table whatever the hash
        if (delimeter==nil) then return nil end
        local hash = contents:sub(1, delimeter-1)
        contents = contents:sub(delimeter)
        --Calculate a hash for the contents
        local calculatedHash = nil
        if (salt) then
            calculatedHash = crypto.digest(crypto.md5, salt .. contents)
        else
            calculatedHash = crypto.digest(crypto.md5, contents)
        end
        --If the two do not match, reject the file
        if (hash~=calculatedHash) then
            if (badHashResponse=="emptyInventory") then 
                return nil
            elseif (badHashResponse=="errorMessage") then
                native.showAlert("Error", "File error.", {"Ok"})
                return nil
            elseif (badHashResponse=="error" or badHashResponse==nil) then 
                error("File error occurred")
                return nil
            else 
                badHashResponse() 
                return nil
            end
        end
    end
    
    return json.decode(contents);
        
end

local function loadTable(filename, location)
    if location and (not ValidLocations[location]) then
     error("Attempted to load a table from an invalid location", 2)
    elseif not location then
      location = DefaultLocation
    end
    local path = system.pathForFile( filename, location)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = loadInventoryFromString(contents)
        io.close( file )
        return myTable
    end
    return nil
end

local function changeDefaultSaveLocation(location)
	if location and (not location) then
		error("Attempted to change the default location to an invalid location", 2)
	elseif not location then
		location = RealDefaultLocation
	end
	DefaultLocation = location
	return true
end

-- ***********************************************************************************************************

local function printInventory()
    print (json.encode(inventory))
end
public.printInventory = printInventory

--Searches for the inventory item with the given name in the refactor table.  If it does not exist, then nil is returned.
local function findNameInRefactorTable(name)
    
    --If no refactor table is available, just return the name that was passed - there is no refactoring to be done
    if (refactorTable==nil) then return nil end
    
    --For every item in the table
    for key, value in pairs(refactorTable) do
        if (value.name==name) then return value end
    end
    
    return nil
end


--Searches for the inventory item with the given refactored name in the refactor table.  If it does not exist, then nil is returned.
local function findRefactoredNameInRefactorTable(rName)
    
    --If no refactor table is available, just return the name that was passed - there is no refactoring to be done
    if (refactorTable==nil) then return nil end
    
    --For every item in the table
    for key, value in pairs(refactorTable) do
        if (value.refactoredName==rName) then return value end
    end
    
    return nil
    
end


--Refactors the given property
--  rObject - object from the refactor table describing how to refactor all of the properties
--  property - the name of the property to refactor
--  value - the value to refactor
--Returns: refactoredPropertyName, refactoredPropertyValue
local function refactorProperty(rObject, propertyName, propertyValue)
    
    --If there is no property information in the table, return the values that were given (there
    --is no refactoring to be done)
    if (rObject.properties==nil) then return propertyName, propertyValue end
    
    --Loop through the properties refactoring information to find the property
    for key, value in pairs(rObject.properties) do    
        --If this is the key specified by the user...
        if (value.name==propertyName) then
           --Refactor the property name (if one was given)
           local refactoredName = propertyName
           if (value.refactoredName~=nil) then refactoredName=value.refactoredName end
           --Refactor the value (if a function is provided)
           local refactoredValue = propertyValue
           if (value.refactorFunction~=nil) then refactoredValue = value.refactorFunction(propertyValue) end
           --Return the values
           return refactoredName, refactoredValue
        end
    end
    
    --There is no information describing how to refactor this property, so return the values
    --that were given
    return propertyName, propertyValue
    
end

--Defactors the given property
--  rObject - object from the refactor table describing how to refactor all of the properties
--  property - the name of the property to defactor
--  value - the value to defactor
--Returns: defactoredPropertyName, defactoredPropertyValue
local function defactorProperty(rObject, propertyName, propertyValue)
    
    --If there is no property information in the table, return the values that were given (there
    --is no refactoring to be done)
    if (rObject.properties==nil) then return propertyName, propertyValue end
    
    --Loop through the properties refactoring information to find the property
    for key, value in pairs(rObject.properties) do    
        --If this is the key specified by the user...
        if (value.refactoredName==propertyName) then
           --Defactor the property name (if one was given)
           local defactoredName = propertyName
           if (value.name~=nil) then defactoredName=value.name end
           --Defactor the value (if a function is provided)
           local defactoredValue = propertyValue
           if (value.defactorFunction~=nil) then defactoredValue = value.defactorFunction(propertyValue) end
           --Return the values
           return defactoredName, defactoredValue
        end
    end
    
    --There is no information describing how to refactor this property, so return the values
    --that were given
    return propertyName, propertyValue
    
end


--Creates a recfactored inventory
local function createRefactoredInventory()
    
    --If the refactor table is nil, return the inventory
    if (refactorTable==nil) then return inventory end
    
    --Create a new table that will be copy of the inventory table
    local refactoredInventory = {}
        
    for key, values in pairs(inventory) do
        
        --Store the key and value 
        local refactoredName=key
        local refactoredValues=values
        
        --Does the inventory item exist in the refactor table>
        local refactorObject = findNameInRefactorTable(key)
        
        --If it does, then refactor
        if (refactorObject~=nil) then
            --Change the name of the object
            if (refactorObject.refactoredName~=nil) then refactoredName = refactorObject.refactoredName end
            --Iterate through the properties
            for pKey, pValue in pairs(values) do
                --Spare table to hold refactored values
                refactoredValues={}
                --Refactor
                local refactoredPropertyKey, refactoredPropertyValue = refactorProperty(refactorObject, pKey, pValue)
                refactoredValues[refactoredPropertyKey]=refactoredPropertyValue
            end
        end
        
        --Add the refactored information into the new inventory
        refactoredInventory[refactoredName] = refactoredValues
    end
    
    
    return refactoredInventory
end
public.createRefactoredInventory = createRefactoredInventory

--Creates a defactored inventory -- not sure if that's a real word, but there you go
local function createDefactoredInventory(inventoryIn)
    
    --Create a new table that will be copy of the inventory table
    local defactoredInventory = {}
        
    for key, values in pairs(inventoryIn) do
        
        --Store the key and value 
        local defactoredName=key
        local defactoredValues=values
        
        --Does the inventory item exist in the refactor table>
        local refactorObject = findRefactoredNameInRefactorTable(key)
        
        --If it does, then refactor
        if (refactorObject~=nil) then
            --Change the name of the object
            defactoredName = refactorObject.name
            --Iterate through the properties
            for pKey, pValue in pairs(values) do
                --Spare table to hold refactored values
                defactoredValues={}
                --Refactor
                local defactoredPropertyKey, defactoredPropertyValue = defactorProperty(refactorObject, pKey, pValue)
                defactoredValues[defactoredPropertyKey]=defactoredPropertyValue
            end
        end
        
        --Add the refactored information into the new inventory
        defactoredInventory[defactoredName] = defactoredValues
    end
    
    return defactoredInventory
end
public.createDefactoredInventory = createDefactoredInventory


--Goes through inventory, and enters random values for random-integer and random-decimal
--products
local function randomiseInventory()
    
    for key, value in pairs(inventory) do
        --Find the product in the product catalogue
        local product = catalogue.inventoryItems[key]
        --If the product is specified in the inventory...
        if (product) then
            --If the product type is random-integer...
            if (product.productType=="random-integer") then
                value.value=math.random(product.randomLow, product.randomHigh)
            elseif (product.productType=="random-decimal") then
                value.value=math.random(product.randomLow, product.randomHigh)+(1/(math.random(1,1000)))
            elseif (product.productType=="random-hex") then
                value.value=string.format("0x%x", math.random(product.randomLow, product.randomHigh))
            end
        end
    end
end

--Saves the inventory contents
--asString - if nil, the inventory will be saved on the user's device; if set to true,
--will return a string representing the inventory that can be used for saving the inventory elsewhere
--(ie. on the cloud etc.)
local function saveInventory(asString)
    --Create random values for random products
    randomiseInventory()
    --Refactor the inventory
    local refactoredInventory = createRefactoredInventory()
    --Save contents
    if (asString==nil) then
        saveTable(refactoredInventory, filename)        
    else if (asString==true) then
        return saveToString(refactoredInventory)
        end
    end
end
public.saveInventory = saveInventory

--Load in a previously saved inventory
--If inventoryString=nil, then the inventory will be loaded from the save file on the user's device.
--If a string is passed, the library will attempt to decode a text string containing the inventory - use
--this for loading from the cloud etc.
local function loadInventory(inventoryString)
    --Attempt to load inventory
    local refactoredInventory=nil
    if (inventoryString==nil) then    
        refactoredInventory = loadTable(filename)
    else
        refactoredInventory = loadInventoryFromString(inventoryString)
    end
    --If inventory does not exists, create one
    if (refactoredInventory==nil) then
        inventory={}
    else
        inventory=createDefactoredInventory(refactoredInventory)
    end
end
public.loadInventory = loadInventory


--Returns true if the specified product exists
local function checkProductExists(productName)
    --Does the product name exist in the product table?
    if (products[productName]==nil) then return false else return true end
end

--Returns the value of the current product inside the inventory (eg. a quantity / boolean)
--If the item is not in the inventory, this returns nil.
local function getInventoryValue(productName) 
    if (inventory[productName]==nil) then 
        if catalogue.inventoryItems[productName] and catalogue.inventoryItems[productName].reportMissingAsZero then return 0 end
        return nil 
    end
    return inventory[productName].value
end
public.getInventoryValue = getInventoryValue

--Returns true if the item is in the inventory
local function isInInventory(productName)
    return inventory[productName]
end
public.isInInventory = isInInventory

--Returns the count of different itemt types in the inventory
local function inventoryItemCount()
    local ctr=0
    if (inventory==nil) then return 0 end
    for key, value in pairs(inventory) do
        ctr=ctr+1
    end
    return ctr
end
public.inventoryItemCount = inventoryItemCount

--Returns true if inventory is empty
local function isInventoryEmpty()
    return inventoryItemCount()==0
end
public.isInventoryEmpty = isInventoryEmpty

--Empties the inventory, keeping any non-consumable items.
--  disposeAll (optional): set to true to remove non-consumables as well (default=false)
local function emptyInventory(disposeAll)
    
    --Disposing everything is easy
    if (disposeAll==true) then
        inventory={}
        return
    end
    
    --Loop through and dispose of everything except non-consumables
    for key, value in pairs(inventory) do
        if (catalogue.inventoryItems[key].productType~="non-consumable") then
            inventory[key]=nil
        end
    end
end
public.emptyInventory=emptyInventory


--Empties the inventory, keeping any consumable items
local function emptyInventoryOfNonConsumableItems()
    
    --Loop through and dispose of all non-consumables
    for key, value in pairs(inventory) do
        if (catalogue.inventoryItems[key].productType=="non-consumable") then
            inventory[key]=nil
        end
    end
end
public.emptyInventory=emptyInventory


--Adds a product to the inventory
--  productName = name of the product to add
--  addValue (optional, default=1 for consumables, true for non-consuambles)
local function addToInventory(productName, addValue)
    
    --Get the product type
    local productType = catalogue.inventoryItems[productName].productType
    
    --If non-consumable, always set product value to true
    if (productType=="non-consumable") then
        inventory[productName]={value=true}
        return
    end
        
    --Adding a consumable so use a quantity
    --Random vars also end up here, but they ignore the quantity anyway, so don't
    --worry about it
    
    --Assume a quantity of 1, if no value if passed
    if (addValue==nil) then addValue=1 end
    
    --Does the current item already exist in the inventory?
    local currentValue=getInventoryValue(productName)
    --The following will handle cases where the product quantity comes back as zero rather than nil
    --(because user has specified things that way).  Zero quantities indicate something slightly
    --different to 'missing' items, so reset value to nil.
    if (currentValue==0) then currentValue=nil end
    
    --If it doesn't, create an entry for the item and quit
    if (currentValue==nil) then
        inventory[productName]={value=addValue}
        return
    end
    
    --Add the quantity to the stores of the item that are already there
    inventory[productName].value=currentValue+addValue    
    
end
public.addToInventory = addToInventory

--Returns true if product was removed, false if not
--  productName = product to remove
--  subValue (optional) - number of items to remove, defaults to 1.  Non-consumables are always removed.  If attempting to remove a consumable (for
--  some reason), then set subValue to true to force removal.  If this item is a consumable, use "all" to remove all of the item.
local function removeFromInventory(productName, subValue)
    
    --Get the product type
    local productType = catalogue.inventoryItems[productName].productType
    
    --If the object is non-consumable...
    if (productType=="non-consumable") then
        --...and the force flag is set to true...
        if (subValue==true) then
            --Remove item
            inventory[productName]=nil
            --Item was removed - non-consumable but user forced removal
            return true
        end
        --Item wasn't removed - it was non-consumable
        error("iap badger.removeFromInventory: attempt to remove non-consumable item (" .. productName .. ") from inventory.")
        return false
    end
    
    --If the object is a consumable...
    if (productType=="consumable") then
        --If no quantity is given, assume a quantity of 1
        if (subValue==nil) then subValue=1 end
        --Does the current item already exist in the inventory?
        local currentQuantity=getInventoryValue(productName)
        if (subValue=="all") then subValue=currentQuantity end
        --If there will be an underrun, signal the error
        if (currentQuantity<subValue) then
            error("iap badger.removeFromInventory: attempted to removed more " .. productName .. "(s) than available in inventory (attempted to remove " .. subValue .. " from " .. currentQuantity .. " available)")
            return false
        end
        --Remove the item
        inventory[productName].value = currentQuantity-subValue
        --If there are none of the item left, remove it from the inventory
        if (inventory[productName].value==0) then inventory[productName]=nil end
        --Item was removed
        return true
    end
    
    --If got here, than removing a random item - always just completely remove from inventory
    inventory[productName]=nil    
    return true    
    
end
public.removeFromInventory = removeFromInventory

--Sets the value of the item in the inventory.  No type checking is done - this is left to the user.
--  productName: the product to set
--  value_in: the value to set it to
local function setInventoryValue(productName, value_in)
    
    if (inventory[productName]==nil) then
        inventory[productName]={ value = value_in }
    else
        inventory[productName].value = value_in
    end
end
public.setInventoryValue=setInventoryValue


local function copyTable(arg)
    local t = {}
    for key, value in pairs(arg) do
        t[key] = value
    end
    return t
end


--Forces the debug mode
--  mode = true/false
--  store = name of store to simulator (defaults to apple)
local function setDebugMode(mode, store)
    
    --Set debug mode
    debugMode=mode
    
    --Copy in the debug store (if one was specified, and running on the simulator).  Ignore this on devices.
    if (system.getInfo("environment")=="simulator") then
        if (store~=nil) then debugStore=store else debugStore="apple" end
        storeName = storeNames[debugStore]
    end
    
    --If running on a device, and in debug mode, then make sure user knows
    if (system.getInfo("environment")~="simulator") and debugMode==true then
        native.showAlert("Warning", "Running IAP Badger in debug mode on device", {"Ok"})
    end
    
end
public.setDebugMode=setDebugMode

-- ************************************************************************************************************

--Returns the product name and product data from the catalogue, for the product with the given
--app store id.
local function getProductFromIdentifier(id)
    
    --Search the product catalogue for the relevant target store - if running in the simulator,
    --default to iOS.
    local searchStore=targetStore
    if (targetStore=="simulator") then searchStore=debugStore end
    
    local productName=nil
    local product=nil
    
    --For every item in the product catalogue
    for key, value in pairs(catalogue.products) do
        --If this product has a store product names table...
        if (value.productNames~=nil) then
            --If this product has an entry in the correct store for the item that has been purchased...
            if (value.productNames[searchStore]==id) then
                --Return the product name and the product info from the catalogue
                return key, value
            end
        end
    end    
    
    return nil, nil
end

--Returns the correct app store identifier for the specified product name
local function getAppStoreID(productName)
    
    --Search for the relevant target store - if running in the simulator,
    --default to iOS.
    local searchStore=targetStore
    if (targetStore=="simulator") then searchStore=debugStore end
    
    --Return the correct ID for this product
    return catalogue.products[productName].productNames[searchStore]
    
end

local function checkPreviousTransactionsForProduct(productIdentifier, transactionIdentifier)
    
    --If the table is empty, return false
    if (previouslyRestoredTransactions==nil) then 
        return false 
    end
    
    --Iterate over the table
    for key, value in pairs(previouslyRestoredTransactions) do
        --If this is the item specified...
        if (value.productIdentifier==productIdentifier) and
            (value.transactionIdentifier==transactionIdentifier) then
            --... indicate item found
            return true
        end
    end
    
    --Item wasn't found
    return false
    
end

--Transaction callback for all purchase / restore functions
local function storeTransactionCallback(event)

    --Get a copy of the transaction
    local transaction={}
        transaction.state=event.transaction.state
        transaction.productIdentifier=event.transaction.productIdentifier
        transaction.receipt=event.transaction.receipt
        transaction.signature=event.transaction.signature
        transaction.identifier=event.transaction.identifier
        transaction.date=event.transaction.date
        transaction.originalReceipt=event.transaction.originalReceipt
        transaction.originalIdentifier=event.transaction.originalIdentifier
        transaction.originalDate=event.transaction.originalDate
        transaction.errorType=event.transaction.errorType
        transaction.errorString=event.transaction.errorString
        transaction.transactionIdentifier = event.transaction.identifier
       
    --If on the Google or Amazon store, and the last action from the user was to make a restore, and this
    --appears to be a purchase, then convert the event into a restore
    if ( ((targetStore=="amazon") or targetStore=="google")) and (actionType=="restore") and (transaction.state=="purchased") then
        transaction.state="restored"
    end
    
    --If on the Amazon store, the revoked status is equivalent to refunded
    if (targetStore=="amazon") and (transaction.state=="revoked") then transaction.state="refunded" end
    
    --Search the product catalogue for the relevant target store - if running in the simulator,
    --default to iOS.
    local searchStore=targetStore
    if (targetStore=="simulator") then searchStore=debugStore end
    
    --Check product name if not a failed or cancelled event
    --Find the product by using its identifier in the product catalogue
    local productName, product = getProductFromIdentifier(transaction.productIdentifier)
    
    ---------------------------------
    -- Handle refunds (Android-based machines only)
    -- Refunds always follow a call to store.restore(); refunds shese should be silent, and will not initiate any callback.
    
    --Refunds on Amazon
    --  An amazon refund (revoke) can follow a restore callback - in which case, the refund should be ignored.
    if (targetStore=="amazon") and (transaction.state=="refunded") then
        --Check through the previously restored transactions to see if this product is listed
        if (checkPreviousTransactionsForProduct(transaction.productIdentifier, transaction.transactionIdentifier)==true) then
            --Just ignore this revoke - the user has previously revoked, repurchased and then restored the item
            if (debugMode~=true) then store.finishTransaction(event.transaction) end
            return true
        end
    end
    --All refunds should be silent
    if (transaction.state=="refunded") then
        --User callback
        if (product.onRefund~=nil) then product.onRefund(productName, transaction) end
        --Tell the store we're finished
        if (debugMode~=true) then store.finishTransaction(event.transaction) end
        --Return
        return true
    end
    
    
    ------------------------------
    -- The other transaction states (failed, cancelled, purchase, restore) can be noisy
    -- so cancel any restore purchases cancel timer.
    
    if (restorePurchasesTimer~=nil) then 
        timer.cancel(restorePurchasesTimer)
        restorePurchasesTimer=nil
    end
    
    ------------------------------
    -- Deal with problems first
    
    --Failed transactions
    if (transaction.state=="failed") then
        if (transactionFailedListener~=nil) then 
            transactionFailedListener(productName, event.transaction)
        else
            native.showAlert("Error", "Transaction failed: " .. transaction.errorString, {"Ok"})
        end
        --Tell the store we are finished
        if (debugMode~=true) then store.finishTransaction(event.transaction) end
        return true        
    end

    --User cancelled transaction
    if (transaction.state=="cancelled") then
        if (transactionCancelledListener~=nil) then
            transactionCancelledListener(productName, event.transaction)
        else
            native.showAlert("Information", "Transaction cancelled by user.", {"Ok"})
        end
        --Tell the store we are finished
        if (debugMode~=true) then store.finishTransaction(event.transaction) end
        return true
    end
    
    
    ------------------------------
    --If the program gets this far into the function, the product was purchased, restored or refunded.
    
    --If this is a restore callback, and this is the first item to be restored...
    if (firstRestoredItem==true) and (transaction.state=="restored") then
        --Add a flag to the transaction event that tells the user
        transaction.firstRestoreCallback=true
        --Reset the flag
        firstRestoredItem=nil
    end
    
    --If the product has not been identified, something has gone wrong
    if (product==nil) then
        error("iap badger.storeTransactionCallback: unable to find product '" .. transaction.productIdentifier .. "' in a product for the " .. 
            targetStore .. " store.")
        return false
    end

    --If successfully purchasing or restoring a transaction...
    if (transaction.state=="purchased") or (transaction.state=="restored") then
        --Call the user specified purchase function
        if (product.onPurchase~=nil) then product.onPurchase(productName, transaction) end
        --Tell the store we're finished
        if (debugMode~=true) then store.finishTransaction(event.transaction) end
        --If the user specified a listener to call after this transaction, call it
        if (transaction.state=="purchased") and (postStoreTransactionCallbackListener~=nil) then postStoreTransactionCallbackListener(productName, transaction) end
        if (transaction.state=="restored") and (postRestoreCallbackListener~=nil) and (product.productType~="consumable") then postRestoreCallbackListener(productName, transaction) end
        --If running on Amazon, and this is a restore, save the purchase info (may need to cancel a revoke later)
        if (targetStore=="amazon") and (transaction.state=="restored") then
            previouslyRestoredTransactions[#previouslyRestoredTransactions+1]=transaction
        end
        --If this is a consumable, and running on Google Play, immediate consume the item so it can be purchased again
        if (targetStore=="google") and (product.productType=="consumable") then
            --Run this on a timer - not recommended to consume purchases within the IAP listener
            timer.performWithDelay(10, function() store.consumePurchase({transaction.productIdentifier}) end)
        end
        return true
    end

    return false
end


--Returns a list of available products
local function getProductList()
    
    local list = {}
    for key, value in pairs(catalogue.products) do
        list[#list+1]=key
    end
    return list
    
end

--Returns the current store name
local function getStoreName()
    return storeName
end
public.getStoreName = getStoreName

--Returns the target store
local function getTargetStore()
    return targetStore
end
public.getTargetStore = getTargetStore

--Returns the identifier for the given product name in the current store (ie. product identifier in iTunes Connect
--may be different to Google etc.)  So, in the catalogue, a product called buyExtraLife might return BUY_LIFE if user
--is buying on iOS through iTunes Connect, or life_purchase on Google.
local function getProductIdentifierFromName(productName)
    if (onSimulator) then
        return catalogue.products[productName].productNames[debugStore]    
    else
        return catalogue.products[productName].productNames[targetStore]
    end
end
public.getProductIdentifierFromName=getProductIdentifierFromName


--Restores purchases
--If this is on a real device, the function will contact the appropriate store to see if there are any purchases that need restoring.
--In debug mode, this will ask you which purchases you would like to restore.
--   emptyFlag - empty the inventory of non-consumable items before restoring from store
--   postRestoreListener (optional) - function to call after restore is complete
--   timeoutFunction (optional) = function to call after a given amount of time if this function hangs (store.restore does not return a transaction when 
--        there are no transactions to restore.
--   cancelTime (optional): how long to wait in ms before calling timeoutFunction (default 10s)
local function restore(emptyFlag, postRestoreListener, timeoutFunction, cancelTime)
    
    if (emptyFlag~=true) and (emptyFlag~=false) then
        error("iap_badger.restore: restore called without setting emptyFlag to true or false (should non-consumables in inventory be removed before contacting store?")
        return
    end
    
    --Set action type
    actionType="restore"
    
    --Save post restore listener
    postRestoreCallbackListener = postRestoreListener
    
    --Remove all non-consumable items from inventory - these will be restored by the relevant App Store
    if (emptyFlag==true) then emptyInventoryOfNonConsumableItems() end
    
    --If no time passed, use a reasonable time (10s)
    if (cancelTime==nil) then cancelTime=10000 end
    
    --store.restore does not provide a callback if there are no products to restore - the code
    --is just left hanging.  Call the userdefined timeoutFunction after the specified amount of
    --time has elapsed if this happens.
    
    --Set the 'first item callback after a restore' flag
    firstRestoredItem=true
    
    --Reset the previously restored transactions table
    previouslyRestoredTransactions={}
    
    --Initiate restore purchases with store
    if (debugMode==true) then 
        fakeRestoreTimeoutTime=cancelTime
        fakeRestoreTimeoutFunction=timeoutFunction
        fakeRestore() 
    else
        --Start restore
        store.restore()
        --Set up a timeout if the user specified a timeoutFunction to call
        if (timeoutFunction~=nil) then 
            restorePurchasesTimer=timer.performWithDelay(cancelTime, function()
                --Kill the first restored item flag and fail callback pointer
                firstRestoredItem=nil
                restorePurchasesTimer=nil
                actionType=nil
                --Call the user defined timeout function
                timeoutFunction()
            end)
        end
    end
        
end
public.restore=restore

    
--Purchase function
--  productList: string or table of strings of items to purchase.  On Amazon, only a string is valid (Amazon only supports purchase of one item at a time)
--  listener (optional): function to call after purchase is successful/unsuccessful.  The function will be called with the transaction portion
--      of the store event.  ie. in the form: function(event) result=event.state (purchased, restored, failed, cancelled, refunded) end
local function purchase(productList, listener)
    
    --Save post purchase listener specified by user
    postStoreTransactionCallbackListener=listener
    
    --Kill the restore item flag if it has been set - attempting a purchase now
    firstRestoredItem=nil
    
    --Set action type
    actionType="purchase"
    
    --Convert string parameters into a table with a single element 
    if (type(productList)=="string") then productList={ productList } end
    
    -------------------------------
    --Handle Amazon separately
    
    if (targetStore=="amazon") then
        --Parameter check (user can only pass a string, rather than a table of strings, as Amazon only supports purchases one item at a time)
        if (tableCount(productList)>1) then
            error("iap_badger:purchase - attempted to pass more than one product to purchase on Amazon store (Amazon only supports purchase of one item at a time)")
        end
        --Convert the product from a catalogue name to a store name
        local renamedProduct = getAppStoreID(productList[1])
        --Purchase it
        if (debugMode==true) then 
            --Convert back into a table for fake purchases
            local renamedProductList = { renamedProduct }
            fakePurchase(renamedProductList)
        else
            --Real store will want the name of the product as a string (and nothing else)
            store.purchase(renamedProduct)
        end
        --Quit here
        return
    end    
    
    -------------------------------
    --Handle Google IAP v3 
    
    if (targetStore=="google") then
        --Parameter check (user can only pass a string, rather than a table of strings, as Google only supports purchases one item at a time)
        if (tableCount(productList)>1) then
            error("iap_badger:purchase - attempted to pass more than one product to purchase on Google Play (IAP v3 only supports one product purchase at a time)")
        end
        --Convert the product from a catalogue name to a store name
        local renamedProduct = getAppStoreID(productList[1])
        --Purchase it
        if (debugMode==true) then 
            --Convert back into a table for fake purchases
            local renamedProductList = { renamedProduct }
            fakePurchase(renamedProductList)
        else
            --Real store will want the name of the product as a string (and nothing else)
            store.purchase(renamedProduct)
        end
        --Quit here
        return
    end    
    
    
    --------------------------------
    --Other stores (and debug mode) all support purchase of more than one item at a time...
    
    --Convert every item in the product list from a catalogue name to a store name
    local renamedProductList = {}
    for key, value in pairs(productList) do
        local productID = getAppStoreID(value)
        renamedProductList[#renamedProductList+1]=productID
    end

    --Make purchase
    if (debugMode==true) then 
        fakePurchase(renamedProductList)
    else
        store.purchase(renamedProductList)
    end
    
end
public.purchase=purchase


--Initialises store
--  Options: table containing...
--      * catalogue = table containing a list of available products of items that appear in inventory
--      * filename = filename for inventory save file
--      * refactorTable (optional) = table containing refactor information
--      * salt (optional) = salt to use for hashing table contents
--      * failedListener (optional) = listener function to call when a transaction fails (in the form, function(itemName, transaction), where itemName=the item
--          the user was attempting to purchase, transaction = transaction info returned by Corona)
--      * cancelledListener (optional) = listener function to call when a transaction is cancelled by the user (in the form, function(itemName, transaction), 
--          where itemName=the item the user started to purchase, transaction = transaction info returned by Corona)
--      (If no function for tFailedListener or tCancelledListener is specified, a simple message saying the transaction was cancelled or failed (with a reason)
--      is given.)
--      * badHashResponse (optional) - indicates what to do if someone has been messing around with the inventory file (ie. the hash does not match
--          the contents of the inventory file).  Legal values are: 
--          * "errorMessage" for a simple "File error" message to be displayed to the user before emptying the inventory
--          * "emptyInventory" to display no message at all, other than the empty the inventory
--          * "error" to print an error message to the console and empty inventory (this may halt the program, depending on how your code is set up)
--          * function() end, a pointer to a user defined listener function to call when a bad hash is detected.
--          A bad hash will always result in the inventory being deleted.
--      * debugMode (optional) - set to true to start in debug mode
--      * debugStore (optional) - identify a store to use in debug mode (eg. "apple", "google").  Only valid on simulator
--      * doNotLoadInventory (optional) - set to true to start with an empty inventory (useful for debugging)

local function init(options)
        
    --Some options are mandatory
    if (options==nil) then
        error("iap_badger:init - no options table provided")
    end
    if (options.catalogue==nil) then
        error("iap_badger:init - no catalogue provided")
    end
    if (options.filename==nil) then
        error("iap_bader:init - no filename for inventory file provided")
    end
    --Get a copy of the products table
    catalogue=options.catalogue
    --Filename
    filename=options.filename
    --Refactor table (optional)
    refactorTable=options.refactorTable
    --Load in the salt (optional)
    salt=options.salt
    --Bad hash response
    if (options.badHashResponse~=nil) then badHashResponse=options.badHashResponse end
    --Transaction failed / cancelled listeners (both optional)
    transactionFailedListener = options.failedListener
    transactionCancelledListener = options.cancelledListener
    
    --Load in inventory
    if (options.doNotLoadInventory==true) then 
        inventory={}
    else
        loadInventory()
    end
    
    --On device or simulator?
    local onSimulator = (system.getInfo("environment")=="simulator")
    
    --Initalise store
        --Assume the store isn't available
        storeAvailable = false
        --Get the current device's target store
        targetStore = system.getInfo("targetAppStore")
        
        --If running on the simulator, set the target store manually
        if (onSimulator==true) then 
            targetStore="simulator" 
            storeAvailable=true
        end        
        
         --Initialise if the store is available
        if targetStore=="apple" and store.availableStores.apple then
            store.init("apple", storeTransactionCallback)   
            storeAvailable = true
        elseif targetStore=="google" then
            store=require("plugin.google.iap.v3")
            store.init("google", storeTransactionCallback)
            storeAvailable = true
        elseif targetStore=="amazon" then
            --Switch to the amazon plug in
            store=require("plugin.amazon.iap")
            store.init(storeTransactionCallback)      
            if (store.isActive) then storeAvailable=true end
        end
        
    --If running on the simulator, always run in debug mode
    debugMode=false
    if (targetStore=="simulator") then 
        --Set debug mode
        debugMode=true 
        --If a debug store to test was passed, use that
        if (options.debugStore~=nil) then debugStore=options.debugStore else debugStore="apple" end
        storeName = storeNames[targetStore]
    end
    
    --If debug mode has been set to true, always put in debug mode (even if on a device)
    if (options.debugMode==true) then debugMode=true end
    
    --Record store name
    if (onSimulator==false) then
        storeName = storeNames[targetStore]
    else
        storeName = storeNames[debugStore]
    end
    
    --If running on a device, and in debug mode, then make sure user knows
    if (onSimulator==false) and debugMode==true then
        native.showAlert("Warning", "Running IAP Badger in debug mode on device", {"Ok"})
    end
            
end
public.init = init


local function setCancelledListener(listener)
    transactionCancelledListener=listener
end
public.setCancelledListener = setCancelledListener

local function setFailedListener(listener)
    transactionFailedListener = listener
end
public.setFailedListener = setFailedListener

--***************************************************************************************************************
--
-- Debug functions
--
-- Comment these out to prevent them any code related to them being included in the final build of your app
--
--***************************************************************************************************************


--Fake purchases for simulator
fakePurchase=function(productList)
    
    --Only execute in debug mode
    if (debugMode~=true) then return end
    
    --For every item in the product list
    for key, value in pairs(productList) do
        --Ask the user what they would like to do - this is put in a timer as Android doesn't like too many
        --native.showAlerts close together
        timer.performWithDelay(150,
            function()
                --Ask user what App Store response they would like to fake
                native.showAlert("Debug", "Purchase initiated for item: " .. value .. ".  What response would you like to give?",
                    { "Successful", "Cancelled", "Failed" }, 
                    function(event)
                        if (event.action=="clicked") then
                            --Create a fake event table
                            local fakeEvent={
                                transaction={
                                    productIdentifier=value,
                                    state=nil,
                                    errorType=nil,
                                    errorString=nil
                                }
                            }
                            --Get index of item clicked
                            local i = event.index
                            if (i==1) then 
                                --Successful transactions
                                fakeEvent.transaction.state="purchased"
                            elseif (i==2) then 
                                --Cancelled transactions
                                fakeEvent.transaction.state="cancelled"
                            elseif (i==3) then 
                                --Failed transactions
                                fakeEvent.transaction.state="failed"
                                fakeEvent.transaction.errorType="Fake error"
                                fakeEvent.transaction.errorString="A debug error message describing nothing."
                            end  --end if i
                            --Fake callback
                            print("Purchasing " .. value)
                            storeTransactionCallback(fakeEvent)
                        end --endif event.action==clicked
                    end) --end native.showAlert
                
            end        
        )
    end
    
end

--Restore listener
fakeRestoreListener=function(event)
    
    --Only execute in debug mode
    if (debugMode~=true) then return end
    
    --If an option was clicked...
    if (event.action=="clicked") then
        --Get a product list
        local productList = getProductList()
        --Get copy of item clicked
        local index = event.index
        --Timeout is easy to deal with
        if (index==1) then 
            --Set up a timeout if the user specified a timeoutFunction to call
            if (fakeRestoreTimeoutFunction~=nil) then restorePurchasesTimer=timer.performWithDelay(fakeRestoreTimeoutTime, 
                function()
                    --Kill the first restored item flag and fail callback pointer
                    firstRestoredItem=nil
                    restorePurchasesTimer=nil
                    actionType=nil
                    --Call the user defined timeout function
                    fakeRestoreTimeoutFunction()
                end)
            end
            return 
        end
        
        --As is cancel
        if (index==3) then
            local fakeEvent={
                transaction={
                    productIdentifier="debugProductIdentifier",
                    state="cancelled",
                    errorType=nil,
                    errorString=nil
                }
            }
            storeTransactionCallback(fakeEvent)
            return
        end
        
        --And fail...
        if (index==2) then
            local fakeEvent={
                transaction={
                    productIdentifier="debugProductIdentifier",
                    state="failed",
                    errorType="Simulated error",
                    errorString="Fake error generated by debug."
                }
            }
            storeTransactionCallback(fakeEvent)
            return
        end
        
        --Restore all products...
        local productList = getProductList()
        --Iterate over the products
        for i=1, #productList do
            --Get the product
            local productID = getAppStoreID(productList[i])
            --If this product isn't consumable...
            if (catalogue.products[productList[i]].productType~="consumable") then 
                --Create a fake event for this product
                local fakeEvent={
                    transaction={
                        productIdentifier=productID,
                        state="restored",
                        errorType=nil,
                        errorString=nil
                    }
                }
                --If on Google Play, change the state to purchased (no restored state exists on Google Play)
                if (targetStore=="google") then fakeEvent.transaction.state="purchased" end
                --Restore purchase (fake)
                print("Restoring " .. productID)
                storeTransactionCallback(fakeEvent)            
            end
        end
        
    end
    
end

--Restores the given table of products.  These should be passed as item names in the catalogue
--rather than as app store ID's.
local function fakeRestoreProducts(productList)
    
    --If one item is passed as a string, convert it into a table
    if (type(productList)=="string") then
        productList = { productList }
    end
    
    --Restore all products...
    local productList = getProductList()
    --Iterate over the products
    for i=1, #productList do
        --Get the product
        local productID = productList[i]
        --Create a fake event for this product
        local fakeEvent={
            transaction={
                productIdentifier=productID,
                state="restored",
                errorType=nil,
                errorString=nil
            }
        }
        --If on Google Play, change the state to purchased (no restored state exists on Google Play)
        if (targetStore=="google") then fakeEvent.transaction.state="purchased" end
        --Restore purchase (fake)
        print("Restoring " .. productID)
        storeTransactionCallback(fakeEvent)            
    end
    
end
public.fakeRestoreProducts=fakeRestoreProducts


--Fake restore
--Gives user a list of products to restore from
fakeRestore = function(timeout)
    
    --Only execute in debug mode
    if (debugMode~=true) then return end
    
    --Create option list
    local optionList={"Simulate time out", "Simulate fail", "Cancel", "Restore products"}
    
    --Ask user which product they would like to restore
    timer.performWithDelay(50, function() native.showAlert("Debug", "What restore callback would you like to simulate?", optionList, fakeRestoreListener) end)
        
end

--------------------------------------------------------------------------------
-- 
-- loadProducts
--

local loadProductsUserCallback=nil


--Create a fake product event with information passed in the catalogue.  This function will be called from loadProducts when run in the
--simulator.  The user's callback function will be called after a brief delay.
local function fakeLoadProducts(callback)
    
    --Create a table containing faked data based on the product catalogue
    loadProductsCatalogue={}
    
    for key, value in pairs(catalogue.products) do
        
        --Create faked data
        local data={}
        --Use a title specified by the user (or a the product key in the catalogue if none is provided)
        if (value.simulatorTitle~=nil) then
            data.title=value.simulatorTitle
        else
            data.title = key
        end
        --Use the item description specified by the user (or a placeholder if none is provided)
        if (value.simulatorDescription~=nil) then
            data.description=value.simulatorDescription
        else
            data.description = "Product description goes here."
        end
        --Use the item price specified by the user (or a placehold if none is provided)
        if (value.simulatorPrice~=nil) then
            data.localizedPrice = value.simulatorPrice
        else
            data.localizedPrice = "$0.99"
        end
        --The product identifier is always the product name as specified for the current store
        data.productIdentifier = value.productNames[debugStore]
        --Type of purchase is always "inapp" (IAP badger doesn't currently support subscriptions)
        data.type="inapp"
        
        --Add data to callback table
        loadProductsCatalogue[key]=data
    end
    
    --If no user callback then quit now
    if (loadProductsUserCallback==nil) then return end
    
    --Create fake callback event data
    local eventData={}
    eventData.products=loadProductsCatalogue
    
    --Call the users callback function (after a brief delay to make it more realistic)
    timer.performWithDelay(2500, function() callback(eventData) end, 1)
    
end

--Callback function

local function loadProductsCallback(event)
    
    --If an error was reported (so the product catalogue couldn't be loaded), leave now
    if (event.isError) then return end
    
    --Create an empty catalogue
    loadProductsCatalogue={}
        
    --Copy in all the valid products into the product catalogue
    for i=1, #event.products do
        --Grab a copy of the event data (only need to perform a shallow copy)
        local eventData={}
        for key, value in pairs(event.products[i]) do
            eventData[key]=value
        end
        --Convert the product identifier (app store specific) into a catalogue product name
        local catalogueKey=nil
        for key, value in pairs(catalogue.products) do
            if (value.productNames[targetStore]==eventData.productIdentifier) then
                catalogueKey = key
                break
            end
        end
        if (not catalogueKey) then
            print("Unable to find a catalogue product name for the product with identifier " .. eventData.productIdentifier)
        end
        --Store copy
        loadProductsCatalogue[catalogueKey]=eventData
--        loadProductsCatalogue[eventData.productIdentifier]=eventData
    end
    
    --If a user specified callback function was specified, call it
    if (loadProductsUserCallback~=nil) then loadProductsUserCallback(event) end
    loadProductsFinished=true
    
end

--If possible, this function will download a product table from either Google Play, the App Store or Amazon and call the 
--specified callback function when complete.  The function itself will return true, indicating that a request was made.
--If no product table is available, or the store cannot process the request, the function will return false.
--If running on the simulator, the user's callback function will be passed a fake array containing fake data based on the product 
--catalogue specification.
--
--Assuming the function is successful, a table containing valid products will be placed in loadProductsCatalgoue, which can be
--access by the getLoadProductsCatalogue function - so strictly speaking it is not always necessary to pass a callback and simply
--interrogate the loadProductsCatalogue instead.  The table will contain false if loadProducts failed, or nil if loadProducts has never
--been called.
--
--The loadProducts table will be in the form of:
--productName
--  {
--   product data
--  }
--productName
--  {
--   product data
--  }
--...
--
--
--callback (optional): the function to call after loadProducts is complete.  The original loadProducts callback event data from 
--          Corona will be passed.

local function loadProducts(callback)
    
    --If running on the simulator, fake the product array
    if (targetStore=="simulator") or (debugMode) then
        fakeLoadProducts(callback)
        return true
    end
    
    --Return a nil value if products cannot be loaded from the real store
    if (store.canLoadProducts~=true) then 
        --Record that the loadProductsCatalgue failed
        loadProductsCatalogue=false
        --Return that this function failed
        return false 
    end
    
    --Generate a list of products
    local listOfProducts={}
    for key, value in pairs(catalogue.products) do
        listOfProducts[#listOfProducts+1]=value.productNames[targetStore]
    end
    
    --Save the user callback function
    loadProductsUserCallback=callback
    
    --Load products
    loadProductsFinished=false
    store.loadProducts(listOfProducts, loadProductsCallback)
    
end
public.loadProducts = loadProducts

return public
