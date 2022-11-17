/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".
*/
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------
USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
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
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
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
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
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
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
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
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 
-- 5. Объясните, что делает и оптимизируйте запрос
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
 Время работы SQL Server:
   Время ЦП = 125 мс, затраченное время = 129 мс.
   */
-- --
/* 
Информация о продажах (номер InvoiceID и дата InvoiceDate), продавце (SalesPersonName),
оплаченной стоимостью (TotalSummByInvoice) и отгруженной стоимостью (TotalSummForPickedItems) 
по позициях, где сумма превышает 27000


Оптимизация за счет:
1. ускорение с помощью  CTE
2. изменение плана запроса
3. повышение читаемости запроса


*планы запросов приложены - sviridova_task4_select1, sviridova_task4_select2
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
 Время работы SQL Server:
   Время ЦП = 125 мс, затраченное время = 119 мс.
*/
