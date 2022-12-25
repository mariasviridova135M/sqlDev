/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "10 - ��������� ��������� ������".

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
use WideWorldImporters

/*
1. ����������� � ���� ���� ������� ��������� insert � ������� Customers ��� Suppliers 
*/
declare @tempCustomers table (tid int);

insert into Sales.Customers (
	CustomerID,
	CustomerName,
	BillToCustomerID,
	CustomerCategoryID,
	BuyingGroupID,
	PrimaryContactPersonID,
	AlternateContactPersonID,
	DeliveryMethodID,
	DeliveryCityID,
	PostalCityID,
	CreditLimit,
	AccountOpenedDate,
	StandardDiscountPercentage,
	IsStatementSent,
	IsOnCreditHold,
	PaymentDays,
	PhoneNumber,
	FaxNumber,
	DeliveryRun,
	RunPosition,
	WebsiteURL,
	DeliveryAddressLine1,
	DeliveryAddressLine2,
	DeliveryPostalCode,
	DeliveryLocation,
	PostalAddressLine1,
	PostalAddressLine2,
	PostalPostalCode,
	LastEditedBy,
	ValidFrom,
	ValidTo
	)
output inserted.CustomerID
into @tempCustomers
values (
	default,
	'Customer 1',
	1,
	3,
	1,
	1001,
	1002,
	3,
	19586,
	19586,
	null,
	'2022-01-01',
	0.000,
	0,
	0,
	7,
	'(308) 555-0100',
	'(308) 555-0101',
	'',
	'',
	'http://www.tailspintoys.com',
	'Shop100500',
	'Great Road',
	'90410',
	geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 100500',
	'Ribeiroville 100500',
	'90410',
	1,
	default,
	default
	),
	(
	default,
	'Customer 2',
	1,
	3,
	1,
	1001,
	1002,
	3,
	19586,
	19586,
	null,
	'2022-01-01',
	0.000,
	0,
	0,
	7,
	'(308) 555-0100',
	'(308) 555-0101',
	'',
	'',
	'http://www.tailspintoys.com',
	'Shop100500',
	'Great Road',
	'90410',
	geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 100500',
	'Ribeiroville 100500',
	'90410',
	1,
	default,
	default
	),
	(
	default,
	'Customer 3',
	1,
	3,
	1,
	1001,
	1002,
	3,
	19586,
	19586,
	null,
	'2022-01-01',
	0.000,
	0,
	0,
	7,
	'(308) 555-0100',
	'(308) 555-0101',
	'',
	'',
	'http://www.tailspintoys.com',
	'Shop100500',
	'Great Road',
	'90410',
	geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 100500',
	'Ribeiroville 100500',
	'90410',
	1,
	default,
	default
	),
	(
	default,
	'Customer 4',
	1,
	3,
	1,
	1001,
	1002,
	3,
	19586,
	19586,
	null,
	'2022-01-01',
	0.000,
	0,
	0,
	7,
	'(308) 555-0100',
	'(308) 555-0101',
	'',
	'',
	'http://www.tailspintoys.com',
	'Shop100500',
	'Great Road',
	'90410',
	geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 100500',
	'Ribeiroville 100500',
	'90410',
	1,
	default,
	default
	),
	(
	default,
	'Customer 5',
	1,
	3,
	1,
	1001,
	1002,
	3,
	19586,
	19586,
	null,
	'2022-01-01',
	0.000,
	0,
	0,
	7,
	'(308) 555-0100',
	'(308) 555-0101',
	'',
	'',
	'http://www.tailspintoys.com',
	'Shop100500',
	'Great Road',
	'90410',
	geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 100500',
	'Ribeiroville 100500',
	'90410',
	1,
	default,
	default
	)

select top 5 *
from Sales.Customers
order by CustomerID desc

/*
2. ������� ���� ������ �� Customers, ������� ���� ���� ���������
*/
delete
from Sales.Customers
where CustomerID = (
		select top 1 tid
		from @tempCustomers
		order by tid desc
		);

select top 5 *
from Sales.Customers
order by CustomerID desc

/*
3. �������� ���� ������, �� ����������� ����� UPDATE
*/
update sc
set CustomerName = 'Customer Name ' + CAST(sc.CustomerID as varchar)
from Sales.Customers sc
where sc.CustomerID = (
		select top 1 tid
		from @tempCustomers
		);

select top 5 *
from Sales.Customers
order by CustomerID desc

/*
4. �������� MERGE, ������� ������� ������� ������ � �������, ���� �� ��� ���, � ������� ���� ��� ��� ����
*/
declare @tempSalesCustomers table (
	DeletedID int,
	Action varchar(10),
	InsertedID int
	)

merge Sales.Customers as target
using (
	select top 1 *
	from Sales.Customers
	order by CustomerID desc
	) as source
	on (target.CustomerID = source.CustomerID)
when matched
	then
		update
		set CustomerName = 'CustomerUpdate'
when not matched
	then
		insert (
			CustomerID,
			CustomerName,
			BillToCustomerID,
			CustomerCategoryID,
			BuyingGroupID,
			PrimaryContactPersonID,
			AlternateContactPersonID,
			DeliveryMethodID,
			DeliveryCityID,
			PostalCityID,
			CreditLimit,
			AccountOpenedDate,
			StandardDiscountPercentage,
			IsStatementSent,
			IsOnCreditHold,
			PaymentDays,
			PhoneNumber,
			FaxNumber,
			DeliveryRun,
			RunPosition,
			WebsiteURL,
			DeliveryAddressLine1,
			DeliveryAddressLine2,
			DeliveryPostalCode,
			DeliveryLocation,
			PostalAddressLine1,
			PostalAddressLine2,
			PostalPostalCode,
			LastEditedBy,
			ValidFrom,
			ValidTo
			)
		values (
			default,
			'CustomerInsert',
			1,
			3,
			1,
			1001,
			1002,
			3,
			19586,
			19586,
			null,
			'2022-01-01',
			0.000,
			0,
			0,
			7,
			'(308) 555-0100',
			'(308) 555-0101',
			'',
			'',
			'http://www.tailspintoys.com',
			'Shop100500',
			'Great Road',
			'90410',
			geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
			'PO Box 100500',
			'Ribeiroville 100500',
			'90410',
			1,
			default,
			default
			)
output deleted.CustomerID,
	$action,
	inserted.CustomerID
into @tempSalesCustomers;

select *
from @tempSalesCustomers

select top 5 *
from Sales.Customers
order by CustomerID desc

--DELETE FROM Sales.Customers
--WHERE CustomerID IN (SELECT TOP 4 CustomerID
--FROM Sales.Customers
--ORDER BY CustomerID DESC)
/*
5. �������� ������, ������� �������� ������ ����� bcp out � ��������� ����� bulk insert
*/
exec sp_configure 'show advanced options',
	1;
go

reconfigure;
go

exec sp_configure 'xp_cmdshell',
	1;
go

reconfigure;
go

exec master..xp_cmdshell 'bcp "[WideWorldImporters].[Sales].[Customers]" out  "C:\work\SalesCustomers.txt" -T -w -t"@#$!"'

/*

==========================================================================================================================
													output
==========================================================================================================================

NULL
������ �����������...
SQLState = S1000, NativeError = 0
Error = [Microsoft][ODBC Driver 13 for SQL Server]Warning: BCP import with a format file will convert empty strings in delimited columns to NULL.
NULL
����������� �����: 667.
������ �������� ������ (� ������): 4096
����� (��) �����     : 47     � ������� : (14191.49 ����� � �������.)
NULL
*/
if OBJECT_ID('WideWorldImporters.Sales.NewCustomers') is not null
begin
	drop table [Sales].[NewCustomers]
end
else
begin
	create table [Sales].[NewCustomers] (
		[CustomerID] [int] not null,
		[CustomerName] [nvarchar](100) not null,
		[BillToCustomerID] [int] not null,
		[CustomerCategoryID] [int] not null,
		[BuyingGroupID] [int] null,
		[PrimaryContactPersonID] [int] not null,
		[AlternateContactPersonID] [int] null,
		[DeliveryMethodID] [int] not null,
		[DeliveryCityID] [int] not null,
		[PostalCityID] [int] not null,
		[CreditLimit] [decimal](18, 2) null,
		[AccountOpenedDate] [date] not null,
		[StandardDiscountPercentage] [decimal](18, 3) not null,
		[IsStatementSent] [bit] not null,
		[IsOnCreditHold] [bit] not null,
		[PaymentDays] [int] not null,
		[PhoneNumber] [nvarchar](20) not null,
		[FaxNumber] [nvarchar](20) not null,
		[DeliveryRun] [nvarchar](5) null,
		[RunPosition] [nvarchar](5) null,
		[WebsiteURL] [nvarchar](256) not null,
		[DeliveryAddressLine1] [nvarchar](60) not null,
		[DeliveryAddressLine2] [nvarchar](60) null,
		[DeliveryPostalCode] [nvarchar](10) not null,
		[DeliveryLocation] [geography] null,
		[PostalAddressLine1] [nvarchar](60) not null,
		[PostalAddressLine2] [nvarchar](60) null,
		[PostalPostalCode] [nvarchar](10) not null,
		[LastEditedBy] [int] not null,
		[ValidFrom] [datetime2](7) not null,
		[ValidTo] [datetime2](7) not null
		)
end

declare @path varchar(256),
	@query nvarchar(MAX),
	@dbname varchar(255),
	@batchsize int

select @dbname = DB_NAME();

set @batchsize = 1000;
set @path = 'C:\work\SalesCustomers.txt';

begin try
	set @query = 'BULK INSERT [' + @dbname + '].[Sales].[NewCustomers]
			FROM "' + @path + '"
			WITH 
				(
				BATCHSIZE = ' + CAST(@batchsize as varchar(255)) + ', 
				DATAFILETYPE = ''widechar'',
				FIELDTERMINATOR = ''@#$!'',
				ROWTERMINATOR =''\n'',
				KEEPNULLS,
				TABLOCK        
				);'

	exec sp_executesql @query

	select 'Success! ' + CAST(GETDATE() as varchar);
end try

begin catch
	select ERROR_NUMBER() as ErrorNumber,
		ERROR_MESSAGE() as ErrorMessage,
		GETDATE();
end catch

select *
from Sales.NewCustomers

drop table [Sales].[NewCustomers]
