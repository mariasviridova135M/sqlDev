/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "06 - ������� �������".

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
1. ������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� 
(� ������ ������ ������ �� ����� ����������, ��������� ����� � ������� ������� �������).
��������: id �������, �������� �������, ���� �������, ����� �������, ����� ����������� ������

������:
-------------+----------------------------
���� ������� | ����������� ���� �� ������
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
������� ����� ����� �� ������� Invoices.
����������� ���� ������ ���� ��� ������� �������.
*/
SELECT i.InvoiceID
	,c.CustomerName
	,i.InvoiceDate
	,ct.TransactionAmount
	,(
		SELECT SUM(ct1.TransactionAmount)
		FROM Sales.Invoices i1
		INNER JOIN Sales.CustomerTransactions ct1 ON i1.InvoiceID = ct1.InvoiceID
		INNER JOIN Sales.Customers c1 ON i1.CustomerID = c1.CustomerID
		WHERE c1.CustomerID = c.CustomerID
			--AND i1.InvoiceID <= i.InvoiceID
			AND month(ct1.TransactionDate) = month(ct.TransactionDate)
			AND year(ct1.TransactionDate) = year(ct.TransactionDate)
			AND year(ct1.TransactionDate) >= 2015
		GROUP BY c1.CustomerID
		) AS [RunningTotal]
FROM Sales.Invoices i
INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
WHERE year(ct.TransactionDate) >= 2015
ORDER BY c.CustomerName
	,i.InvoiceID ASC;
GO

/*
2. �������� ������ ����� ����������� ������ � ���������� ������� � ������� ������� �������.
   �������� ������������������ �������� 1 � 2 � ������� set statistics time, io on
*/
SELECT i.InvoiceID
	,c.CustomerName
	,i.InvoiceDate
	,ct.TransactionAmount
	,SUM(ct.TransactionAmount) OVER (
		PARTITION BY year(ct.TransactionDate)
		,month(ct.TransactionDate)
		,i.CustomerID
		) AS [RunningTotal]
FROM Sales.Invoices i
INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
WHERE year(ct.TransactionDate) >= 2015
ORDER BY c.CustomerName;
GO

----------------------------------��� ������� ��������---------------------------------------------------------
SET STATISTICS TIME ON;

SELECT i.InvoiceID
	,c.CustomerName
	,i.InvoiceDate
	,ct.TransactionAmount
	,(
		SELECT SUM(ct1.TransactionAmount)
		FROM Sales.Invoices i1
		INNER JOIN Sales.CustomerTransactions ct1 ON i1.InvoiceID = ct1.InvoiceID
		INNER JOIN Sales.Customers c1 ON i1.CustomerID = c1.CustomerID
		WHERE c1.CustomerID = c.CustomerID
			--AND i1.InvoiceID <= i.InvoiceID
			AND month(ct1.TransactionDate) = month(ct.TransactionDate)
			AND year(ct1.TransactionDate) = year(ct.TransactionDate)
			AND year(ct1.TransactionDate) >= 2015
		GROUP BY c1.CustomerID
		) AS [RunningTotal]
FROM Sales.Invoices i
INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
WHERE year(ct.TransactionDate) >= 2015
ORDER BY c.CustomerName
	,i.InvoiceID ASC;

SET STATISTICS TIME OFF;
----------------------------------� ������� ��������---------------------------------------------------------
SET STATISTICS TIME ON;

SELECT i.InvoiceID
	,c.CustomerName
	,i.InvoiceDate
	,ct.TransactionAmount
	,SUM(ct.TransactionAmount) OVER (
		PARTITION BY year(ct.TransactionDate)
		,month(ct.TransactionDate)
		,i.CustomerID
		) AS [RunningTotal]
FROM Sales.Invoices i
INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
WHERE year(ct.TransactionDate) >= 2015
ORDER BY c.CustomerName;

SET STATISTICS TIME OFF;

--���������: � ������� �������� �������� �������
--����������:
----------------------------------��� ������� ��������---------------------------------------------------------
/*
(��������� �����: 31440)

 ����� ������ SQL Server:
   ����� �� = 95921 ��, ����������� ����� = 96087 ��.
*/
----------------------------------� ������� ��������---------------------------------------------------------
/*
(��������� �����: 31440)

 ����� ������ SQL Server:
   ����� �� = 406 ��, ����������� ����� = 954 ��.
 */
/*
3. ������� ������ 2� ����� ���������� ��������� (�� ���������� ���������) 
� ������ ������ �� 2016 ��� (�� 2 ����� ���������� �������� � ������ ������).
*/
SELECT b.Month
	,b.StockItemName
	,b.Quantity
FROM (
	SELECT a.*
		,row_number() OVER (
			PARTITION BY a.Month ORDER BY a.[Quantity] DESC
			) AS [CountInvoice]
	FROM (
		SELECT DISTINCT month(ct.TransactionDate) AS [Month]
			,si.StockItemName
			,SUM(il.Quantity) OVER (
				PARTITION BY month(ct.TransactionDate)
				,si.StockItemName
				) AS [Quantity]
		FROM Sales.InvoiceLines il
		INNER JOIN Sales.CustomerTransactions ct ON il.InvoiceID = ct.InvoiceID
		INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
		WHERE year(ct.TransactionDate) = 2016
		) a
	) b
WHERE [CountInvoice] <= 2
ORDER BY b.Month ASC
	,b.Quantity DESC;
GO

/*
4. ������� ����� ��������
���������� �� ������� ������� (� ����� ����� ������ ������� �� ������, ��������, ����� � ����):
1 ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
2 ���������� ����� ���������� ������� � �������� ����� � ���� �� �������
3 ���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
4 ���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
5 ���������� �� ������ � ��� �� �������� ����������� (�� �����)
6 �������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
7 ����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��

��� ���� ������ �� ����� ������ ������ ��� ������������� �������.
*/
--1 ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
SELECT row_number() OVER (
		PARTITION BY left(StockItemName, 1) ORDER BY StockItemName ASC
		) AS [� by Letter]
	,StockItemID
	,StockItemName
	,Brand
	,UnitPrice
FROM Warehouse.StockItems;

--2 ���������� ����� ���������� ������� � �������� ����� � ���� �� �������
SELECT row_number() OVER (
		PARTITION BY left(StockItemName, 1) ORDER BY StockItemName ASC
		) AS [� by Letter]
	,SI.StockItemID
	,StockItemName
	,Brand
	,UnitPrice
	,SUM(sih.QuantityOnHand) OVER (PARTITION BY si.StockItemName) AS [QuantityStockItem]
FROM Warehouse.StockItems si
INNER JOIN Warehouse.StockItemHoldings sih ON si.StockItemID = sih.StockItemID;

--3 ���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
SELECT DISTINCT left(si.StockItemName, 1)
	,SUM(sih.QuantityOnHand) OVER (
		PARTITION BY left(si.StockItemName, 1) ORDER BY left(si.StockItemName, 1) ASC
		) AS [CountStockItem]
FROM Warehouse.StockItems si
INNER JOIN Warehouse.StockItemHoldings sih ON si.StockItemID = sih.StockItemID;

--4 ���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
SELECT SI.StockItemID
	,si.StockItemName
	,lead(si.StockItemID) OVER (
		ORDER BY si.StockItemName
		) AS [NextStockItemName]
FROM Warehouse.StockItems si

--5 ���������� �� ������ � ��� �� �������� ����������� (�� �����)
SELECT SI.StockItemID
	,si.StockItemName
	,lag(si.StockItemID) OVER (
		ORDER BY si.StockItemName
		) AS [PreviousStockItemID]
FROM Warehouse.StockItems si

--6 �������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
SELECT SI.StockItemID
	,si.StockItemName
	,isnull(lag(si.StockItemName, 2) OVER (
			ORDER BY si.StockItemName
			), 'No items') AS [2PreviousStockItemName]
FROM Warehouse.StockItems si;

--7 ����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
SELECT SI.StockItemID
	,si.StockItemName
	,si.TypicalWeightPerUnit
	,ntile(30) OVER (
		ORDER BY si.TypicalWeightPerUnit
		) AS [TypicalWeightGroup]
FROM Warehouse.StockItems si;

/*
5. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������.
   � ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������.
*/
SELECT pp.SalespersonPersonID
	,pp.FullName
	,c.CustomerID
	,c.CustomerName
	,ct.TransactionDate
	,ct.TransactionAmount
FROM (
	SELECT DISTINCT o.SalespersonPersonID
		,p.FullName
		,max(ct.CustomerTransactionID) OVER (PARTITION BY o.SalespersonPersonID) AS [CustomerTransactionID]
	FROM Application.People p
	INNER JOIN Sales.Orders o ON p.PersonID = o.SalespersonPersonID
	INNER JOIN Sales.Invoices i ON o.OrderID = i.OrderID
	INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	) pp
INNER JOIN Sales.CustomerTransactions ct ON pp.CustomerTransactionID = ct.CustomerTransactionID
INNER JOIN Sales.Invoices i ON ct.InvoiceID = i.InvoiceID
INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
ORDER BY pp.SalespersonPersonID;
GO

/*
6. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/
SELECT DISTINCT a.CustomerID
	,a.CustomerName
	,a.StockItemID
	,a.UnitPrice
	,a.TransactionDate
FROM (
	SELECT c.CustomerID
		,c.CustomerName
		,si.StockItemID
		,si.UnitPrice
		,max(ct.TransactionDate) OVER (
			PARTITION BY c.CustomerID
			,si.StockItemID
			) AS [TransactionDate]
		,dense_rank() OVER (
			PARTITION BY c.CustomerID ORDER BY si.UnitPrice DESC
			) AS [CoutInvoices]
	FROM Sales.Orders o
	INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
	INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
	INNER JOIN Sales.Invoices i ON o.OrderID = i.OrderID
	INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	INNER JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
	) a
WHERE a.CoutInvoices <= 2
ORDER BY a.CustomerID ASC
	,a.UnitPrice DESC;
