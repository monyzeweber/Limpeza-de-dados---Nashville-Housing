-- Limpeza de dados com SQL

SELECT * FROM nashville

--------------------------------------------------------------------------------

-- Padronizando o formato da data

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM nashville

UPDATE nashville
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE nashville
ADD DataConvertida date;

UPDATE nashville
SET DataConvertida = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------

-- Populando o 'Propery Adress' (Endereço da Propriedade)

SELECT PropertyAddress
FROM nashville
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Caso encontre o PropertyAdress nulo, substituir pelo valor correspondente na coluna b:

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Fazendo o update:

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT PropertyAddress
FROM nashville
WHERE PropertyAddress IS NULL

-- verificando se deu certo, se não há mais valores nulos:

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Divindo a coluna de Endereço em (Endereço, Cidade, Estado)

SELECT PropertyAddress
FROM nashville

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Endereço,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Cidade

FROM nashville

-- Criar duas colunas para colocar os valores:

ALTER TABLE nashville
ADD EnderecoConvertida nvarchar(255);

UPDATE nashville
SET EnderecoConvertida = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE nashville
ADD NomeCidadeDividida nvarchar(225);

UPDATE nashville
SET NomeCidadeDividida = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 


SELECT * FROM nashville

-- Fazendo o mesmo com o endereço do dono do imóvel mas usando a função PARSENAME
-- Utilização da função replace para substituir as vírgulas por ponto, pois o PARSENAME tem como separador o ponto

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM nashville

-- Colocando em colunas:

ALTER TABLE nashville
ADD EnderecoDonoDividida nvarchar(255);

UPDATE nashville
SET EnderecoDonoDividida = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashville
ADD CidadeDonoDividida nvarchar(255);

UPDATE nashville
SET CidadeDonoDividida = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

ALTER TABLE nashville
ADD EstadoDonoDividida nvarchar(255);

UPDATE nashville
SET EstadoDonoDividida = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT TOP(100) * FROM nashville

--Mudando o Y e N para Sim e Não no campo 'Sold in Vacant'

SELECT DISTINCT (SoldAsVacant),
COUNT(*)
FROM nashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM nashville

UPDATE nashville	
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END 
FROM nashville


-- Removendo Duplicadas

-- Utilizando ctes e windows functions para achar onde estão os valores duplicados:

WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelID, 
								PropertyAddress, 
								SalePrice, 
								SaleDate, 
								LegalReference 
								ORDER BY 
								UniqueID) row_num

FROM nashville
--ORDER BY ParcelID
)

SELECT * FROM RowNumCTE
where row_num > 1
order by PropertyAddress

-- Deletando as linhas duplicadas:
 
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Deletando colunas não utilizadas

SELECT * 
FROM nashville

ALTER TABLE nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
