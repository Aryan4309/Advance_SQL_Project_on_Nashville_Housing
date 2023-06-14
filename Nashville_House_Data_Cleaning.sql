/*
Cleaning Data in SQL Queries
Skills used - CONVERT, Parse Name, Self Join, Is null, Update, Alter, String Functions, Case, CTEs, Row number 
*/

 use [Alex.Portfolio_Project_1]

Select * From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]
Order By 1

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardise the Date Format
Select SaleDate, CONVERT(date, SaleDate) SaleDateCorrected
From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]
Order By 1

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD SaleDateCorrected Date;

Update Nashville_Housing_Data_for_Data_Cleaning
SET SaleDateCorrected = CONVERT(date, SaleDate)

Select SaleDateCorrected From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]
Order By 1


----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select PropertyAddress From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]
Where PropertyAddress is null
Order By 1

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)-- populating Property address using isnull
From [dbo].[Nashville_Housing_Data_for_Data_Cleaning] a JOIN [dbo].[Nashville_Housing_Data_for_Data_Cleaning] b 
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] -- Self Join
Where a.PropertyAddress is null
Order By 1

-- Updating Property Address

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[Nashville_Housing_Data_for_Data_Cleaning] a JOIN [dbo].[Nashville_Housing_Data_for_Data_Cleaning] b 
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] -- Self Join
Where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking Out Address into Individual Columns (Address, City, State)
--Using SUBSTRING and Parse name to split the address

Select PropertyAddress From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS State
From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD Address nvarchar(255);

Update Nashville_Housing_Data_for_Data_Cleaning
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD City nvarchar(255);

Update Nashville_Housing_Data_for_Data_Cleaning
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]

-- Using parse name for splitting address (Since splitting it with substring is a pain)
-- Parse name uses periods "." to separate Words

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) State
From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD OwnerSplitAddress nvarchar(255);

Update Nashville_Housing_Data_for_Data_Cleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD OwnerSplitCity nvarchar(255);

Update Nashville_Housing_Data_for_Data_Cleaning
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD OwnerSplitState nvarchar(255);

Update Nashville_Housing_Data_for_Data_Cleaning
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" feild

SELECT SoldAsVacant, COUNT(SoldAsVacant) From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]
GROUP BY SoldAsVacant
Order By 2


Update Nashville_Housing_Data_for_Data_Cleaning
Set SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
				   When SoldAsVacant = 'N' THEN 'No'
				   Else SoldAsVacant
				   END 

 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates With CTE

WITH Row_Num_CTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
					) row_num
					
From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]
)
DELETE
FROM Row_Num_CTE
Where row_num > 1





----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select * From [dbo].[Nashville_Housing_Data_for_Data_Cleaning]

ALTER TABLE [dbo].[Nashville_Housing_Data_for_Data_Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [dbo].[Nashville_Housing_Data_for_Data_Cleaning]
DROP COLUMN SaleDate





----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO



