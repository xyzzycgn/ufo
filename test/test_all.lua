---
--- Created by xyzzycgn.
--- DateTime: 28.11.25
---
require('test.BaseTest')

--########################################################

BaseTest.hooked = true

require('test.test_adapterHandling')

BaseTest.hooked = false
BaseTest:hookTests()
