Select * 
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date format
Select SaleDateConverted, Convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate=Convert(Date, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;
Update NashvilleHousing
Set SaleDateConverted=Convert(Date, SaleDate)

--Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--Deleting the null values and assigning a logical value corresponding to its ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress= isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into individual columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

--Creating the structures we need
Select
Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
, Substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--Creating the columns and updating with the structures
Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
Set PropertySplitAddress=Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
Set PropertySplitCity=Substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

Select*
From PortfolioProject.dbo.NashvilleHousing

--Let's split OwnerAddress by ParseName
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
Parsename(Replace(OwnerAddress,',','.'),3)
,Parsename(Replace(OwnerAddress,',','.'),2)
,Parsename(Replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

--Add columns and the structures

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
Set OwnerSplitAddress=Parsename(Replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
Set OwnerSplitCity=Parsename(Replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
Set OwnerSplitState=Parsename(Replace(OwnerAddress,',','.'),1)

Select*
From PortfolioProject.dbo.NashvilleHousing

--Change Y and N to Yes and No in Sold as Vacant Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--Creating a key statement to understand and select Yes and No

Select SoldAsVacant
, Case when SoldAsVacant= 'Y' Then 'Yes'
       when SoldAsVacant= 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant= 'Y' Then 'Yes'
       when SoldAsVacant= 'N' Then 'No'
	   Else SoldAsVacant
	   End

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)

--Order by ParcelID
Select *
From RowNumCTE
Where row_num >1
--Order by PropertyAddress

--Delete Unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate

