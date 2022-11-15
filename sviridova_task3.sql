/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, GROUP BY, HAVING".
*/
-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��������� ������� ���� ������, ����� ����� ������� �� �������.
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����

������� �������� � ������� Sales.Invoices � ��������� ��������.
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
2. ���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000

�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������

������� �������� � ������� Sales.Invoices � ��������� ��������.
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
3. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.

�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������

������� �������� � ������� Sales.Invoices � ��������� ��������.
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

 