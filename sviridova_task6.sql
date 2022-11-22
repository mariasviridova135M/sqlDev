/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------
USE WideWorldImporters

/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
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
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
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

----------------------------------без оконной функцией---------------------------------------------------------
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
----------------------------------с оконной функцией---------------------------------------------------------
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

--Сравнение: с оконной функцией работает быстрее
--Результаты:
----------------------------------без оконной функцией---------------------------------------------------------
/*
(затронуто строк: 31440)

 Время работы SQL Server:
   Время ЦП = 95921 мс, затраченное время = 96087 мс.
*/
----------------------------------с оконной функцией---------------------------------------------------------
/*
(затронуто строк: 31440)

 Время работы SQL Server:
   Время ЦП = 406 мс, затраченное время = 954 мс.
 */
/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
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
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
1 пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
2 посчитайте общее количество товаров и выведете полем в этом же запросе
3 посчитайте общее количество товаров в зависимости от первой буквы названия товара
4 отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
5 предыдущий ид товара с тем же порядком отображения (по имени)
6 названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
7 сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/
--1 пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
SELECT row_number() OVER (
		PARTITION BY left(StockItemName, 1) ORDER BY StockItemName ASC
		) AS [№ by Letter]
	,StockItemID
	,StockItemName
	,Brand
	,UnitPrice
FROM Warehouse.StockItems;

--2 посчитайте общее количество товаров и выведете полем в этом же запросе
SELECT row_number() OVER (
		PARTITION BY left(StockItemName, 1) ORDER BY StockItemName ASC
		) AS [№ by Letter]
	,SI.StockItemID
	,StockItemName
	,Brand
	,UnitPrice
	,SUM(sih.QuantityOnHand) OVER (PARTITION BY si.StockItemName) AS [QuantityStockItem]
FROM Warehouse.StockItems si
INNER JOIN Warehouse.StockItemHoldings sih ON si.StockItemID = sih.StockItemID;

--3 посчитайте общее количество товаров в зависимости от первой буквы названия товара
SELECT DISTINCT left(si.StockItemName, 1)
	,SUM(sih.QuantityOnHand) OVER (
		PARTITION BY left(si.StockItemName, 1) ORDER BY left(si.StockItemName, 1) ASC
		) AS [CountStockItem]
FROM Warehouse.StockItems si
INNER JOIN Warehouse.StockItemHoldings sih ON si.StockItemID = sih.StockItemID;

--4 отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
SELECT SI.StockItemID
	,si.StockItemName
	,lead(si.StockItemID) OVER (
		ORDER BY si.StockItemName
		) AS [NextStockItemName]
FROM Warehouse.StockItems si

--5 предыдущий ид товара с тем же порядком отображения (по имени)
SELECT SI.StockItemID
	,si.StockItemName
	,lag(si.StockItemID) OVER (
		ORDER BY si.StockItemName
		) AS [PreviousStockItemID]
FROM Warehouse.StockItems si

--6 названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
SELECT SI.StockItemID
	,si.StockItemName
	,isnull(lag(si.StockItemName, 2) OVER (
			ORDER BY si.StockItemName
			), 'No items') AS [2PreviousStockItemName]
FROM Warehouse.StockItems si;

--7 сформируйте 30 групп товаров по полю вес товара на 1 шт
SELECT SI.StockItemID
	,si.StockItemName
	,si.TypicalWeightPerUnit
	,ntile(30) OVER (
		ORDER BY si.TypicalWeightPerUnit
		) AS [TypicalWeightGroup]
FROM Warehouse.StockItems si;

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
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
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
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
