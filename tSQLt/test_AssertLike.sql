EXEC tSQLt.NewTestClass 'testHelpDB'
GO

CREATE OR ALTER PROCEDURE testHelpDB.[test Module2]
AS
BEGIN
	DECLARE @actual NVARCHAR(50)
	DECLARE @bodyemail NVARCHAR(max),
		@email_address NVARCHAR(max) = 'mari.sviridova1@yandex.ru'

	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM HelpDB.dbo.DataBaseAdmins
			WHERE Email LIKE @email_address
			) 
	BEGIN
		EXEC tSQLt.Fail '������������ ��� � ���� ������!';--��������� ������
	END

	EXEC sp_createemail @day = 7,
		@html = @bodyemail OUTPUT

	SELECT @bodyemail

	EXECUTE AS LOGIN = 'sa'

	EXEC msdb.dbo.sp_send_dbmail
		-- ��������� ���� ������� �������������� �������� ��������
		@profile_name = 'sviridova135m@mail.ru',
		-- ����� ����������
		@recipients = @email_address,
		-- ����
		@subject = N'��������� ������� � ���� ������',
		-- ����� ������
		@body = @bodyemail,
		@body_format = 'HTML';

	WAITFOR DELAY '00:00:30';

	SELECT TOP 1 @actual = sent_status
	FROM msdb.dbo.sysmail_allitems
	ORDER BY mailitem_id DESC

	SELECT getdate() AS [����],
		@actual AS [@actual]

	EXEC tSQLt.AssertLike '%sent',
		@actual;--�������� ������� ��������
END;
GO

SELECT TOP 3 getdate() AS [����],
	sent_status, *
FROM msdb.dbo.sysmail_allitems
ORDER BY mailitem_id DESC

EXEC tSQLt.Run 'testHelpDB.[test Module2]'
 
SELECT TOP 3 getdate() AS [����],
	sent_status, *
FROM msdb.dbo.sysmail_allitems
ORDER BY mailitem_id DESC
