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

It's supplied under an MIT license, so fork it and do what you like with it.


##Documentation

The code included in this repository is a standard lua library, which can be included in your project and forked/amended as required.  The library will (hopefully) soon be available as a standard Corona SDK plug-in.

To provide a single point of access for information about IAP Badger that is up to date, documentation and sample tutorials for IAP Badger will now be maintained [on our website](http://happymongoosegames.co.uk/iapbadger.php).

