/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".
*/
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
SELECT 
	DATEPART(YEAR,ct.TransactionDate) AS YearTransactionDate,
	DATEPART(MONTH,ct.TransactionDate) AS MonthTransactionDate,
	AVG(ol.UnitPrice) AS AVG_Sales,
	SUM(ct.TransactionAmount) AS SUM_Sales
FROM
	Sales.Invoices i
	INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	INNER JOIN Sales.OrderLines ol ON i.OrderID = ol.OrderID
GROUP BY DATEPART(YEAR,ct.TransactionDate),
	 DATEPART(MONTH,ct.TransactionDate) 
ORDER BY 1,2
GO
/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	DATEPART(YEAR,ct.TransactionDate) AS YearTransactionDate,
	DATEPART(MONTH,ct.TransactionDate) AS MonthTransactionDate, 
	SUM(ct.TransactionAmount) AS SUM_Sales
FROM
	Sales.Invoices i
	INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	INNER JOIN Sales.OrderLines ol ON i.OrderID = ol.OrderID
GROUP BY DATEPART(YEAR,ct.TransactionDate),
	 DATEPART(MONTH,ct.TransactionDate) 
HAVING SUM(ct.TransactionAmount) > 4600000
ORDER BY 1,2
GO
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	DATEPART(YEAR,ct.TransactionDate) AS YearTransactionDate,
	DATEPART(MONTH,ct.TransactionDate) AS MonthTransactionDate, 
	si.StockItemName
	,SUM(ct.TransactionAmount) AS SUM_Sales
	,MIN(ct.TransactionDate) AS FirstTransactionDate
	,COUNT(il.Quantity) AS COUNT_Quantity
FROM
	Sales.InvoiceLines il
	INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
	INNER JOIN Sales.CustomerTransactions ct ON il.InvoiceID = ct.InvoiceID
GROUP BY si.StockItemName,
	DATEPART(YEAR,ct.TransactionDate),
	DATEPART(MONTH,ct.TransactionDate) 	
HAVING COUNT(il.Quantity) < 50
ORDER BY 1,2
GO

 