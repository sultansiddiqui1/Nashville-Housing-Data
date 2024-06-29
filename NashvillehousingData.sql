
-- Data Cleaning is sql:

select * from NashvilleHousingData

-- standardize the SaleData column:

select 
    SaleDate
    ,TRY_CAST(nhd.SaleDate AS DATE) as DateOnly
from 
NashvilleHousingData AS nhd
-- The TRY_CAST/ TRY_CONVERT function  attempts the conversion andf reutrns null if the conversion fails rather than causing an error.
-- we can also use them to identify problamatic value srather than the query failing entirely.

UPDATE NashvilleHousingData
set SaleDate=TRY_CAST(SaleDate AS DATE)
-- updating the column to only then containinf the date.

------------------------------------------------------------------------------------------

-- Populate the Property Address Data:

-- checking if we have null values. why there are null values is strange and something that i do not know.
select * 
from NashvilleHousingData AS nhd
where PropertyAddress is null
order by parcelId

-- we can say almost with certainty that the address of a property should not change. So we conclude that we can populate this 
-- column if we had a certain reference point.
-- INTERESTING FIND: on data exploration with parcelId we find out that two entries with the same parcelId have the same address.
-- we want to use this insight that we just developed to try and populate some of the empty/null property address.

-- doing a self join:
select a.ParcelID, a.PropertyAddress,b.parcelID, b.PropertyAddress, 
isnull(a.PropertyAddress,b.PropertyAddress) as replaceValue
-- so basically saying if a.PropertyAddress is null we populate it with b.PropertyAddress
from NashvilleHousingData as a 
join NashvilleHousingData as b
on a.parcelID=b.ParcelID
and a.UniqueID<> b.UniqueID -- so we basically want the rows with the same parcelId but are diffrent rows
WHERE a.PropertyAddress is null

-- Now updating the table:
update a
set  PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingData as a 
join NashvilleHousingData as b
on a.parcelID=b.ParcelID
and a.UniqueID<> b.UniqueID 
WHERE a.PropertyAddress is null

-- in cases where we do not have the data to populate the row but dont want null we can also pass in a string:
-- set PropertyAdress=isnull(a.PorpertyAddress,"No address");


-- Seperating the address into Indiviual columns(Adress, city , state)
-- sepearting based on the comma delimeter using a substring and character index/ char index

select PropertyAddress
from NashvilleHousingData

select 
SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1)) as Address,
-- 1 specifies the starting position and CHARINDEX specifies what we are lookign for ('tom' or 'john' pr whatever)
-- so basicaly taking the PropertyAddress starting at position 1 and going till the comma.
-- the -1 basically is like going one place behind the comma so that the comma is not inlcuded in the address field.

SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as State
from NashvilleHousingData
WHERE CHARINDEX(',', PropertyAddress)>0

-- MAKING THE CHANGES TO THE TABLE:

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress  NVARCHAR(255);

UPDATE NashvilleHousingData 
SET PropertySplitAddress= SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1))
where  CHARINDEX(',', PropertyAddress)>0

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity  NVARCHAR(255);


UPDATE NashvilleHousingData 
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 






-- Splitting the OwnerAddress using parsename as we saw above substring was a pain
select OwnerAddress
from NashvilleHousingData


select OwnerAddress,
-- THE PROBLEM IS OFCOURSE PARSENAME ONLY WORKS WITH PERIODS BUT WE HAVE COMMAS. so replacing them:
-- ps: important to remember that parsename does things opposite
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2) as city,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1) as state
from NashvilleHousingData
where OwnerAddress is not null 

-- adding the columns to the originasl table:
ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress  NVARCHAR(255);

UPDATE NashvilleHousingData 
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)
where OwnerAddress is not null 

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity  NVARCHAR(255);

UPDATE NashvilleHousingData 
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)
where OwnerAddress is not null 

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState  NVARCHAR(255);

UPDATE NashvilleHousingData 
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
where OwnerAddress is not null 

-----------------------------------------------------------------------------------------------


-- changing Y and N to Yes and No in SoldAsVacant field.

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousingData
Group by(SoldAsVacant)
order by 2 desc
-- we see that there are many diffrent kind of values in the field like yes, no, N, and y. WE WANT IT to be of the same type and
-- since majority of the data has values yes and no we want to convert to yes and no.

-- using case statements to convert the types to yes and no:
select SoldAsVacant,
CASE WHEN (SoldAsVacant='Y' or SoldAsVacant ='y') THEN 
    'Yes'
    When(SoldAsVacant='N' or SoldAsVacant='n') THEN
    'No'
    else SoldAsVacant
END
FROM NashvilleHousingData

-- changing the table now:

update NashvilleHousingData
set SoldAsVacant =CASE WHEN (SoldAsVacant='Y' or SoldAsVacant ='y') THEN 
    'Yes'
    When(SoldAsVacant='N' or SoldAsVacant='n') THEN
    'No'
    else SoldAsVacant
END




-- Remove Duplicate Values:
-- using a cte and some windows functions to find the null values.

-- using rownum as its the simplest and will do whjat i want to do exactly
IF OBJECT_ID('tempdb..RowNumCTE') IS NOT NULL
BEGIN
    DROP TABLE RowNumCTE;
END;


WITH RowNumCTE AS(
select *,
    row_number() OVER(
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     legalReference
                     ORDER BY
                        UniqueId
    ) row_num

-- WE need to partition it bny things that are unique to each row, and then we want to see if things like LegalReference, or 
-- the parcelID, SaleDate, PropertyAddress and SalePrice is the same then it most probably is the same and is a duplicate.
FROM NashvilleHousingData
)

delete 
    from RowNumCTE
    where row_num>1






--delete unused columns:not really a good coding practise but just incase i want to create a view
-- because we already split the owner address and PropertyAdress we will delete theml.
ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress, PropertyAddress
