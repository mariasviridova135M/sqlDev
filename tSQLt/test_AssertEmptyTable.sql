EXEC tSQLt.NewTestClass 'testHelpDB'
GO

CREATE OR ALTER PROCEDURE testHelpDB.[test Module4]
AS
BEGIN
	IF OBJECT_ID('actual') IS NOT NULL
		DROP TABLE actual;

	EXEC sp_FindBackup

	SELECT tid,
		SubDirectory,
		Depth,
		FileFlag,
		ParentDirectoryID
	INTO actual
	FROM DirTree;
 
	EXEC tSQLt.AssertEmptyTable 'actual';
END;

EXEC tSQLt.Run 'testHelpDB.[test Module4]'

EXEC sp_FullBackup --запуск резервного копирования
