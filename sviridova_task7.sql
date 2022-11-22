/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "07 - ������������ SQL".

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

��� ������� �� ������� "��������� CROSS APPLY, PIVOT, UNPIVOT."
����� ��� ���� �������� ������������ PIVOT, ������������ ���������� �� ���� ��������.
��� ������� ��������� ��������� �� ���� CustomerName.

��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.

���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.

������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (������ �������)
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
