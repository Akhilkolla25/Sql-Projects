--Looking at Nashville Housing dataset for cleaning the data

Select *
From [sql project]..HousingData

--Changing SaleDate to Short Date format 

Alter table HousingData
Add SaleDateConverted date;

Update [sql project]..Housingdata
Set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted
From [sql project]..HousingData

--Cleaning Property Address data

Select *
From [sql project]..Housingdata
--Where PropertyAddress is Null
Order by ParcelID
	
--Checking if Corresponding ParcelID is matching with PropertyAddress 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From [sql project]..Housingdata a
Join [sql project]..Housingdata b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

--Populating the PropertyAddress column where it is null

Update a 
Set PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
From [sql project]..Housingdata a
Join [sql project]..Housingdata b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

--Splitting PropertyAddress as Address, City, State Using Substring

Select PropertyAddress
From [sql project]..Housingdata


Select
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as City
From [sql project]..Housingdata


Alter Table HousingData
Add PropertyAddressPart Nvarchar(255);

Update Housingdata
Set PropertyAddressPart = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table HousingData
Add PropertyCity Nvarchar(255);

Update Housingdata
Set PropertyCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


Select OwnerName,OwnerAddress
From [sql project]..Housingdata
--Where OwnerAddress = '1927  14TH AVE N, NASHVILLE, TN'
--Where OwnerName is Null and OwnerAddress is not Null
--Where OwnerName is not Null and OwnerAddress is Null

--Spliting OwnerAddress Using Parsename


Select
PARSENAME( Replace( OwnerAddress, ',','.'), 3)
, PARSENAME( Replace( OwnerAddress, ',','.'), 2)
, PARSENAME( Replace( OwnerAddress, ',','.'), 1)
From [sql project]..Housingdata


Alter Table Housingdata
Add OwnerAddressSplit Nvarchar(255),
OwnerCity Nvarchar(255),
OwnerState Nvarchar(255);

Update Housingdata
Set OwnerAddressSplit = PARSENAME( Replace( OwnerAddress, ',','.'), 3),
OwnerCity = PARSENAME( Replace( OwnerAddress, ',','.'), 2),
OwnerState = PARSENAME( Replace( OwnerAddress, ',','.'), 1)

--Change Y and N in SoldAsVacant Column to Yes or No


Select Distinct( SoldAsVacant), COUNT( SoldAsVacant)
From [sql project]..Housingdata
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
,	Case	When SoldAsVacant = 'Y' then 'Yes'
			When SoldAsVacant = 'N' then 'No'
			Else SoldAsVacant
			End
From [sql project]..Housingdata


Update Housingdata
Set SoldAsVacant = Case	When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant
						End

--Removing Duplicate Values

With RowNumCTE as(
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				Order by
					UniqueID
					) row_num

From [sql project]..Housingdata
)
--Delete
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Deleting Unused Columns

Alter Table [sql project]..Housingdata
Drop Column	 SaleDate

--Renaming the Converted Coloumns

Use [sql project]
Go
Exec sp_rename 'Housingdata.SaleDateConverted' , 'SaleDate', 'Column';
Exec sp_rename 'Housingdata.PropertyAddressPart' , 'PropertyAddress', 'Column';
Exec sp_rename 'Housingdata.OwnerAddressSplit' , 'OwnerAddress', 'Column';
Go