# iap_badger.setFailedListener()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | _[Table](http://docs.coronalabs.com/api/type/Table.html)_
| __Keywords__         | listener, failed, fail, event
| __See also__         | 


## Overview

Sets the failed listener function that is called when an attempt to make a purchase fails - this could be due to a number of reasons, including network failure.  By default, IAP Badger displays a message to the user reporting the error text as described by the standard Corona store libraries.

The failed listener call also be set in [iap_badger.init()](init.markdown), but can also be modified during app execution to respond appropriately at different times.


## Syntax

	iap_badger.setFailedListener()


## Example

```lua
--Include the plugin
local iap = require 'iap_badger'

--New transaction failed event listener
local function newListener(productName, transaction)

	print ("Transaction failed")

end

iap.setFailedListener(newListener)

```
