# iap_badger.setCancelledListener()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[Table](http://docs.coronalabs.com/api/type/Table.html)_
| __Keywords__         | listener, cancelled, cancel, event
| __See also__         | 


## Overview

Sets the cancelled listener function that is called when an attempt to make a purchase is cancelled by the user.  By default, IAP Badger displays a message to the user to tell them their transaction was cancelled.

The cancelled listener call also be set in [iap_badger.init()](init.markdown), but can also be modified during app execution to respond appropriately at different times.


## Syntax

	iap_badger.setCancelledListener()


## Example

```lua
--Include the plugin
local iap = require 'iap_badger'

--New transaction cancelled event listener
local function newListener(productName, transaction)

	print ("Transaction was cancelled")

end

iap.setCancelledListener(newListener)

```
