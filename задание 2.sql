/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".
*/
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------
USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/
SELECT StockItemID
	,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%'
	OR StockItemName LIKE 'Animal%'
GO

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/
SELECT ps.SupplierID
	,ps.SupplierName
FROM Purchasing.Suppliers ps
LEFT OUTER JOIN Purchasing.PurchaseOrders ppo ON ps.SupplierID = ppo.SupplierID
WHERE ppo.PurchaseOrderID IS NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
SELECT DISTINCT so.OrderID
	,CONVERT(VARCHAR, OrderDate, 104) AS [дата заказа]
	,datename(month, sct.TransactionDate) AS [название месяца]
	,datepart(quarter, sct.TransactionDate) AS [номер квартала]
	,CASE 
		WHEN MONTH(sct.TransactionDate) IN (1,2,3,4)
			THEN 1
		WHEN MONTH(sct.TransactionDate) IN (5,6,7,8)
			THEN 2
		WHEN MONTH(sct.TransactionDate) IN (9,10,11,12)
			THEN 3
		END AS [треть года]
	,c.CustomerName AS [имя заказчика]
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
ORDER BY [номер квартала]
	,[треть года]
	,[дата заказа] ASC
GO

-- Вариант с постраничной выборкой
SELECT DISTINCT so.OrderID
	,CONVERT(VARCHAR, OrderDate, 104) AS [дата заказа]
	,datename(month, sct.TransactionDate) AS [название месяца]
	,datepart(quarter, sct.TransactionDate) AS [номер квартала]
	,CASE 
		WHEN MONTH(sct.TransactionDate) IN (1,2,3,4)
			THEN 1
		WHEN MONTH(sct.TransactionDate) IN (5,6,7,8)
			THEN 2
		WHEN MONTH(sct.TransactionDate) IN (9,10,11,12)
			THEN 3
		END AS [треть года]
	,c.CustomerName AS [имя заказчика]
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
ORDER BY [номер квартала]
	,[треть года]
	,[дата заказа] ASC 
	
OFFSET 1000 ROWS
FETCH NEXT 100 ROWS ONLY
GO

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
SELECT adm.DeliveryMethodName AS [способ доставки]
	,ppo.ExpectedDeliveryDate AS [дата доставки]
	,ps.SupplierName AS [имя поставщика]
	,ap.FullName AS [имя контактного лица принимавшего заказ]
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
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
SELECT TOP 10 sc.CustomerName AS [Customer Name]
	,ap.FullName AS [Salesperson Name]
FROM Sales.Orders AS so
LEFT OUTER JOIN Sales.Customers sc ON so.CustomerID = sc.CustomerID
LEFT OUTER JOIN Application.People ap ON so.SalespersonPersonID = ap.PersonID
ORDER BY so.OrderID DESC
GO

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
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


