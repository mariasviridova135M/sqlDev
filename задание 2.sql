/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, JOIN".
*/
-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------
USE WideWorldImporters

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/
SELECT StockItemID
	,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%'
	OR StockItemName LIKE 'Animal%'
GO

/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/
SELECT ps.SupplierID
	,ps.SupplierName
FROM Purchasing.Suppliers ps
LEFT OUTER JOIN Purchasing.PurchaseOrders ppo ON ps.SupplierID = ppo.SupplierID
WHERE ppo.PurchaseOrderID IS NULL

/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
SELECT DISTINCT so.OrderID
	,CONVERT(VARCHAR, OrderDate, 104) AS [���� ������]
	,datename(month, sct.TransactionDate) AS [�������� ������]
	,datepart(quarter, sct.TransactionDate) AS [����� ��������]
	,CASE 
		WHEN MONTH(sct.TransactionDate) IN (1,2,3,4)
			THEN 1
		WHEN MONTH(sct.TransactionDate) IN (5,6,7,8)
			THEN 2
		WHEN MONTH(sct.TransactionDate) IN (9,10,11,12)
			THEN 3
		END AS [����� ����]
	,c.CustomerName AS [��� ���������]
FROM Sales.Orders so
INNER JOIN Sales.Invoices si ON so.OrderID = si.OrderID
INNER JOIN Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
INNER JOIN Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
INNER JOIN Sales.Customers c ON so.CustomerID = c.CustomerID
WHERE (
		sil.UnitPrice > 100
		OR so.OrderID IN (
			SELECT dt.OrderID
			FROM (
				SELECT so.OrderID
					,count(sol.OrderLineID) AS [OrderLinesQuantity]
				FROM Sales.Orders so
				INNER JOIN Sales.OrderLines sol ON sol.OrderID = so.OrderID
				GROUP BY so.OrderID
				HAVING count(sol.OrderLineID) > 20
				) dt
			)
		)
	AND sct.TransactionDate IS NOT NULL
	AND so.PickingCompletedWhen IS NOT NULL
ORDER BY [����� ��������]
	,[����� ����]
	,[���� ������] ASC
GO

-- ������� � ������������ ��������
SELECT DISTINCT so.OrderID
	,CONVERT(VARCHAR, OrderDate, 104) AS [���� ������]
	,datename(month, sct.TransactionDate) AS [�������� ������]
	,datepart(quarter, sct.TransactionDate) AS [����� ��������]
	,CASE 
		WHEN MONTH(sct.TransactionDate) IN (1,2,3,4)
			THEN 1
		WHEN MONTH(sct.TransactionDate) IN (5,6,7,8)
			THEN 2
		WHEN MONTH(sct.TransactionDate) IN (9,10,11,12)
			THEN 3
		END AS [����� ����]
	,c.CustomerName AS [��� ���������]
FROM Sales.Orders so
INNER JOIN Sales.Invoices si ON so.OrderID = si.OrderID
INNER JOIN Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
INNER JOIN Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
INNER JOIN Sales.Customers c ON so.CustomerID = c.CustomerID
WHERE (
		sil.UnitPrice > 100
		OR so.OrderID IN (
			SELECT dt.OrderID
			FROM (
				SELECT so.OrderID
					,count(sol.OrderLineID) AS [OrderLinesQuantity]
				FROM Sales.Orders so
				INNER JOIN Sales.OrderLines sol ON sol.OrderID = so.OrderID
				GROUP BY so.OrderID
				HAVING count(sol.OrderLineID) > 20
				) dt
			)
		)
	AND sct.TransactionDate IS NOT NULL
	AND so.PickingCompletedWhen IS NOT NULL
ORDER BY [����� ��������]
	,[����� ����]
	,[���� ������] ASC 
	
OFFSET 1000 ROWS
FETCH NEXT 100 ROWS ONLY
GO

/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
SELECT adm.DeliveryMethodName AS [������ ��������]
	,ppo.ExpectedDeliveryDate AS [���� ��������]
	,ps.SupplierName AS [��� ����������]
	,ap.FullName AS [��� ����������� ���� ������������ �����]
FROM Purchasing.PurchaseOrders ppo
INNER JOIN Application.DeliveryMethods adm ON ppo.DeliveryMethodID = adm.DeliveryMethodID
LEFT OUTER JOIN Purchasing.Suppliers ps ON ppo.SupplierID = ps.SupplierID
LEFT OUTER JOIN Application.People ap ON ppo.ContactPersonID = ap.PersonID
WHERE ppo.ExpectedDeliveryDate BETWEEN '20130101'
		AND '20130131'
	AND ppo.IsOrderFinalized = 1
	AND adm.DeliveryMethodName IN (
		'Air Freight'
		,'Refrigerated Air Freight'
		)

/*
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/
SELECT TOP 10 sc.CustomerName AS [Customer Name]
	,ap.FullName AS [Salesperson Name]
FROM Sales.Orders AS so
LEFT OUTER JOIN Sales.Customers sc ON so.CustomerID = sc.CustomerID
LEFT OUTER JOIN Application.People ap ON so.SalespersonPersonID = ap.PersonID
ORDER BY so.OrderID DESC
GO

/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
*/
SELECT DISTINCT sc.CustomerID
	,sc.CustomerName
	,sc.PhoneNumber
FROM Warehouse.StockItems wsi
INNER JOIN Sales.OrderLines sol ON wsi.StockItemID = sol.StockItemID
INNER JOIN Sales.Orders so ON sol.OrderID = so.OrderID
INNER JOIN Sales.Customers sc ON sc.CustomerID = so.CustomerID
WHERE wsi.StockItemID = (
		SELECT StockItemID
		FROM Warehouse.StockItems
		WHERE StockItemName = 'Chocolate frogs 250g'
		)
GO


