---
--- Created by xyzzycgn.
--- DateTime: 28.11.25
---
require('test.BaseTest')

--########################################################

BaseTest.hooked = true

require('test.test_adapterHandling')
require('test.test_ufo')
require('test.test_scale')
require('test.test_vaultHandling')

BaseTest.hooked = false
BaseTest:hookTests()
