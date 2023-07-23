/*

Data Cleaning in SQL 
Using Nashville Housing Data Set

*/

Use ProjectPortfolio
Select * from NashvilleHousing;

--1-- Standardize Date Format
SELECT  SaleDate, CONVERT(DATE,SaleDate) FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;


--2--Populate Property Adress/Replace Null Values
SELECT *
FROM NashvilleHousing
Where PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b
On a.ParcelID=b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]


--3-- Breaking Out Address Into Individual Columns
SELECT PropertyAddress FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),2)

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),1)


--4--Change Y and N to Yes and No in 'Sold as Vacant' field 
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

UPDATE NashvilleHousing
SET SoldAsVacant=CASE SoldAsVacant WHEN 'Y' THEN 'Yes'
								   WHEN 'N' THEN 'NO'
								   ELSE SoldAsVacant
								   END 

--5--Remove Duplicates 

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
FROM NashvilleHousing)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--6-- Delete Unused Columns 

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

SELECT * FROM NashvilleHousing