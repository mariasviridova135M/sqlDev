---------------------------------------------------------------
--���� ������
---------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_loginfodbs
AS
BEGIN
	INSERT INTO FullnessDisks (
		tid_disk
		,TotalVolume
		,UsedVolume
		)
	SELECT D.TID
		,A.TOTAL
		,A.VIS
	FROM (
		SELECT DISTINCT vs.volume_mount_point
			,CONVERT(DECIMAL(25, 6), vs.total_bytes / 1073741824.0) AS TOTAL
			,CONVERT(DECIMAL(25, 6), vs.available_bytes / 1073741824.0) AS VIS
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.[file_id]) AS vs
		) a
	JOIN Disks D WITH (NOLOCK) ON D.Path = A.volume_mount_point collate SQL_Latin1_General_cP1251_CI_AS


	WITH fs AS (
			SELECT database_id
				,type
				,size * 8.0 / 1024 AS size
				,CONVERT(DECIMAL(10, 2), SIZE / 128.0 - ((SIZE / 128.0) - CAST(FILEPROPERTY(NAME, 'SPACEUSED') AS INT) / 128.0)) AS [UsedSpace]
			FROM sys.master_files
			)

	INSERT INTO UsedSpace (
		tid_DataBase
		,TotalVolume
		,DataVolume
		,UsedDataVolume
		,LogVolume
		,UsedLogVolume
		)
	SELECT ud.tid
		,(
			SELECT sum(size)
			FROM fs
			WHERE fs.database_id = db.database_id
			) total
		,(
			SELECT sum(size)
			FROM fs
			WHERE type = 0
				AND fs.database_id = db.database_id
			) DataFileSizeMB
		,(
			SELECT sum(UsedSpace)
			FROM fs
			WHERE type = 0
				AND fs.database_id = db.database_id
			) UsedDataSizeMB
		,(
			SELECT sum(size)
			FROM fs
			WHERE type = 1
				AND fs.database_id = db.database_id
			) LogFileSizeMB
		,(
			SELECT sum(UsedSpace)
			FROM fs
			WHERE type = 1
				AND fs.database_id = db.database_id
			) UsedLogSizeMB
	FROM sys.databases db
	LEFT JOIN DataBases ud ON db.name = ud.Name

	INSERT INTO HistoryReglaments (
		tid_Reglament
		,StartDate
		,FinishDate
		,STATUS
		)
	SELECT r.tid
		,CONVERT(VARCHAR, convert(VARCHAR, mpl.start_time, 120)) AS StartDate
		,CONVERT(VARCHAR, convert(VARCHAR, mpl.end_time, 120)) AS FinishDate
		,mpl.succeeded
	FROM msdb.dbo.sysmaintplan_plans mp
	INNER JOIN msdb.dbo.sysmaintplan_subplans msp WITH (NOLOCK) ON mp.id = msp.plan_id
	INNER JOIN msdb.dbo.sysmaintplan_log mpl WITH (NOLOCK) ON msp.subplan_id = mpl.subplan_id
	JOIN Reglaments r WITH (NOLOCK) ON r.Name = mp.name collate SQL_Latin1_General_CP1251_CI_AS
	WHERE (
			mp.name LIKE '%TRANSIT%'
			OR mp.name LIKE '%LEAD%'
			)
		AND DATEDIFF(DAY, mpl.start_time, getdate()) = 1
	ORDER BY mpl.end_time

	INSERT INTO HelpTable (
		tid_FullnessDisk
		,tid_HistoryReglament
		,tid_UsedSpase
		,PercentAvailableVolumeDisk
		,PercentAvailableVolumeData
		,PercentAvailableVolumeLog
		,TimeReglament
		)
	SELECT fd.tid
		,tid_HistoryReglament
		,tid_UsedSpase
		,fd.UsedVolume / fd.TotalVolume * 100 AS PercentAvailableVolumeDisk
		,PercentAvailableVolumeData
		,PercentAvailableVolumeLog
		,TimeReglament
	FROM DataBases db
	INNER JOIN Disks d ON d.tid = db.tid_disk
	INNER JOIN FullnessDisks fd ON d.tid = fd.tid_disk
	OUTER APPLY (
		SELECT us.UsedDataVolume / us.DataVolume * 100 AS PercentAvailableVolumeData
			,us.UsedLogVolume / us.LogVolume * 100 AS PercentAvailableVolumeLog
			,us.tid AS tid_UsedSpase
		FROM UsedSpace us
		WHERE us.tid_DataBase = db.tid
			AND DATEPART(YEAR, us.RecordDate) = DATEPART(YEAR, FD.RecordDate)
			AND DATEPART(MONTH, us.RecordDate) = DATEPART(MONTH, FD.RecordDate)
			AND DATEPART(DAY, us.RecordDate) = DATEPART(DAY, FD.RecordDate)
		) b
	OUTER APPLY (
		SELECT DATEDIFF(HOUR, h.StartDate, h.FinishDate) AS TimeReglament
			,h.tid AS tid_HistoryReglament
		FROM HistoryReglaments h
		INNER JOIN Reglaments r ON r.tid = h.tid_Reglament
		WHERE r.tid_DataBase = db.tid
			AND DATEPART(YEAR, h.RecordDate) = DATEPART(YEAR, FD.RecordDate)
			AND DATEPART(MONTH, h.RecordDate) = DATEPART(MONTH, FD.RecordDate)
			AND DATEPART(DAY, h.RecordDate) = DATEPART(DAY, FD.RecordDate)
		) c
	WHERE tid_HistoryReglament IS NOT NULL
	ORDER BY RecordDate
END
GO


USE msdb ;  
GO  
EXEC dbo.sp_add_job  
    @job_name = N'�����������' ;  
GO  
EXEC sp_add_jobstep  
    @job_name = N'�����������',  
    @step_name = N'����������� �� ��������� ����',  
    @subsystem = N'TSQL',  
	@database_name = N'HelpDB',
    @command = N'EXEC sp_loginfodbs',   
    @retry_attempts = 1,  --���������� ��������� �������, ������������ � ������ ���� ����� ���
    @retry_interval = 5 ;  --����� � ������� ����� ���������� ���������
GO  
EXEC dbo.sp_add_schedule  
    @schedule_name = N'EveryDay',  
    @freq_type = 4,  
    @active_start_time = 230000 ;  
USE msdb ;  
GO  
EXEC sp_attach_schedule  
   @job_name = N'�����������',  
   @schedule_name = N'EveryDay';  
GO  
EXEC dbo.sp_add_jobserver  
    @job_name = N'�����������';  
GO

---------------------------------------------------------------
--��������� ��������
---------------------------------------------------------------
-- ������� ������� Service broker - �� ��������� ��� �������� ��������
-- �����, ������������ DBMail
IF (SELECT is_broker_enabled FROM sys.databases WHERE [name] = 'msdb') = 0
	ALTER DATABASE msdb SET ENABLE_BROKER WITH ROLLBACK AFTER 10 SECONDS
GO
-- ������� ��������������� ������� DBMail
sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE
GO

--����� ����� ���������, �������� �� ������ DBMail:
EXECUTE msdb.dbo.sysmail_help_status_sp
GO
/*
--� ���� ��� �� �������� (�� ������ �� �STARTED�), �� ��������� �� ��������
EXECUTE msdb.dbo.sysmail_start_sp
*/ 
  
--�������� ��������
EXECUTE msdb.dbo.sysmail_add_account_sp  
@account_name = 'sviridova_dba@mail.ru',  
@description = 'Mail account for administrative e-mail.',  
@email_address = 'sviridova_dba@mail.ru',  
@display_name = 'Automated Mailer',  
@mailserver_name = 'smtp.mail.ru' ,
-- ���� SMTP-�������, ������ 25
@port = 25,
-- ��� ������������. ��������� �������� ������� ������� �������� �����
-- ������ ��������� ����� ������ ������ ����� ������������
@username = 'sviridova_dba@mail.ru',
-- ������ � ��������� �����
@password = 'JmNDQQqFkz4xfq6iVjQR',
-- ������ SSL ��� �����������, ����������� SMTP-�������� ������ ������� SSL
@enable_ssl = 1; 
GO
				
-- �������� ��������� �������� � ���������
EXEC msdb.dbo.sysmail_help_account_sp;
GO
EXECUTE msdb.dbo.sysmail_help_profile_sp;  
GO
/*
EXECUTE msdb.dbo.sysmail_delete_account_sp  
@account_name = 'admin@mail.ru' ;   

EXECUTE msdb.dbo.sysmail_delete_profile_sp  
@profile_name = 'sviridova135m@mail.ru' ;   
 
*/
-- �������� ������� �������������� �������� ��������
EXECUTE msdb.dbo.sysmail_add_profile_sp
		@profile_name = 'sviridova_dba@mail.ru';
GO
-- ��������� SMTP-������� � ���������� �������
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
		@profile_name = 'sviridova_dba@mail.ru',
		@account_name = 'sviridova_dba@mail.ru',
	-- ��������� ������ SMTP-�������� � �������
		@sequence_number = 24;
GO
-- ��������� ����� ������� � ������� ��� ���� DatabaseMailUserRole ���� MSDB
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
		@profile_name = 'sviridova_dba@mail.ru',
		@principal_id = 0,
		@is_default = 1;
GO
 
 
 --�������� ������
EXECUTE as login = 'sa'
EXEC  msdb.dbo.sp_send_dbmail    
	-- ��������� ���� ������� �������������� �������� ��������
		@profile_name = 'sviridova_dba@mail.ru', 
	-- ����� ����������
		@recipients = 'mari.sviridova1@yandex.ru',
	-- ����� ������
		@body = N'��������� ������� SQL Server Database Mail',
	-- ����
		@subject = N'�������� ���������' 		  
GO
 
--���� ���-�� �� � �������, ������� ����� ���������� �� ������ ������:
SELECT sent_status,*
FROM msdb.dbo.sysmail_allitems
ORDER BY 2 DESC

--� ����� ��������� � ���:
SELECT * FROM msdb.dbo.sysmail_event_log
ORDER BY 1 DESC
 
--������� ������������ ������ ����� ���������� ����� SQL-��������:
SELECT sent_account_id, sent_date FROM msdb.dbo.sysmail_sentitems
GO
---------------------------------------------------------------
--��������� ��� ����������� ������� � html-�������
---------------------------------------------------------------
CREATE OR ALTER PROC [dbo].[spQueryToHtmlTable] 
(
  @query nvarchar(MAX), --A query to turn into HTML format. It should not include an ORDER BY clause.
  @orderBy nvarchar(MAX) = NULL, --An optional ORDER BY clause. It should contain the words 'ORDER BY'.
  @html nvarchar(MAX) = NULL OUTPUT --The HTML output of the procedure.
)
AS
BEGIN   
  SET NOCOUNT ON;

  IF @orderBy IS NULL BEGIN
    SET @orderBy = ''  
  END

  SET @orderBy = REPLACE(@orderBy, '''', '''''');

  DECLARE @realQuery nvarchar(MAX) = '
    DECLARE @headerRow nvarchar(MAX);
    DECLARE @cols nvarchar(MAX);    

    SELECT * INTO #dynSql FROM (' + @query + ') sub;

    SELECT @cols = COALESCE(@cols + '', '''''''', '', '''') + ''['' + name + ''] AS ''''td''''''
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @cols = ''SET @html = CAST(( SELECT '' + @cols + '' FROM #dynSql ' + @orderBy + ' FOR XML PATH(''''tr''''), ELEMENTS XSINIL) AS nvarchar(max))''    

    EXEC sys.sp_executesql @cols, N''@html nvarchar(MAX) OUTPUT'', @html=@html OUTPUT

    SELECT @headerRow = COALESCE(@headerRow + '''', '''') + ''<th>'' + name + ''</th>'' 
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @headerRow = ''<tr>'' + @headerRow + ''</tr>'';

    SET @html = ''<table border="1">'' + @headerRow + @html + ''</table>'';    
    ';

  EXEC sys.sp_executesql @realQuery, N'@html nvarchar(MAX) OUTPUT', @html=@html OUTPUT
END
GO

---------------------------------------------------------------
--�������� ����������� � ����������� � �����������
---------------------------------------------------------------
CREATE TABLE DictionaryView (
	tid int identity(1, 1),
	NameRU nvarchar(MAX),
	NameEN nvarchar(MAX),
	Descrip nvarchar(MAX)
)

INSERT INTO DictionaryView (NameEN,
                            NameRU,
                            Descrip)
SELECT 'view_HistoryReglaments',
       '������� ������������',
       '���������� ��� ����� ����������� ������������ ��'

INSERT INTO DictionaryView (NameEN,
                            NameRU,
                            Descrip)
SELECT 'view_FullnessDisks',
       '������������� ������',
       '��������� ���������� �������� ������������'

INSERT INTO DictionaryView (NameEN,
                            NameRU,
                            Descrip)
SELECT 'view_UsedSpace',
       '������������� ������������',
       '��� �������������� ����� ��� ������ � ���'

INSERT INTO DictionaryView (NameEN,
                            NameRU,
                            Descrip)
SELECT 'view_HelpTableFullnessDisks',
       '����� ���������� � ������',
       '������������� ��������������'

SELECT *
FROM DictionaryView 
GO
 ---------------------------------------------------------------
--��������� ������������ ���� ������
---------------------------------------------------------------
CREATE	OR ALTER PROCEDURE sp_createemail (
	@day INT
	,@html NVARCHAR(max) OUTPUT
	)
AS
BEGIN
	DECLARE @body NVARCHAR(max)
		,@title NVARCHAR(max)
		,@table NVARCHAR(max)
		,@sql NVARCHAR(max)
		,@name NVARCHAR(max)
	DECLARE @view TABLE (
		tid INT identity(1, 1)
		,tid_view INT
		,NameRU NVARCHAR(max)
		,NameEN NVARCHAR(max)
		,Descrip NVARCHAR(max)
		)
	DECLARE @tid INT
		,@tid_view INT
		,@NameEN NVARCHAR(max)
		,@NameRU NVARCHAR(max)
		,@Descrip NVARCHAR(max)

	INSERT INTO @view (
		tid_view
		,NameRU
		,NameEN
		,Descrip
		)
	SELECT tid
		,Nameru
		,NameEN
		,Descrip
	FROM HelpDB.dbo.DictionaryView

	WHILE (
			SELECT count(*)
			FROM @view
			) > 0
	BEGIN
		SET @tid = (
				SELECT TOP 1 tid
				FROM @view
				)
		SET @tid_view = (
				SELECT TOP 1 tid_view
				FROM @view
				)
		SET @NameRU = (
				SELECT TOP 1 NameRU
				FROM @view
				WHERE tid_view = @tid_view
				)
		SET @NameEN = (
				SELECT TOP 1 NameEN
				FROM @view
				WHERE tid_view = @tid_view
				)
		SET @Descrip = (
				SELECT TOP 1 Descrip
				FROM @view
				WHERE tid_view = @tid_view
				)
		SET @title = '<html> <body> <h2>' + @NameRU + '</h2>' + @Descrip + '<h3></h23</body></html>'
		SET @sql = 'select * from ' + @NameEN + ' where datediff (day, [����],getdate()) = ' + CAST(@day AS NVARCHAR(max))

		EXEC spQueryToHtmlTable @query = @sql
			,@html = @table OUTPUT

		SET @body = isnull(@body, '<p></p>') + isnull(@title, '���������� ���') + isnull(@table, '���������� ���')

		DELETE
		FROM @view
		WHERE tid = @tid
	END

	SET @html = '<html> <body>' + @body + '</body></html>'
END
GO

---------------------------------------------------------------
--��������� �������� �� �����
---------------------------------------------------------------
CREATE	OR ALTER PROCEDURE sp_sentemail (@html NVARCHAR(max))
AS
BEGIN
	DECLARE @temp TABLE (email NVARCHAR(max))
	DECLARE @email_address NVARCHAR(max)

	INSERT INTO @temp (email)
	SELECT Email
	FROM HelpDB.dbo.DataBaseAdmins

	WHILE (
			SELECT count(*)
			FROM @temp
			) > 0
	BEGIN
		SET @email_address = (
				SELECT TOP 1 email
				FROM @temp
				)

		EXECUTE AS LOGIN = 'sa'
		EXEC msdb.dbo.sp_send_dbmail
			-- ��������� ���� ������� �������������� �������� ��������
			@profile_name = 'sviridova_dba@mail.ru',
			-- ����� ����������
			@recipients = @email_address,
			-- ����
			@subject = N'��������� ������� � ���� ������',
			-- ����� ������
			@body = @html,
			@body_format = 'HTML';

		DELETE
		FROM @temp
		WHERE email = @email_address
	END
END
GO

---------------------------------------------------------------
--������
---------------------------------------------------------------
DECLARE @bodyemail NVARCHAR(max)

EXEC sp_createemail @day = 100
	,@html = @bodyemail OUTPUT

SELECT @bodyemail

EXEC sp_sentemail @html = @bodyemail
GO
---------------------------------------------------------------
--��������� ��� �������� ����� �������
---------------------------------------------------------------
CREATE	OR ALTER PROCEDURE sp_sentinfodbs (@day int)
AS
BEGIN
	DECLARE @bodyemail NVARCHAR(max)

	EXEC sp_createemail @day = @day
	,@html = @bodyemail OUTPUT 

	EXEC sp_sentemail @html = @bodyemail
END
GO

---------------------------------------------------------------
--������������ ����� ��� ��������
---------------------------------------------------------------
USE msdb ;  
GO  
EXEC dbo.sp_add_job  
    @job_name = N'��������� �� � �������' ;  
GO  
EXEC sp_add_jobstep  
    @job_name = N'��������� �� � �������',  
    @step_name = N'������ �� ��������� ����',  
    @subsystem = N'TSQL',  
	@database_name = N'HelpDB',
    @command = N'EXEC sp_sentinfodbs @day = 1',   
    @retry_attempts = 1,  --���������� ��������� �������, ������������ � ������ ���� ����� ���
    @retry_interval = 5 ;  --����� � ������� ����� ���������� ���������
GO  
EXEC dbo.sp_add_schedule  
    @schedule_name = N'RunEveryDay',  
    @freq_type = 4,  
    @active_start_time = 080000 ;  
USE msdb ;  
GO  
EXEC sp_attach_schedule  
   @job_name = N'��������� �� � �������',  
   @schedule_name = N'RunEveryDay';  
GO  
EXEC dbo.sp_add_jobserver  
    @job_name = N'��������� �� � �������';  
GO

---------------------------------------------------------------
--��������� �����������
---------------------------------------------------------------
USE msdb ;  
GO  
EXEC dbo.sp_add_job  
    @job_name = N'��������� �����������' ;  
GO  
EXEC sp_add_jobstep  
    @job_name = N'��������� �����������',  
    @step_name = N'������',  
    @subsystem = N'TSQL',  
	@database_name = N'HelpDB',
    @command = N'BACKUP DATABASE HelpDB TO DISK = ''C:\work\tmp\HelpDB.bak'' WITH FORMAT, MEDIANAME = ''SQLServerBackups'', NAME = ''Full Backup of HelpDB'';GO',   
    @retry_attempts = 1,  --���������� ��������� �������, ������������ � ������ ���� ����� ���
    @retry_interval = 5 ;  --����� � ������� ����� ���������� ���������
GO  
EXEC dbo.sp_add_schedule  
    @schedule_name = N'RunEvery7Day',  
    @freq_type = 8,  
    @active_start_time = 233000 ;  
USE msdb ;  
GO  
EXEC sp_attach_schedule  
   @job_name = N'��������� �����������',  
   @schedule_name = N'RunEvery7Day';  
GO  
EXEC dbo.sp_add_jobserver  
    @job_name = N'��������� �����������';  
GO

---------------------------------------------------------------
--����������� �������
--------------------------------------------------------------- 
CREATE VIEW [dbo].[CreatePassword]
AS
SELECT NEWID() AS [UniqueID]
GO

CREATE FUNCTION [dbo].[fnCreatePassword] (@Length INT)
RETURNS VARCHAR(18) 
AS 
BEGIN
DECLARE @Password VARCHAR(18),
     @CharSet VARCHAR(75),
     @initialpw VARCHAR(5),
     @CharPick INT,
     @Counter INT
 
SET @initialpw = ''
SET @CharSet='AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789!@#$%&'
SET @Counter = 1
SET @Password = @initialpw
 
WHILE @Counter <= @Length
BEGIN
SELECT @CharPick = ABS(CAST (CAST([UniqueID] AS VARBINARY) AS INT)) %LEN(@CharSet) + 2
FROM [dbo].[CreatePassword]
 
SET @Password = @Password + SUBSTRING(@CharSet, @CharPick, 1)
SET @Counter= @Counter + 1
 
END
RETURN @Password
END
GO
-------------------------------------------------------------------------------------
SELECT [dbo].[fnCreatePassword] (14)

CREATE LOGIN readerHelpDB   
    WITH PASSWORD = 'iommleJcSz$k6D';  
GO  
 
CREATE USER readerHelpDB FOR LOGIN readerHelpDB;  
GO

ALTER ROLE db_denydatawriter
	ADD MEMBER readerHelpDB;  
GO
