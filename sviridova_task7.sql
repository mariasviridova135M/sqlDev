/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
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

-----------------------------------------------------------------
DECLARE @cols AS NVARCHAR(MAX) = '';
DECLARE @query AS NVARCHAR(MAX) = '';

SELECT @cols = @cols + + QUOTENAME(replace(replace([CustomerName], left([CustomerName], charindex('(', [CustomerName], 0)), ''), ')', '')) + ','
FROM [Sales].[Customers] c
WHERE c.[CustomerID] BETWEEN 2
		AND 6

SELECT @cols = substring(@cols, 0, len(@cols))

SET @query = 'SELECT pvt.*
FROM (
	SELECT [OrderDate]
		,[CustomerName] = replace(replace([CustomerName], left([CustomerName], charindex(''('', [CustomerName], 0)), ''''), '')'', '''')
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
) sel
pivot 
(
    count([OrderID]) FOR [CustomerName] IN (' + @cols + ')
) pvt
ORDER BY CAST(OrderDate AS DATE) ASC'

EXECUTE (@query)
