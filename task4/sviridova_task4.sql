/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "03 - ����������, CTE, ��������� �������".
*/
-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ��� ���� �������, ��� ��������, �������� ��� �������� ��������:
--  1) ����� ��������� ������
--  2) ����� WITH (��� ����������� ������)
-- ---------------------------------------------------------------------------
USE WideWorldImporters

/*
1. �������� ����������� (Application.People), ������� �������� ������������ (IsSalesPerson), 
� �� ������� �� ����� ������� 04 ���� 2015 ����. 
������� �� ���������� � ��� ������ ���. 
������� �������� � ������� Sales.Invoices.
*/
SELECT PersonID
	,FullName
FROM Application.People
WHERE IsSalesPerson = 1
	AND PersonID NOT IN (
		SELECT DISTINCT I.SalespersonPersonID
		FROM Sales.Invoices i
		INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
		INNER JOIN Sales.OrderLines ol ON i.OrderID = ol.OrderID
		WHERE DATEPART(YEAR, ct.TransactionDate) = 2015
			AND DATEPART(MONTH, ct.TransactionDate) = 7
			AND DATEPART(DAY, ct.TransactionDate) = 4
		)
GO

WITH cte
AS (
	SELECT DISTINCT SalespersonPersonID
	FROM Sales.Invoices i
	INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	INNER JOIN Sales.OrderLines ol ON i.OrderID = ol.OrderID
	--JOIN Application.People P ON P.PersonID = i.SalespersonPersonID
	WHERE DATEPART(YEAR, ct.TransactionDate) = 2015
		AND DATEPART(MONTH, ct.TransactionDate) = 7
		AND DATEPART(DAY, ct.TransactionDate) = 4
	)
SELECT PersonID
	,FullName
FROM cte AS c
RIGHT JOIN Application.People P ON P.PersonID = c.SalespersonPersonID
WHERE IsSalesPerson = 1
	AND SalespersonPersonID IS NULL
GO

/*
2. �������� ������ � ����������� ����� (�����������). �������� ��� �������� ����������. 
�������: �� ������, ������������ ������, ����.
*/
SELECT StockItemID
	,StockItemName
	,UnitPrice
FROM Warehouse.StockItems
WHERE UnitPrice = (
		SELECT min(UnitPrice) AS MIN_Price
		FROM Warehouse.StockItems
		)
GO

SELECT si.StockItemID
	,si.StockItemName
	,si.UnitPrice
FROM Warehouse.StockItems si
JOIN (
	SELECT min(UnitPrice) AS MIN_Price
	FROM Warehouse.StockItems
	) minPrice ON si.UnitPrice = minPrice.MIN_Price
GO

WITH cte
AS (
	SELECT min(UnitPrice) AS MIN_Price
	FROM Warehouse.StockItems SI
	)
SELECT StockItemID
	,StockItemName
	,UnitPrice
FROM cte AS c
JOIN Warehouse.StockItems AS SI ON si.UnitPrice = C.MIN_Price
GO

/*
3. �������� ���������� �� ��������, ������� �������� �������� ���� ������������ �������� 
�� Sales.CustomerTransactions. 
����������� ��������� �������� (� ��� ����� � CTE). 
*/
SELECT DISTINCT c.CustomerID
	,c.CustomerName
FROM (
	SELECT TOP 5 CustomerID
	FROM Sales.CustomerTransactions
	ORDER BY TransactionAmount DESC
	) a
INNER JOIN Sales.Customers c ON a.CustomerID = c.CustomerID;
GO

SELECT DISTINCT CustomerID
	,CustomerName
FROM Sales.Customers
WHERE CustomerID IN (
		SELECT TOP 5 CustomerID
		FROM Sales.CustomerTransactions
		ORDER BY TransactionAmount DESC
		);
GO

WITH cte
AS (
	SELECT TOP 5 CustomerID
	FROM Sales.CustomerTransactions
	ORDER BY TransactionAmount DESC
	)
SELECT DISTINCT c.CustomerID
	,c.CustomerName
FROM Sales.Customers c
JOIN cte t ON c.CustomerID = t.CustomerID
GO

/*
4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, 
�������� � ������ ����� ������� �������, � ����� ��� ����������, 
������� ����������� �������� ������� (PackedByPersonID).
*/
SELECT DISTINCT cts.CityID
	,cts.CityName
	,p.FullName
FROM (
	SELECT TOP 3 StockItemID
	FROM Warehouse.StockItems
	ORDER BY UnitPrice DESC
	) si
INNER JOIN Sales.OrderLines ol ON si.StockItemID = ol.StockItemID
INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
INNER JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Application.People p ON o.PickedByPersonID = p.PersonID
INNER JOIN Application.Cities cts ON c.DeliveryCityID = cts.CityID
WITH cte AS (
		SELECT TOP 3 StockItemID
		FROM Warehouse.StockItems
		ORDER BY UnitPrice DESC
		)

SELECT DISTINCT cts.CityID
	,cts.CityName
	,p.FullName
FROM CTE AS si
INNER JOIN Sales.OrderLines ol ON si.StockItemID = ol.StockItemID
INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
INNER JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Application.People p ON o.PickedByPersonID = p.PersonID
INNER JOIN Application.Cities cts ON c.DeliveryCityID = cts.CityID
GO

-- ---------------------------------------------------------------------------
-- ������������ �������
-- ---------------------------------------------------------------------------
-- ����� ��������� ��� � ������� ��������� ������������� �������, 
-- ��� � � ������� ��������� �����\���������. 
-- �������� ������������������ �������� ����� ����� SET STATISTICS IO, TIME ON. 
-- ���� ������� � ������� ��������, �� ����������� �� (����� � ������� ����� ��������� �����). 
-- �������� ���� ����������� �� ������ �����������. 
-- 5. ���������, ��� ������ � ������������� ������
SET STATISTICS TIME ON

SELECT Invoices.InvoiceID
	,Invoices.InvoiceDate
	,(
		SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
		) AS SalesPersonName
	,SalesTotals.TotalSumm AS TotalSummByInvoice
	,(
		SELECT SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (
				SELECT Orders.OrderId
				FROM Sales.Orders
				WHERE Orders.PickingCompletedWhen IS NOT NULL
					AND Orders.OrderId = Invoices.OrderId
				)
		) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN (
	SELECT InvoiceId
		,SUM(Quantity * UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity * UnitPrice) > 27000
	) AS SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

SET STATISTICS TIME OFF
/*
 ����� ������ SQL Server:
   ����� �� = 125 ��, ����������� ����� = 129 ��.
   */
-- --
/* 
���������� � �������� (����� InvoiceID � ���� InvoiceDate), �������� (SalesPersonName),
���������� ���������� (TotalSummByInvoice) � ����������� ���������� (TotalSummForPickedItems) 
�� ��������, ��� ����� ��������� 27000


����������� �� ����:
1. ��������� � �������  CTE
2. ��������� ����� �������
3. ��������� ���������� �������


*����� �������� ��������� - sviridova_task4_select1, sviridova_task4_select2
 */
SET STATISTICS TIME ON;

WITH InvoiceSum
AS (
	SELECT InvoiceId
		,SUM(Quantity * UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity * UnitPrice) > 27000
	)
SELECT i.InvoiceID
	,i.InvoiceDate
	,p.FullName AS SalesPersonName
	,cte.TotalSumm AS TotalSummByInvoice
	,ol.TotalSummForPickedItems
FROM InvoiceSum cte
INNER JOIN Sales.Invoices i ON cte.InvoiceID = i.InvoiceID
INNER JOIN (
	SELECT ol.OrderID
		,SUM(ol.PickedQuantity * ol.UnitPrice) AS TotalSummForPickedItems
	FROM Sales.Orders o
	INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
	WHERE o.PickingCompletedWhen IS NOT NULL
	GROUP BY ol.OrderID
	) ol ON i.OrderID = ol.OrderID
INNER JOIN Application.People p ON i.SalespersonPersonID = p.PersonID
ORDER BY TotalSumm DESC

SET STATISTICS TIME OFF;
	/*
 ����� ������ SQL Server:
   ����� �� = 125 ��, ����������� ����� = 119 ��.
*/
