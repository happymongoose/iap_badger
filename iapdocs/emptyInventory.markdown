# iap_badger.emptyInventory()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | remove, empty, inventory, iap
| __See also__         | [iap_badger.saveInventory()](saveInventory.markdown) [iap_badger.removeFromInventory()](removeFromInventory.markdown) [iap_badger.emptyInventoryOfNonConsumableItems()](emptyInventoryOfNonConsumableItems.markdown)


## Overview

Empties the inventory of all consumable items.

Note: changes won't be written permanently to the device until the [saveInventory()](saveInventory.markdown) function is called.


## Syntax

	iap_badger.emptyInventory()
	iap_badger.emptyInventory( disposeAll )

##### disposeAll <small>(required)</small>
_[Boolean](http://docs.coronalabs.com/api/type/Boolean.html)._ Set disposeAll to true to remove everything, including non-consumable items, from the inventory.


