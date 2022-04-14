# iap_badger
A simplified approach to in-app purchases with Corona SDKs.

Note: This project is no longer being actively maintained. Please feel free to create a new fork and use it as you wish :)

## What is IAP Badger? (And what will it do for you?)

Although Corona SDK offers an IAP API that is quite similar across the app stores, there are differences depending on whether you are connecting to Apple's App Store, Google Play or through Amazon.  This can result in spaghetti code that is difficult to maintain.

The main benefit of using IAP Badger is you can forget all that.  You write one, simple piece of code that functions across all the app stores.

In terms of program flow and event handling, IAP Badger makes all of the stores appear to follow Apple's purchase and restore model.  For instance, it will automatically handle the consumption of consumable products on Google Play.


## Overview

The iap_badger plugin can be used in your [Corona](https://coronalabs.com/products/corona-sdk/) project.  It provides:

* A simplified set of functions for processing in app purchases (IAP)
* The ability to write a single piece of IAP code that works across Apple's App Store, Google Play and Amazon.
* Makes Google and Amazon stores appear to follow the purchase/restore model adopted by Apple.
* A built-in inventory system with basic security for load/saving purchases (if you want it)
* Products can have different names across the range of stores (so an upgrade called 'COIN_UPGRADE' in iTunes  Connect could be called 'coins_purchased' in Google Play) without the need for additional code
* A testing mode, so your IAP functions can be tested on the simulator or a real device without having to contact an actual app store.

IAP Badger is wrapper class written in pure lua for Corona's Apple store libraries and the Google and Amazon IAP plug-ins.

It's supplied under an MIT license, so fork it and do what you like with it.


##Documentation

The code included in this repository is a standard lua library, which can be included in your project and forked/amended as required.  The library is also available as a standard Corona SDK plug-in.

The documentation for IAP Badger can be found in the iapdocs folder in this project.

To find our about latest changes, and to ask questions about IAP Badger, [use this forum on Corona's website](https://forums.coronalabs.com/topic/59137-iap-badger-a-unified-approach-to-in-app-purchases/).
