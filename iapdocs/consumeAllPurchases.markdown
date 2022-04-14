# iap_badger.consumeAllPurchases()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | version
| __See also__         | 


## Overview

On Google Play, this function instructs IAP Badger to consume every product in the catalogue, making all IAPs available for purchase.  This will include non-consumable products that have been purchased in the past.  No changes are made to the user's inventory (if you are using IAP Badger's inventory system) - this simple resets the purchases available through the Google Play store.

consumeAllPurchases is useful during testing, to reset the IAPs available to a user.  (Remember that consuming products is not instantaneous) 

This function only applies to Google Play; it is ignored on all other platforms.


## Syntax

	iap_badger.consumeAllPurchases()



