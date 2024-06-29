# Nashville-Housing-Data

This project involves cleaning and standardizing a dataset from Nashville housing data using SQL.The goal is to improve data quality for accurate analysis and reporting.
Data Cleaning Steps:

- Data Cleaning Steps:
  -Standardizing Date Format:
    Converted SaleDate to a standard date format using TRY_CAST to handle conversion errors gracefully.
    Updated the SaleDate column with the standardized date values.
  -Populating Missing Property Addresses:
    Identified and filled null PropertyAddress values using self-join on ParcelID.
    Used ISNULL to replace null addresses with corresponding values from matching ParcelID rows.
  -Splitting Address Fields:
    Separated PropertyAddress into individual columns: PropertySplitAddress and PropertySplitCity.
    Utilized SUBSTRING and CHARINDEX functions to extract address components.
    Implemented similar logic for OwnerAddress, splitting it into OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState using PARSENAME after replacing commas with periods.

-Standardizing Boolean Values:
  -Converted SoldAsVacant values from 'Y', 'N', 'y', 'n' to 'Yes' and 'No' using CASE statements.
  -Updated the table with standardized boolean values.

-Removing Duplicate Records:
  -Identified duplicate rows based on ParcelID, PropertyAddress, SalePrice, SaleDate, and legalReference.
  -Used a CTE and ROW_NUMBER to delete duplicate records, retaining only unique entries.

-Additional Data Cleaning:

  -Deleting Unused Columns:
    -Dropped the original OwnerAddress and PropertyAddress columns after splitting them into separate fields.

-SQL Techniques Used:

  -TRY_CAST for safe data type conversion.
  -Self-joins for data imputation.
  -String manipulation with SUBSTRING, CHARINDEX, and PARSENAME.
  -Conditional updates with CASE statements.
  -Duplicate detection and removal using CTEs and window functions.

Assumptions and Insights:

-Assumed property addresses remain consistent across records with the same ParcelID.
-Discovered patterns in the dataset that facilitated data cleaning strategies, such as consistent addresses for ParcelID.

-Challenges and Solutions:

-Handling null values and ensuring non-disruptive updates.
-Standardizing diverse boolean representations.
-Efficiently splitting and updating address fields.










