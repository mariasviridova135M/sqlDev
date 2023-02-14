/*
����:
� ���� �� �� �������� �������-�������� ��� ��������������� � ��������� ��������� �����������������.

��������/��������� ���������� ���������� ��������� �������:
�������� � ����� ������� �������-�������� ��� ��������������� � ��������� �����������������.
���� � ������� ��� ����� �������, �� ������ ������ ���� ������ �� ������� ������, �������� ������� � ������ �� ���������������,
� ��������� ������ �� ������� (���������) - ������ �� ����, ��� ������� �������, ����� ������� �������� � ���������������� �������
*/

USE master
GO
--�������� �������� �����
ALTER DATABASE HelpDB
ADD FILEGROUP HelpDB_FG;
GO
ALTER DATABASE HelpDB
ADD FILE
(
 NAME = HelpDB_FG_1,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\HelpDB_FG_1.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
), 
( 
 NAME = HelpDB_FG_2,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\HelpDB_FG_2.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
) 
TO FILEGROUP HelpDB_FG;
GO


ALTER DATABASE HelpDB
ADD FILEGROUP HelpDB_FG_2;
GO
ALTER DATABASE HelpDB
ADD FILE
(
 NAME = HelpDB_FG_3,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\HelpDB_FG_3.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
), 
( 
 NAME = HelpDB_FG_4,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\HelpDB_FG_4.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
) 
TO FILEGROUP HelpDB_FG_2;
GO

ALTER DATABASE HelpDB
ADD FILEGROUP HelpDB_FG_3;
GO
ALTER DATABASE HelpDB
ADD FILE
(
 NAME = HelpDB_FG_5,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\HelpDB_FG_5.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
)
TO FILEGROUP HelpDB_FG_3;
GO


use HelpDB
--�������� ������ �� �������
SELECT    [tid]
    ,[tid_DataBase]
    ,[TotalVolume]
    ,[DataVolume]
    ,[LogVolume]
    ,[UsedDataVolume]
    ,[UsedLogVolume]
    ,[RecordDate]
FROM [HelpDB].[dbo].[UsedSpace]
 
--�������� �������
create  partition function fn_partition (datetime) as range
for values ('20221101', '20221201')

--�������� �����
create partition scheme parHELP -- ��� �����
as partition fn_partition -- ��� ������� ���������������
to ([HelpDB_FG], [HelpDB_FG_2], [HelpDB_FG_3]); -- ������������ �������� ����� ��� ������ ������

--���������� � �� 
SELECT name, physical_name,name
FROM sys.master_files
WHERE database_id = DB_ID('HelpDB');
GO

--��������
SELECT
    sc.name + N'.' + so.name as [Schema.Table],
    si.index_id as [Index ID],
    si.type_desc as [Structure],
    si.name as [Index],
    stat.row_count AS [Rows],
    stat.in_row_reserved_page_count * 8./1024./1024. as [In-Row GB],
    stat.lob_reserved_page_count * 8./1024./1024. as [LOB GB],
    p.partition_number AS [Partition #],
    pf.name as [Partition Function],
    CASE pf.boundary_value_on_right
        WHEN 1 then 'Right / Lower'
        ELSE 'Left / Upper'
    END as [Boundary Type],
    prv.value as [Boundary Point],
    fg.name as [Filegroup]
FROM sys.partition_functions AS pf
JOIN sys.partition_schemes as ps on ps.function_id=pf.function_id
JOIN sys.indexes as si on si.data_space_id=ps.data_space_id
JOIN sys.objects as so on si.object_id = so.object_id
JOIN sys.schemas as sc on so.schema_id = sc.schema_id
JOIN sys.partitions as p on 
    si.object_id=p.object_id 
    and si.index_id=p.index_id
LEFT JOIN sys.partition_range_values as prv on prv.function_id=pf.function_id
    and p.partition_number= 
        CASE pf.boundary_value_on_right WHEN 1
            THEN prv.boundary_id + 1
        ELSE prv.boundary_id
        END 
JOIN sys.dm_db_partition_stats as stat on stat.object_id=p.object_id
    and stat.index_id=p.index_id
    and stat.index_id=p.index_id and stat.partition_id=p.partition_id
    and stat.partition_number=p.partition_number
JOIN sys.allocation_units as au on au.container_id = p.hobt_id
    and au.type_desc ='IN_ROW_DATA'  
JOIN sys.filegroups as fg on fg.data_space_id = au.data_space_id
ORDER BY [Schema.Table], [Index ID], [Partition Function], [Partition #];

--�������� �������
CREATE NONCLUSTERED INDEX [ix_UsedSpace_Log_FG] ON [dbo].[UsedSpace]
(
	[tid_DataBase] ASC
)
INCLUDE([TotalVolume],[LogVolume],[UsedLogVolume])  
ON parHELP (recorddate)

--��������
SELECT 
	OBJECT_NAME(ps.[object_id]) AS [��� �������]
	,indx.[name] AS [��� �������]
	,ps.[partition_id] AS [������������� ������]
	,ps.[partition_number] AS [����� ������]
	,ps.[in_row_data_page_count] AS [���������� ������� ��� �������� ������] 
FROM sys.dm_db_partition_stats ps
	LEFT JOIN sys.indexes indx
	ON ps.object_id = indx.object_id
		AND ps.index_id = indx.index_id
WHERE 
	 OBJECT_NAME(ps.object_id) = 'UsedSpace'
	and indx.[name] = 'ix_UsedSpace_Log_FG'

 