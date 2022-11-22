/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "05 - ��������� CROSS APPLY, PIVOT, UNPIVOT".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/
-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------
USE WideWorldImporters

/*
1. ��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.

�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys.
��� ������� ����� �������� ��� ����� �������� ������ ���������.
��������, �������� �������� "Tailspin Toys (Gasport, NY)" - �� �������� ������ "Gasport, NY".
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.

������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
SELECT pvt.*
FROM (
	SELECT [OrderDate]
		,[CustomerName] = replace(replace([CustomerName], left([CustomerName], charindex('(', [CustomerName], 0)), ''), ')', '')
		,[OrderID]
	FROM [Sales].[Customers] c
	CROSS APPLY (
		SELECT [OrderDate] = CONVERT(VARCHAR, OrderDate, 104)
			,o.[OrderID]
		FROM [Sales].[Orders] o
		INNER JOIN [Sales].[Invoices] i ON o.[OrderID] = i.[OrderID]
		WHERE EXISTS (
				SELECT ct.[CustomerTransactionID]
				FROM [Sales].[CustomerTransactions] ct
				WHERE ct.[InvoiceID] = i.[InvoiceID]
				)
			AND c.[CustomerID] = o.[CustomerID]
		) oc
	WHERE c.[CustomerID] BETWEEN 2
			AND 6
	) AS sel
PIVOT(count([OrderID]) FOR [CustomerName] IN (
			[Peeples Valley, AZ]
			,[Medicine Lodge, KS]
			,[Gasport, NY]
			,[Sylvanite, MT]
			,[Jessie, ND]
			)) AS pvt
ORDER BY CAST(OrderDate AS DATE) ASC

/*
2. ��� ���� �������� � ������, � ������� ���� "Tailspin Toys"
������� ��� ������, ������� ���� � �������, � ����� �������.

������ ����������:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
SELECT CustomerName
	,UNpvt.[AddressLine]
FROM (
	SELECT [CustomerName]
		,[DeliveryAddressLine1]
		,[DeliveryAddressLine2]
		,[PostalAddressLine1]
		,[PostalAddressLine2]
	FROM [Sales].[Customers] c
	WHERE c.[CustomerName] LIKE 'Tailspin Toys%'
	) c
UNPIVOT([AddressLine] FOR [AddressType] IN (
			[DeliveryAddressLine1]
			,[DeliveryAddressLine2]
			,[PostalAddressLine1]
			,[PostalAddressLine2]
			)) UNpvt

/*
3. � ������� ����� (Application.Countries) ���� ���� � �������� ����� ������ � � ���������.
�������� ������� �� ������, �������� � �� ���� ���, 
����� � ���� � ����� ��� ���� �������� ���� ��������� ���.

������ ����������:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/
SELECT [CountryID]
	,[CountryName]
	,OA.[Code]
FROM [Application].[Countries] c
OUTER APPLY (
	SELECT CAST([IsoNumericCode] AS NVARCHAR(3)) AS [Code]
	FROM [Application].[Countries] c1
	WHERE c.[CountryID] = c1.[CountryID]
	
	UNION
	
	SELECT [IsoAlpha3Code] AS [Code]
	FROM [Application].[Countries] c1
	WHERE c.[CountryID] = c1.[CountryID]
	) OA
ORDER BY [CountryID]
	,[CountryName]
	,LEN(OA.[Code]) DESC

/*
4. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/
SELECT stockItem.CustomerID
	,stockItem.CustomerName
	,stockItem.StockItemID
	,stockItem.UnitPrice
	,orders.[TransactionDate]
FROM (
	SELECT c.CustomerID
		,c.CustomerName
		,a.StockItemID
		,a.UnitPrice
	FROM Sales.Customers c
	CROSS APPLY (
		SELECT DISTINCT TOP 2 si.StockItemID
			,si.UnitPrice
		FROM Sales.Orders o
		INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
		INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
		INNER JOIN Sales.Invoices i ON o.OrderID = i.OrderID
		WHERE c.CustomerID = o.CustomerID
			AND EXISTS (
				SELECT InvoiceID
				FROM Sales.CustomerTransactions ct1
				WHERE ct1.InvoiceID = i.InvoiceID
				)
		ORDER BY si.UnitPrice DESC
		) a
	) stockItem
CROSS APPLY (
	SELECT TOP 1 ct.TransactionDate
	FROM Sales.Orders o
	INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
	INNER JOIN Sales.Invoices i ON o.OrderID = i.OrderID
	INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	WHERE ol.StockItemID = stockItem.StockItemID
		AND o.CustomerID = stockItem.CustomerID
	ORDER BY ct.TransactionDate DESC
	) orders
ORDER BY CustomerID ASC
	,UnitPrice DESC;
