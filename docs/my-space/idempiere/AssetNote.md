## MDepreciationWorkfile

MDepreciationWorkfile store importance asset value like cost, remain cost, Accumulated value, account date, current period,..

MDepreciationWorkfile normal has 3 method for 3 purpose

* getA_xxxx => natual value
* getA_xxxx_F => natual value for Fiscal
* getxxx => calculator value on fly

It has 2 special method for get fiscal value

* getxxx(,,,, isFiscal)) => get natual/calculator value for normal or fiscal by parameter
* setFiscal (sFiscal) => get natual/calculator value for normal or fiscal by set flag
  after call setFiscal, method getxxx wiil depend on the flag to return normal or fiscal

importance vallue

1. Remaining Cost
   remain cost store on database (column A_Asset_Remaining) = asset cost - Accumulated depreciated
   to get true remain cost (exclude Salvage vallue) use getRemainingCost
2. getActualCost
   exclude Salvage vallue

Importance method

1. buildDepreciation => to build/rebuild un-depreciation for each period

## MDepreciationExp

store depreciation for each period, it's create for all periods of asset, run "Post Depreciation Entry" to postting

importance method

1. updateFrom(updateFrom)
   it call when create MDepreciationExp and also when posting (process) MDepreciationExp to store value

   1. A_Asset_Cost
   2. A_Accumulated_Depr (F)
   3. UseLifeMonths (F)
   4. A_Asset_Remaining (F) (remain without exclude Salvage value)

   Because after process each depreciation Accumulated, Remaining will change so this value on MDepreciationExp difference before and after process
