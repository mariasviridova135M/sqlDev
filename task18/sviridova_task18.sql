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
--3619
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
--���������������� ������---
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

 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.

 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.

(��������� �����: 3619)
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 331, lob ���������� ������ 0, lob ����������� ������ 0.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 881, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 462, ���������� ������ 162058, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 296 ��, ����������� ����� = 445 ��.

����� ����������: 2023-02-02T21:56:09.6470137+03:00
   */