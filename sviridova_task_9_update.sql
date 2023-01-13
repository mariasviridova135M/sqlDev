/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
use WideWorldImporters

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/
/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, ItemID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 
===================================================================================================================
Сделать два варианта: с помощью OPENXML и через XQuery.
===================================================================================================================
*/
-- ------------
-- OPEN XML
---------------
drop table if exists #tempStockItems;

create table #tempStockItems (
	[StockItemName] varchar(100) COLLATE Latin1_General_100_CI_AS,
	[SupplierID] int,
	[UnitPackageID] int,
	[OuterPackageID] int,
	[QuantityPerOuter] int,
	[TypicalWeightPerUnit] decimal(18, 3),
	[LeadTimeDays] int,
	[IsChillerStock] bit,
	[TaxRate] decimal(18, 2),
	[UnitPrice] decimal(18, 2)
	)

-- Переменная, в которую считаем XML-файл
declare @xmlStockItemsmlDocument xml;

-- Считываем XML-файл в переменную
select @xmlStockItemsmlDocument = BulkColumn
from OPENROWSET(bulk 'C:\work\StockItems.xml', SINGLE_CLOB) as data;

declare @docHandle int;

exec sp_xml_preparedocument @docHandle output,
	@xmlStockItemsmlDocument;

insert into #tempStockItems (
	[StockItemName],
	[SupplierID],
	[UnitPackageID],
	[OuterPackageID],
	[QuantityPerOuter],
	[TypicalWeightPerUnit],
	[LeadTimeDays],
	[IsChillerStock],
	[TaxRate],
	[UnitPrice]
	)
select [StockItemName],
	[SupplierID],
	[UnitPackageID],
	[OuterPackageID],
	[QuantityPerOuter],
	[TypicalWeightPerUnit],
	[LeadTimeDays],
	[IsChillerStock],
	[TaxRate],
	[UnitPrice]
from OPENXML(@docHandle, N'/StockItems/Item') with (
		[StockItemName] varchar(100) '@Name',
		[SupplierID] int 'SupplierID',
		[UnitPackageID] int 'Package/UnitPackageID',
		[OuterPackageID] int 'Package/OuterPackageID',
		[QuantityPerOuter] int 'Package/QuantityPerOuter',
		[TypicalWeightPerUnit] decimal(18, 3) 'Package/TypicalWeightPerUnit',
		[LeadTimeDays] int 'LeadTimeDays',
		[IsChillerStock] bit 'IsChillerStock',
		[TaxRate] decimal(18, 2) 'TaxRate',
		[UnitPrice] decimal(18, 2) 'UnitPrice'
		);

begin try
	USE  WideWorldImporters 
	MERGE  [Warehouse].[StockItems] AS target		 
	USING (
		SELECT [StockItemName] 
			,[SupplierID] 
			,[UnitPackageID]
			,[OuterPackageID]
			,[QuantityPerOuter]
			,[TypicalWeightPerUnit] 
			,[LeadTimeDays] 
			,[IsChillerStock] 
			,[TaxRate] 
			,[UnitPrice] 
		FROM #tempStockItems
	) AS source ([StockItemName], [SupplierID], [UnitPackageID], [OuterPackageID], [QuantityPerOuter], [TypicalWeightPerUnit], [LeadTimeDays], [IsChillerStock], [TaxRate], [UnitPrice])
	ON (target.[StockItemName] = source.[StockItemName])
	WHEN MATCHED
	THEN 
		UPDATE
		SET	target.[SupplierID] = source.[SupplierID]
			,target.[UnitPackageID] = source.[UnitPackageID]
			,target.[OuterPackageID] = source.[OuterPackageID]
			,target.[QuantityPerOuter] = source.[QuantityPerOuter]
			,target.[TypicalWeightPerUnit] = source.[TypicalWeightPerUnit]
			,target.[LeadTimeDays] = source.[LeadTimeDays]
			,target.[IsChillerStock] = source.[IsChillerStock]
			,target.[TaxRate] = source.[TaxRate]
			,target.[UnitPrice] = source.[UnitPrice]
	WHEN NOT MATCHED
	THEN 
		INSERT ( [StockItemName]
				,[SupplierID]
				,[UnitPackageID]
				,[OuterPackageID]
				,[QuantityPerOuter]
				,[TypicalWeightPerUnit]
				,[LeadTimeDays]
				,[IsChillerStock]
				,[TaxRate]
				,[UnitPrice]
				,[LastEditedBy]
			)
		VALUES ( source.[StockItemName]
				,source.[SupplierID]
				,source.[UnitPackageID]
				,source.[OuterPackageID]
				,source.[QuantityPerOuter]
				,source.[TypicalWeightPerUnit]
				,source.[LeadTimeDays]
				,source.[IsChillerStock]
				,source.[TaxRate]
				,source.[UnitPrice]
				,1
			);

	select GETDATE() as [Success!];
end try

begin catch
	select ERROR_NUMBER() as ErrorNumber,
		ERROR_MESSAGE() as ErrorMessage,
		GETDATE();
end catch

-- ----------------------
-- XQuery
-- ----------------------
declare @xmlStockItems xml;

set @xmlStockItems = (
		select *
		from OPENROWSET(bulk 'C:\work\StockItems.xml', SINGLE_BLOB) as d
		);

delete
from #tempStockItems

insert into #tempStockItems (
	[StockItemName],
	[SupplierID],
	[UnitPackageID],
	[OuterPackageID],
	[QuantityPerOuter],
	[TypicalWeightPerUnit],
	[LeadTimeDays],
	[IsChillerStock],
	[TaxRate],
	[UnitPrice]
	)
select [StockItemName] = xmlStock.Item.value('(@Name)', 'nvarchar(100)'),
	[SupplierID] = xmlStock.Item.value('(SupplierID[1])', 'int'),
	[UnitPackageID] = xmlStock.Item.value('(Package[1]/UnitPackageID[1])', 'int'),
	[OuterPackageID] = xmlStock.Item.value('(Package[1]/OuterPackageID[1])', 'int'),
	[QuantityPerOuter] = xmlStock.Item.value('(Package[1]/QuantityPerOuter[1])', 'int'),
	[TypicalWeightPerUnit] = xmlStock.Item.value('(Package[1]/TypicalWeightPerUnit[1])', 'decimal(18,3)'),
	[LeadTimeDays] = xmlStock.Item.value('(LeadTimeDays[1])', 'int'),
	[IsChillerStock] = xmlStock.Item.value('(IsChillerStock[1])', 'bit'),
	[TaxRate] = xmlStock.Item.value('(TaxRate[1])', 'decimal(18,3)'),
	[UnitPrice] = xmlStock.Item.value('(UnitPrice[1])', 'decimal(18,2)')
from @xmlStockItems.nodes('/StockItems/Item') as xmlStock(Item);

begin try
	USE  WideWorldImporters 
	MERGE  [Warehouse].[StockItems] AS target	
	USING (
		SELECT [StockItemName] 
			,[SupplierID] 
			,[UnitPackageID]
			,[OuterPackageID]
			,[QuantityPerOuter]
			,[TypicalWeightPerUnit] 
			,[LeadTimeDays] 
			,[IsChillerStock] 
			,[TaxRate] 
			,[UnitPrice] 
		FROM #tempStockItems
	) AS source ([StockItemName], [SupplierID], [UnitPackageID], [OuterPackageID], [QuantityPerOuter], [TypicalWeightPerUnit], [LeadTimeDays], [IsChillerStock], [TaxRate], [UnitPrice])
	ON (target.[StockItemName] = source.[StockItemName])
	WHEN MATCHED
	THEN 
		UPDATE
		SET	target.[SupplierID] = source.[SupplierID]
			,target.[UnitPackageID] = source.[UnitPackageID]
			,target.[OuterPackageID] = source.[OuterPackageID]
			,target.[QuantityPerOuter] = source.[QuantityPerOuter]
			,target.[TypicalWeightPerUnit] = source.[TypicalWeightPerUnit]
			,target.[LeadTimeDays] = source.[LeadTimeDays]
			,target.[IsChillerStock] = source.[IsChillerStock]
			,target.[TaxRate] = source.[TaxRate]
			,target.[UnitPrice] = source.[UnitPrice]
	WHEN NOT MATCHED
	THEN 
		INSERT ( [StockItemName]
				,[SupplierID]
				,[UnitPackageID]
				,[OuterPackageID]
				,[QuantityPerOuter]
				,[TypicalWeightPerUnit]
				,[LeadTimeDays]
				,[IsChillerStock]
				,[TaxRate]
				,[UnitPrice]
				,[LastEditedBy]
			)
		VALUES ( source.[StockItemName]
				,source.[SupplierID]
				,source.[UnitPackageID]
				,source.[OuterPackageID]
				,source.[QuantityPerOuter]
				,source.[TypicalWeightPerUnit]
				,source.[LeadTimeDays]
				,source.[IsChillerStock]
				,source.[TaxRate]
				,source.[UnitPrice]
				,1
			);
		
	select GETDATE() as [Success!];
end try

begin catch
	select ERROR_NUMBER() as ErrorNumber,
		ERROR_MESSAGE() as ErrorMessage,
		GETDATE();
end catch

drop table if exists #tempStockItems;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/
declare @queryStockItems nvarchar(max) = 'SELECT [@Name] = [StockItemName], [SupplierID],[Package] = (cast((SELECT [UnitPackageID], [OuterPackageID], [QuantityPerOuter], [TypicalWeightPerUnit] FROM [WideWorldImporters].[Warehouse].[StockItems] sip WHERE si.[StockItemID] = sip.[StockItemID] FOR XML PATH ('''''''')) as XML)),[LeadTimeDays],[IsChillerStock], [TaxRate], [UnitPrice] FROM [WideWorldImporters].[Warehouse].[StockItems] si FOR XML PATH (''''Item''''), ROOT (''''StockItems'''')';
declare @bcp nvarchar(max) = 'EXEC xp_cmdshell ''bcp "' + @queryStockItems + '" queryout "C:\work\NewStockItems.xml" -c -t -T''';

exec sp_executesql @bcp;

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/
select StockItemID,
	StockItemName,
	CustomFields,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') as [CountryOfManufacture],
	JSON_QUERY(CustomFields, '$.Tags')  as [Tags],
	JSON_VALUE(CustomFields, '$.Tags[0]')  as [CustomFields] 
from [Warehouse].[StockItems];

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/
select StockItemID,
	StockItemName,
	CustomFields,
	Tags
from [Warehouse].[StockItems] si
cross apply OPENJSON(CustomFields, '$.Tags') t
where Value = 'Vintage';
