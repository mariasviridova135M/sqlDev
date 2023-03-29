EXEC tSQLt.NewTestClass 'testHelpDB'
GO

CREATE OR ALTER PROCEDURE testHelpDB.[test Module3]
AS
BEGIN
	IF OBJECT_ID('actual') IS NOT NULL
	BEGIN
		DROP TABLE actual;
	END

	IF OBJECT_ID('expected') IS NOT NULL
	BEGIN
		DROP TABLE expected;
	END

	------Запрос
	SELECT CAST(d.Name + ' ' + d.Path AS VARCHAR) AS [Название],
		fd.TotalVolume AS [Объем],
		fd.UsedVolume AS [Использовано, ГБ],
		100 - ((fd.UsedVolume / fd.TotalVolume) * 100) [Свободно, %],
		fd.RecordDate AS [Дата]
	INTO actual
	FROM FullnessDisks fd
	JOIN Disks d ON d.tid = fd.tid_disk
	ORDER BY fd.RecordDate

	------Данные из представления
	SELECT [Название],
		[Объем],
		[Использовано, ГБ],
		[Свободно, %],
		[Дата]
	INTO expected
	FROM view_FullnessDisks
	ORDER BY Дата

	EXEC tSQLt.AssertEqualsTable 'expected',
		'actual'; --проверка, что данные в представлении равны данным запроса
END;
GO

EXEC tSQLt.Run 'testHelpDB.[test Module3]'
 