--cleaning data in SQL queries

select*
from NashvilleHousing


--Standardize Date Format
select NewSaleDate 
from NashvilleHousing

alter table NashvilleHousing
add NewSaleDate date;

update NashvilleHousing
set NewSaleDate = convert(Date,SaleDate) 

select*
from NashvilleHousing


--populate property address data


select PropertyAddress
from NashvilleHousing


--join to search about the missing addresses
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

--Replaceing the null with b.PropertyAddress

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

--	Breaking out address into individual columns( Address, City , State )

select PropertyAddress
from NashvilleHousing
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
from NashvilleHousing
-- creating the 2 new columns

Alter table NashvilleHousing
add StreetAddress nvarchar(255);

update NashvilleHousing
set StreetAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter table NashvilleHousing
add City nvarchar(255);

update NashvilleHousing
set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 


select OwnerAddress
from NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing

Alter table NashvilleHousing
add StreetOwnerAddress nvarchar(255);

update NashvilleHousing
set StreetOwnerAddress = PARSENAME(replace(OwnerAddress,',','.'),3)


Alter table NashvilleHousing
add OwnerAddressCity nvarchar(255);

update NashvilleHousing
set OwnerAddressCity = PARSENAME(replace(OwnerAddress,',','.'),2)


Alter table NashvilleHousing
add OwnerAddressState nvarchar(255);

update NashvilleHousing
set OwnerAddressState = PARSENAME(replace(OwnerAddress,',','.'),1)


--change Y and N To Yes and No in 'Sold As Vacant' field

select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N'then 'No'
else SoldAsVacant
end
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N'then 'No'
else SoldAsVacant
end


--Removing Duplicates      
SELECT DISTINCT *
FROM NashvilleHousing;

-- Find duplicates
SELECT
    ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    COUNT(*) AS cnt
FROM NashvilleHousing
GROUP BY
    ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate
HAVING COUNT(*) > 1;

-- Remove duplicates using ROW_NUMBER()

--VIEW duplicates
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
               ORDER BY UniqueID
           ) AS rn
    FROM NashvilleHousing
)
SELECT *
FROM CTE
WHERE rn > 1;

--DELETE duplicates

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
               ORDER BY UniqueID
           ) AS rn
    FROM NashvilleHousing
)
Delete
FROM CTE
WHERE rn > 1;

-- delete unused columns
select *
from NashvilleHousing

alter table NashvilleHousing
drop column owneraddress,taxdistrict,PropertyAddress,saledate







