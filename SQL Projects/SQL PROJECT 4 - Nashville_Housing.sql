-- Cleaning Data

select * from Nashvillehousing

------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- #1
select saledateconverted, convert (date, saledate)
from nashvillehousing

update Nashvillehousing
set saledate = convert (date, saledate)

-- #2
alter table Nashvillehousing
add saledateconverted date

update Nashvillehousing
set saledateconverted = convert (date, saledate)

------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from nashvillehousing
where propertyaddress is null

select * from nashvillehousing
--order by parcelid

update a
set propertyaddress = isnull( a.propertyaddress, b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
on a.parcelid = b.parcelid 
and a.[uniqueid] != b.[uniqueid]
where a.propertyaddress is null


------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select propertyaddress from nashvillehousing

-- #1
select
substring( Propertyaddress, 1, charindex(',', propertyaddress) -1 ) as address
, substring( Propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress) ) as address
from 
nashvillehousing


alter table Nashvillehousing
add PropertySplitAddress nvarchar(255)

update Nashvillehousing
set PropertySplitAddress = substring( Propertyaddress, 1, charindex(',', propertyaddress) -1 )


alter table Nashvillehousing
add PropertySplitCity nvarchar(255)

update Nashvillehousing
set PropertySplitCity = substring( Propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress) )


Select *
From NashvilleHousing


-- #2

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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

From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
