--Data Cleaning Project 1 using housing dataset for nashville

--Pulling first 50 rows to show that Null values do exist, sales date can be converted to a different format, addresses can be stored better, etc

SELECT TOP 50 * FROM Housing..NashvilleHousing 
SELECT TOP 50 * FROM Housing..NashvilleHousing WHERE OwnerName is null



-- Changing the date format by adding a new column that will consist of the new formatted date

ALTER TABLE Housing..NashvilleHousing ADD SaleDateConverted Date;

UPDATE Housing..NashvilleHousing SET SaleDateConverted=Convert(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(date,SaleDate) FROM Housing..NashvilleHousing

--Cleaning the Address data

SELECT * FROM Housing..NashvilleHousing
ORDER BY ParcelID

--Joining the uniqueId with ParcelId to fill in some of the missing addres values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing..NashvilleHousing a
JOIN Housing..NashvilleHousing b
		ON a.ParcelID=b.ParcelID
		AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing..NashvilleHousing a
JOIN Housing..NashvilleHousing b
		ON a.ParcelID=b.ParcelID
		AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

--To store the address better, breaking down the PropertyAddress column into 3 new columns (Street Address, City, State)

SELECT SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as StreetAddress, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as StreetAddress
FROM Housing..NashvilleHousing

ALTER TABLE Housing..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Housing..NashvilleHousing SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Select OwnerAddress
From Housing..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Housing..NashvilleHousing

ALTER TABLE Housing..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Housing..NashvilleHousing SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE Housing..NashvilleHousing 
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Housing..NashvilleHousing SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE Housing..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Housing..NashvilleHousing SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT * FROM Housing..NashvilleHousing

--Removing Duplicate Values

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housing..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1


--Deleting repretitive columns
ALTER TABLE Housing..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress,SaleDate

SELECT * FROM Housing..NashvilleHousing