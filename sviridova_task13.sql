/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters
 GO
/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
 
CREATE OR ALTER FUNCTION CustomerNameWithMaxSum  ()
RETURNS nvarchar(100)
AS
BEGIN 
	DECLARE @CustomerName nvarchar(100);

	SELECT top 1 @CustomerName = CustomerName
	FROM Sales.Orders so
	INNER JOIN Sales.Invoices si ON so.OrderID = si.OrderID
	INNER JOIN Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
	INNER JOIN Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
	INNER JOIN Sales.Customers c ON so.CustomerID = c.CustomerID
	GROUP BY  CustomerName
	ORDER BY SUM(TransactionAmount) DESC
	  
	RETURN @CustomerName

END
 GO
DECLARE @CustomerNameWithMaxSum nvarchar(100); 
SET @CustomerNameWithMaxSum = (SELECT [dbo].[CustomerNameWithMaxSum] ())
select @CustomerNameWithMaxSum
 GO
/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/


CREATE OR ALTER PROCEDURE SumAmountForCustomerName
	@CustomerName nvarchar(100),
	@TransactionAmount decimal(18,2) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @TransactionAmount = SUM(TransactionAmount)
	FROM Sales.Orders so
	INNER JOIN Sales.Invoices si ON so.OrderID = si.OrderID
	INNER JOIN Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
	INNER JOIN Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
	INNER JOIN Sales.Customers c ON so.CustomerID = c.CustomerID
	GROUP BY  CustomerName 
	HAVING CustomerName = @CustomerName
	ORDER BY SUM(TransactionAmount) DESC 

END
GO

 
DECLARE @AmountForCustomerName decimal(18,2),@CustomerName nvarchar(100); 

select @CustomerName = CustomerName 
from Sales.Customers
where CustomerName like '%Tailspin Toys (Inguadona, MN)%' 

exec SumAmountForCustomerName
@CustomerName = @CustomerName,
@TransactionAmount = @AmountForCustomerName OUTPUT

select @AmountForCustomerName
GO
/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

/*
Отобразить все месяцы, где общая сумма продаж превысила 4 600 000
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/ 
 
CREATE OR ALTER PROCEDURE SumAmountInvoices
	@Amount decimal(18,2)  
AS
BEGIN
	SELECT 
	DATEPART(YEAR,ct.TransactionDate) AS YearTransactionDate,
	DATEPART(MONTH,ct.TransactionDate) AS MonthTransactionDate, 
	SUM(ct.TransactionAmount) AS SUM_Sales
	FROM Sales.Invoices i
	INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	INNER JOIN Sales.OrderLines ol ON i.OrderID = ol.OrderID
	GROUP BY DATEPART(YEAR,ct.TransactionDate),
		DATEPART(MONTH,ct.TransactionDate) 
	HAVING SUM(ct.TransactionAmount) > @Amount
	ORDER BY YearTransactionDate, MonthTransactionDate

END
GO 

CREATE OR ALTER FUNCTION  fn_SumAmountInvoices 
(	
	@Amount decimal(18,2)
)
RETURNS TABLE 
AS
RETURN 
(
	 SELECT 
	DATEPART(YEAR,ct.TransactionDate) AS YearTransactionDate,
	DATEPART(MONTH,ct.TransactionDate) AS MonthTransactionDate, 
	SUM(ct.TransactionAmount) AS SUM_Sales
	FROM Sales.Invoices i
	INNER JOIN Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	INNER JOIN Sales.OrderLines ol ON i.OrderID = ol.OrderID
	GROUP BY DATEPART(YEAR,ct.TransactionDate),
		DATEPART(MONTH,ct.TransactionDate) 
	HAVING SUM(ct.TransactionAmount) > @Amount 
)
GO

SET STATISTICS TIME ON
DECLARE @Amount DECIMAL(18,2) = 4600000
SELECT * FROM fn_SumAmountInvoices (@Amount)
ORDER BY YearTransactionDate, MonthTransactionDate
SET STATISTICS TIME OFF
GO
/*
 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 5 мс.

(затронуто строк: 41)

 Время работы SQL Server:
   Время ЦП = 94 мс, затраченное время = 121 мс.

Время выполнения: 2022-12-28T21:55:02.0978524+03:00
*/
 
SET STATISTICS TIME ON
DECLARE @Amount DECIMAL(18,2) = 4600000
EXEC SumAmountInvoices @Amount = @Amount
SET STATISTICS TIME OFF
GO
/*
 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

(затронуто строк: 41)

 Время работы SQL Server:
   Время ЦП = 109 мс, затраченное время = 119 мс.

 Время работы SQL Server:
   Время ЦП = 109 мс, затраченное время = 119 мс.

*/

--Функции работают быстрее, потому что как только SQL видит BEGIN или END, система не может упростить содержимое.
--Хранимые процедуры предварительно скомпилированы. Оптимизатору не нужно каждый раз разрабатывать план выполнения.
--Оптимизатор может переписывать и оптимизировать запросы при использованием функций.

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
 
 
CREATE OR ALTER FUNCTION CustomerTotalAmount
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
   SELECT  SUM(TransactionAmount) as TotalAmount
	FROM Sales.Orders so
	INNER JOIN Sales.Invoices si ON so.OrderID = si.OrderID
	INNER JOIN Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
	INNER JOIN Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
	INNER JOIN Sales.Customers c ON so.CustomerID = c.CustomerID
	GROUP BY  c.CustomerID 
	HAVING c.CustomerID =  @CustomerID
)
GO
SELECT CustomerName, cta.TotalAmount
FROM Sales.Customers c
CROSS APPLY CustomerTotalAmount(c.CustomerID) AS cta

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
