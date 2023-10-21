select *
from NashvilleHousing

---Standardize date format

select Sale_Date, convert(Date,SaleDate)
from NashvilleHousing

alter table NashvilleHousing
Add Sale_Date date;

Update NashvilleHousing
set Sale_Date = convert(Date,SaleDate)

update NashvilleHousing
set saleDate = SaleDate date


---------------------------------------------------------------------------------------------------------------------------------
--Property Address Data

select *
from NashvilleHousing
---where propertyAddress is null 
order by ParcelID

-------------------------------------------------------------------------------------------------------------------------------
---Update prpopertyAddress where addressis null. Using  inside join. Join into thesame table

select a.parcelID, a.propertyAddress, b.parcelID, b.propertyAddress, isnull(a.propertyAddress,b.propertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.parcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
set propertyAddress = isnull(a.propertyAddress,b.propertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.parcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------------
--Breaking down Address into individualcolumns (Address, city, state). Using substring s and character index

select PropertyAddress
from NashvilleHousing
---where propertyAddress is null 
-- order by ParcelID

select 
substring(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City

from NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

select *
from NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------
---split owner address using Parsname

select ownerAddress
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerSplitACity

select 
PARSENAME(replace(ownerAddress,',','.') , 3)
,PARSENAME(replace(ownerAddress,',','.') , 2)
,PARSENAME(replace(ownerAddress,',','.') , 1)
from NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(ownerAddress,',','.') , 3)

alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(ownerAddress,',','.') , 2)

alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(ownerAddress,',','.') , 1)



select *
from NashvilleHousing
-----------------------------------------------------------------------------------------------------------------------------------------
----- Change Y and N  to Yes and No in "sold as Vacant" field using case

select distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2


select SoldAsVacant
,Case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
	  from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end

------------------------------------------------------------------------------------------------------------------------------------------------
--- Remove duplicate

 with RowNumCTE as(
 select *,
 Row_Number() over(
 Partition by ParcelID,
              PropertyAddress,      
			  SalePrice,
			  LegalReference
			  Order by
			  UniqueID
			  ) row_num

from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
---order by PropertyAddress


----------------------------------------------------------------------------------------------------------------------------------------------
---Delete Unused Columns

select * 
from NashvilleHousing

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
