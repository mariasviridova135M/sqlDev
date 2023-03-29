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

	------������
	SELECT CAST(d.Name + ' ' + d.Path AS VARCHAR) AS [��������],
		fd.TotalVolume AS [�����],
		fd.UsedVolume AS [������������, ��],
		100 - ((fd.UsedVolume / fd.TotalVolume) * 100) [��������, %],
		fd.RecordDate AS [����]
	INTO actual
	FROM FullnessDisks fd
	JOIN Disks d ON d.tid = fd.tid_disk
	ORDER BY fd.RecordDate

	------������ �� �������������
	SELECT [��������],
		[�����],
		[������������, ��],
		[��������, %],
		[����]
	INTO expected
	FROM view_FullnessDisks
	ORDER BY ����

	EXEC tSQLt.AssertEqualsTable 'expected',
		'actual'; --��������, ��� ������ � ������������� ����� ������ �������
END;
GO

EXEC tSQLt.Run 'testHelpDB.[test Module3]'
 