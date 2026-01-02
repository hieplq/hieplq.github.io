## Import Loader Format

AD_ImpFormat.AD_Table_ID table use to load column info

## Import Loader Format - Format Field

ImpFormat.loadRows => load format field info by merger info from AD_Column

so when use datatype = Constant value lenght is limit same lenth of column

it's hard to set default value for a field

1. import direct insert to database so can't use default value for Imported window (example Imported Fixed Asset)
2. value of Constant isn't support environment variable

 import a Constant value for date is hard, need to set value follow default date format (MM/dd/YYYY)

or you need to create a column on data file and define a format field with datatype = date, data format = suitable for ccolumn value (date format follow SimpleDateFormat)

* ImpFormatRow.parseDate
* ImpFormat.parseLine

or need to use callout to convert input value to time function or time value

callout on Import Loader Format is incomplete implement, it's direct instance class so need to use fragment to inject callout to adepiere base

need to more to osgi service
