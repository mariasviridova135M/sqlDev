--==========================================
--ИСХОДНЫЙ ЗАПРОС---
--==========================================
SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT ord.CustomerID,
       det.StockItemID,
       SUM(det.UnitPrice),
       SUM(det.Quantity),
       COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND
    (SELECT SupplierId
     FROM Warehouse.StockItems AS It
     WHERE It.StockItemID = det.StockItemID) = 12
  AND
    (SELECT SUM(Total.UnitPrice*Total.Quantity)
     FROM Sales.OrderLines AS Total
     JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
     WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
  AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID,
         det.StockItemID
ORDER BY ord.CustomerID,
         det.StockItemID

SET STATISTICS TIME OFF 
SET STATISTICS IO OFF

/*
--3619
 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

(затронуто строк: 3619)
Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 29, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "OrderLines". Считано сегментов 2, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Orders". Число просмотров 2, логических чтений 883, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 1, логических чтений 44525, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

(затронута одна строка)

 Время работы SQL Server:
   Время ЦП = 907 мс, затраченное время = 1536 мс.

Время выполнения: 2023-01-30T18:11:55.3296194+03:00

*/
--==========================================
--ОПТИМИЗИРОВАННЫЙ ЗАПРОС---
--==========================================
CREATE INDEX IX_Warehouse_StockItems_SupplierId ON Warehouse.StockItems (SupplierId);
CREATE INDEX IX_Sales_Invoices_BillToCustomerID ON Sales.Invoices  (BillToCustomerID);
--CREATE INDEX IX_Sales_Invoices_CustomerID ON Sales.Invoices  (CustomerID);

SET STATISTICS TIME ON
SET STATISTICS IO ON
SET NOCOUNT OFF;

WITH CTECustomerID (tid) AS
  (SELECT DISTINCT ordTotal.CustomerID
   FROM Sales.OrderLines AS Total WITH (NOLOCK)
   INNER JOIN Sales.Orders AS ordTotal WITH (NOLOCK) ON ordTotal.OrderID = Total.OrderID
   GROUP BY ordTotal.CustomerID
   HAVING SUM(Total.UnitPrice*Total.Quantity) > 250000
   )

SELECT ord.CustomerID,
       det.StockItemID,
       SUM(det.UnitPrice) AS sumPrice,
       SUM(det.Quantity) AS sumQuantity,
       COUNT(ord.OrderID) AS countOrder
FROM Sales.Orders AS ord WITH (NOLOCK)
INNER JOIN Sales.OrderLines AS det WITH (NOLOCK) ON det.OrderID = ord.OrderID
INNER JOIN Sales.Invoices AS Inv WITH (NOLOCK) ON Inv.OrderID = ord.OrderID
INNER JOIN CTECustomerID AS CTE WITH (NOLOCK) ON CTE.tid = Inv.CustomerID
INNER JOIN Warehouse.StockItems AS It WITH (NOLOCK) ON It.StockItemID = det.StockItemID
WHERE  Inv.BillToCustomerID != ord.CustomerID
  AND Inv.InvoiceDate = ord.OrderDate
  AND It.SupplierId = 12
GROUP BY ord.CustomerID,
         det.StockItemID  
ORDER BY ord.CustomerID,
         det.StockItemID

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

/*

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

(затронуто строк: 3619)
Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "OrderLines". Считано сегментов 2, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Orders". Число просмотров 2, логических чтений 881, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 462, логических чтений 162058, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 296 мс, затраченное время = 445 мс.

Время выполнения: 2023-02-02T21:56:09.6470137+03:00
   */
