# Speeding Up Master Data Import in iDempiere

**Sponsored by**: [nTier Software Services](https://www.ntier.co.za/)

I needed to import approximately 4000 fixed assets into iDempiere. iDempiere supports two methods for importing master data:

---

## Methods for Importing Master Data

### 1. [Old Method](https://wiki.idempiere.org/en/Template:Import_File_Loader_(Form_ID-101_V1.0.0))

This method involves importing CSV files through the *Import File Loader*:

- Define an `I_` table, an import window, and an import process.
- Create an "Import Loader Format" for the table.
- Run the "Import File Loader" to load data from the CSV file into the `I_` table.
- Open the import window and invoke the process to apply logic for importing master data.

### 2. [New Method](https://wiki.idempiere.org/en/NF1.0_ImportCSV)

This method allows importing CSV files directly from any window:

- Prepare the import file.
- Run the CSV import process.

---

## Comparison of the Two Methods

| Feature                             | Old Method                                                                                                      | New Method                                                                                                                                                                                                              |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Support for Callouts**      | Limited support for converting values per field.                                                                | Full support for callouts.                                                                                                                                                                                              |
| **Support for Default Logic** | Uses direct SQL for importing, so ignore display logic in either the import loader format or the import window. | Fully supports display logic.                                                                                                                                                                                           |
| **Performance**               | Faster than the new method.                                                                                     | Automates key entry in the window, suitable for small datasets but slow for large datasets due to time spent looking up foreign keys.[Reference](https://mattermost.idempiere.org/idempiere/pl/84jcr3idmfgf8n4ud5f9aakngc) |
| **Effort**                    | Requires significant time to prepare, including coding for the import process.                                  | Requires refining the grid layout of the window and preparing the CSV file accordingly.                                                                                                                                 |
| **Complex Cases**             | Manual coding allows handling of complex cases.                                                                 | Handles complex cases using window events and model events.                                                                                                                                                             |

---

## Improving Data Import Speed

To speed up the import process, I combined the two methods and identified some issues (along with solutions).

### Combining the Two Methods

1. **Define the `I_` Table**

   - The Fixed Asset module already has an `I_FixedAsset` table.
   - I added additional columns for my customizations.
2. **Define the Import Window**

   - The Fixed Asset module already has an "Imported Fixed Asset" window.
   - I added additional fields for my customizations.
   - Used 'Window Customization' to hide unused fields and refine the grid view for clarity.
   - Defined default logic for missing data.
   - Prepared the CSV file based on the grid view.
   - **Used the New Method** to import data into the `I_FixedAsset` table.
3. **Create the Import Process**

   - The Fixed Asset module already has an `ImportFixedAsset` process.
   - In the process, foreign keys are looked up using values, names, or other criteria.
   - **SQL is used for lookups, performing one query for all records,** which is faster than window-based lookups.

---

### Issues with `ImportFixedAsset`

1. **Transaction Timeout**

   - The process uses a single transaction for all imported records. If the process runs for more than 2 hours, iDempiere will close the transaction due to the default timeout ([Added transaction timeout control](https://github.com/idempiere/idempiere/commit/e573983f5f8f68858519521f2ed5ebe8c6808e6e)).
2. **Performance Degradation**

   - Keeping a large transaction open causes performance to degrade over time, with each record taking longer to process.

---

### Solutions

1. **Increase Transaction Timeout**

   - I implemented a check to increase the timeout when it approaches the default limit.
2. **Batch Processing**

   - I modified the process to handle records in batches of 100, committing after each batch. This significantly improved performance and avoided the issues caused by large transactions.
