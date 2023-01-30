--==========================================
--�������� ������---
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

 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.

(��������� �����: 3619)
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 29, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 331, lob ���������� ������ 0, lob ����������� ������ 0.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 261, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 883, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 1, ���������� ������ 44525, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

(��������� ���� ������)

 ����� ������ SQL Server:
   ����� �� = 907 ��, ����������� ����� = 1536 ��.

����� ����������: 2023-01-30T18:11:55.3296194+03:00

*/

--==========================================
--������������� DMV, ������ � ������ ---
--==========================================
SET STATISTICS TIME ON
SET STATISTICS IO ON

SET NOCOUNT OFF

SELECT ord.CustomerID,
       det.StockItemID,
       SUM(det.UnitPrice),
       SUM(det.Quantity),
       COUNT(ord.OrderID)
FROM Sales.Orders AS ord
INNER JOIN Sales.OrderLines AS det WITH (NOLOCK) ON det.OrderID = ord.OrderID
INNER JOIN Sales.Invoices AS Inv WITH (NOLOCK) ON Inv.OrderID = ord.OrderID
INNER JOIN Sales.CustomerTransactions AS Trans WITH (NOLOCK) ON Trans.InvoiceID = Inv.InvoiceID
INNER JOIN Warehouse.StockItemTransactions AS ItemTrans WITH (NOLOCK) ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND
    (SELECT SupplierId
     FROM Warehouse.StockItems AS It WITH (NOLOCK)
     WHERE It.StockItemID = det.StockItemID) = 12
  AND
    (SELECT SUM(Total.UnitPrice*Total.Quantity)
     FROM Sales.OrderLines AS Total WITH (NOLOCK)
     INNER JOIN Sales.Orders AS ordTotal WITH (NOLOCK) ON ordTotal.OrderID = Total.OrderID
     WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
  AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID,
         det.StockItemID
ORDER BY ord.CustomerID,
         det.StockItemID

OPTION (MAXDOP 2);

SET STATISTICS TIME OFF 
SET STATISTICS IO OFF

 /*
  ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.

 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.

(��������� �����: 3619)
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 29, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 331, lob ���������� ������ 0, lob ����������� ������ 0.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 258, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 882, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 1, ���������� ������ 44525, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 844 ��, ����������� ����� = 980 ��.

����� ����������: 2023-01-30T18:32:06.2416712+03:00
*/
--==========================================
--� ������ ����� ���������� ������---
--==========================================

SET STATISTICS TIME ON
SET STATISTICS IO ON

SET NOCOUNT OFF

SELECT ord.CustomerID,
       det.StockItemID,
       SUM(det.UnitPrice),
       SUM(det.Quantity),
       COUNT(ord.OrderID)
FROM Sales.Orders AS ord
INNER JOIN Sales.OrderLines AS det WITH (NOLOCK) ON det.OrderID = ord.OrderID
INNER JOIN Sales.Invoices AS Inv WITH (NOLOCK) ON Inv.OrderID = ord.OrderID
AND Inv.BillToCustomerID != ord.CustomerID
INNER JOIN Sales.CustomerTransactions AS Trans WITH (NOLOCK) ON Trans.InvoiceID = Inv.InvoiceID
INNER JOIN Warehouse.StockItemTransactions AS ItemTrans WITH (NOLOCK) ON ItemTrans.StockItemID = det.StockItemID
INNER JOIN Warehouse.StockItems AS It WITH (NOLOCK) ON It.StockItemID = det.StockItemID
WHERE It.SupplierId = 12
  AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
  AND Inv.CustomerID in
    (SELECT ordTotal.CustomerID
     FROM Sales.OrderLines AS Total WITH (NOLOCK)
     INNER JOIN Sales.Orders AS ordTotal WITH (NOLOCK) ON ordTotal.OrderID = Total.OrderID
     GROUP BY ordTotal.CustomerID
     HAVING SUM(Total.UnitPrice*Total.Quantity) > 250000)
GROUP BY ord.CustomerID,
         det.StockItemID
ORDER BY ord.CustomerID,
         det.StockItemID OPTION (MAXDOP 2);


SET STATISTICS TIME OFF
SET STATISTICS IO OFF

/*
 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.

 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.

(��������� �����: 3619)
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 29, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 331, lob ���������� ������ 0, lob ����������� ������ 0.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 258, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 882, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 462, ���������� ������ 162058, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 640 ��, ����������� ����� = 796 ��.

����� ����������: 2023-01-30T18:58:51.1614449+03:00

*/