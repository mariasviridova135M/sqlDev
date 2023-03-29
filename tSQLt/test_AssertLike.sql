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
		EXEC tSQLt.Fail 'Пользователя нет в базе данных!';--обработка ошибки
	END

	EXEC sp_createemail @day = 7,
		@html = @bodyemail OUTPUT

	SELECT @bodyemail

	EXECUTE AS LOGIN = 'sa'

	EXEC msdb.dbo.sp_send_dbmail
		-- Созданный нами профиль администратора почтовых рассылок
		@profile_name = 'sviridova135m@mail.ru',
		-- Адрес получателя
		@recipients = @email_address,
		-- Тема
		@subject = N'Состояние сервера и базы данных',
		-- Текст письма
		@body = @bodyemail,
		@body_format = 'HTML';

	WAITFOR DELAY '00:00:30';

	SELECT TOP 1 @actual = sent_status
	FROM msdb.dbo.sysmail_allitems
	ORDER BY mailitem_id DESC

	SELECT getdate() AS [Дата],
		@actual AS [@actual]

	EXEC tSQLt.AssertLike '%sent',
		@actual;--проверка статуса отправки
END;
GO

SELECT TOP 3 getdate() AS [Дата],
	sent_status, *
FROM msdb.dbo.sysmail_allitems
ORDER BY mailitem_id DESC

EXEC tSQLt.Run 'testHelpDB.[test Module2]'
 
SELECT TOP 3 getdate() AS [Дата],
	sent_status, *
FROM msdb.dbo.sysmail_allitems
ORDER BY mailitem_id DESC
