# iap_badger.getVersion()

|                      | &nbsp; 
| -------------------- | ---------------------------------------------------------------
| __Type__             | [function](http://docs.coronalabs.com/api/type/Function.html)
| __Library__          | [iap_badger.*](Readme.markdown)
| __Return value__     | 
| __Keywords__         | version
| __See also__         | 


## Overview

Returns the version number of IAP Badger currently installed.



## Syntax

	iap_badger.getVersion()




## Examples


Querying the library version currently in use:


```lua

--Include the plugin
local iap = require 'plugin.iap_badger'

--Print out the version of IAP Badger being used
print ("Running IAP Badger version " .. iap.getVersion())


```
