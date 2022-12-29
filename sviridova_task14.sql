/*
Цель:
В этом ДЗ вы научитесь:

использовать очередь
настраивать сервер для работы с очередями
писать скрипты для создания и настройки очереди

Описание/Пошаговая инструкция выполнения домашнего задания:
Создание очереди в БД для фоновой обработки задачи в БД.
Подумайте и реализуйте очередь в рамках своего проекта.
Если в вашем проекте нет задачи, которая подходит под реализацию через очередь, то в качестве ДЗ:
Реализуйте очередь для БД WideWorldImporters:

Создайте очередь для формирования отчетов для клиентов по таблице Invoices. При вызове процедуры для создания отчета в очередь должна отправляться заявка.
При обработке очереди создавайте отчет по количеству заказов (Orders) по клиенту за заданный период времени и складывайте готовый отчет в новую таблицу.
Проверьте, что вы корректно открываете и закрываете диалоги и у нас они не копятся.
*/ 

CREATE TABLE Sales.CountOrdersCustomers(
tid int identity(1,1),
countOrder int,
Customer_id int,
Invoice_id int,
OrderDate datetime,
RecordDate datetime default GETDATE())

ALTER TABLE Sales.Invoices
ADD InvoiceConfirmedForProcessing DATETIME;

------------------------------------------------------------------
--Queue
------------------------------------------------------------------

CREATE QUEUE TargetQueueWWI;

CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);
GO


CREATE QUEUE InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);
GO

------------------------------------------------------------------
---ServiceBrokerEnable
------------------------------------------------------------------


USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER  WITH NO_WAIT; 

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters to [DESKTOP-FJ9KEEQ\Maria] ;

------------------------------------------------------------------
---QueueStatus
------------------------------------------------------------------
USE [WideWorldImporters];

SELECT * FROM sys.service_contract_message_usages; 
SELECT * FROM sys.service_contract_usages;
SELECT * FROM sys.service_queue_usages;
 
SELECT * FROM sys.transmission_queue;

SELECT * 
FROM dbo.InitiatorQueueWWI;

SELECT * 
FROM dbo.TargetQueueWWI;

select name, is_broker_enabled
from sys.databases;

SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;

SELECT InvoiceConfirmedForProcessing, * 
FROM Sales.Invoices
WHERE InvoiceID = 61211;



------------------------------------------------------------------
---MessageType
------------------------------------------------------------------

--Create Message Types for Request and Reply messages
USE WideWorldImporters
-- For Request
CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML;
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

GO

CREATE CONTRACT [//WWI/SB/Contract]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );
GO
------------------------------------------------------------------
---SP_SendMessage
------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Sales.SendNewInvoice
	@invoiceId INT,
	@StartDate datetime,
	@FinishDate datetime
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	--Prepare the Message
	SELECT @RequestMessage = (SELECT  COUNt(ISNULL(so.OrderID,0)) as countOrderID, c.CustomerID, si.InvoiceID, so.OrderDate
								FROM Sales.Orders so
								LEFT JOIN Sales.Invoices si ON so.OrderID = si.OrderID
								LEFT JOIN Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
								LEFT JOIN Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
								LEFT JOIN Sales.Customers c ON so.CustomerID = c.CustomerID
								where si.InvoiceID = @invoiceId
								and so.OrderDate between @StartDate and @FinishDate
								GROUP BY   c.CustomerID, si.InvoiceID, so.OrderDate    
							  FOR XML AUTO, root('RequestMessage')); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	
	SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END
GO
------------------------------------------------------------------
---SP_ReplyMessage
------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Sales.GetNewInvoice
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@countOrderID INT,
			@Customer_id INT,
			@Invoice_id INT,
			@OrderDate datetime,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SELECT @Message;

	SET @xml = CAST(@Message AS XML);

	SELECT @countOrderID = R.c.value('@countOrderID','INT')
	FROM @xml.nodes('/RequestMessage/c') as R(c);

	SELECT @Customer_id = R.c.value('@Customer_id','INT')
	FROM @xml.nodes('/RequestMessage/c') as R(c);

	SELECT @Invoice_id = R.si.value('@Invoice_id','INT')
	FROM @xml.nodes('/RequestMessage/si') as R(si);

	SELECT @OrderDate = R.so.value('@OrderDate','INT')
	FROM @xml.nodes('/RequestMessage/so') as R(so);

	IF (@countOrderID > 0)
	BEGIN
		INSERT INTO Sales.CountOrdersCustomers (countOrder, Customer_id, Invoice_id, OrderDate, RecordDate)
		SELECT @countOrderID, @Customer_id, @Invoice_id, @OrderDate, getdate();
	END;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; 
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END
go
------------------------------------------------------------------
---SP_GetReplyMessage
------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Sales.ConfirmInvoice
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; 

	COMMIT TRAN; 
END
go
------------------------------------------------------------------
---AlterQueue
------------------------------------------------------------------
USE [WideWorldImporters]
GO
/****** Object:  ServiceQueue [InitiatorQueueWWI]    Script Date: 6/5/2019 11:57:47 PM ******/
ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = Sales.ConfirmInvoice, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = Sales.GetNewInvoice, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO

------------------------------------------------------------------
---ExecSP
------------------------------------------------------------------
SELECT InvoiceId, InvoiceConfirmedForProcessing, *
FROM Sales.Invoices
WHERE InvoiceID IN ( 61210,61211,61212,61213) ;

--Send message
EXEC Sales.SendNewInvoice
	@invoiceId = 61213,
	@startdate = '2013-01-01',
	@finishdate = '2020-01-01';

SELECT  COUNt(ISNULL(so.OrderID,0)) as countOrderID, c.CustomerID, si.InvoiceID, so.OrderDate
FROM Sales.Orders so
LEFT JOIN Sales.Invoices si ON so.OrderID = si.OrderID
LEFT JOIN Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
LEFT JOIN Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
LEFT JOIN Sales.Customers c ON so.CustomerID = c.CustomerID
where si.InvoiceID = 61213
and so.OrderDate between '2013-01-01' and '2020-01-01'
GROUP BY   c.CustomerID, si.InvoiceID, so.OrderDate  
FOR XML AUTO, root('RequestMessage')
 
SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueueWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueueWWI;

--Target
EXEC Sales.GetNewInvoice;

--Initiator
EXEC Sales.ConfirmInvoice;

SELECT * FROM Sales.CountOrdersCustomers

------------------------------------------------------------------
---CleanTransmissionQueue
------------------------------------------------------------------

SET NOCOUNT ON;

DECLARE @Conversation uniqueidentifier;

WHILE EXISTS(SELECT 1 FROM sys.transmission_queue)
BEGIN
  SET @Conversation = 
                (SELECT TOP(1) conversation_handle 
                                FROM sys.transmission_queue);
  END CONVERSATION @Conversation WITH CLEANUP;
END;

------------------------------------------------------------------
---RevokeChanges
------------------------------------------------------------------
 

DROP TABLe Sales.CountOrdersCustomers


ALTER TABLE Sales.Invoices 
DROP COLUMN InvoiceConfirmedForProcessing;

DROP SERVICE [//WWI/SB/TargetService]
GO

DROP SERVICE [//WWI/SB/InitiatorService]
GO

DROP SERVICE [//WWI//InitiatorService]
GO

DROP QUEUE [dbo].[TargetQueueWWI]
GO 

DROP QUEUE [dbo].[InitiatorQueueWWI]
GO

DROP CONTRACT [//WWI/SB/Contract]
GO

DROP MESSAGE TYPE [//WWI/SB/RequestMessage]
GO

DROP MESSAGE TYPE [//WWI/SB/ReplyMessage]
GO

DROP PROCEDURE IF EXISTS  Sales.SendNewInvoice;

DROP PROCEDURE IF EXISTS  Sales.GetNewInvoice;

DROP PROCEDURE IF EXISTS  Sales.ConfirmInvoice;
