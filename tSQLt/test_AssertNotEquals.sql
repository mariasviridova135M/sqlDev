EXEC tSQLt.NewTestClass 'testHelpDB'
GO

CREATE OR ALTER PROCEDURE testHelpDB.[test Module1]
AS
BEGIN
	DECLARE @actual INT,
		@expected INT

	SELECT @actual = count(*)
	FROM dbo.HelpTable;

	INSERT INTO HelpTable (
		tid_FullnessDisk,
		tid_HistoryReglament,
		tid_UsedSpase,
		PercentAvailableVolumeDisk,
		PercentAvailableVolumeData,
		PercentAvailableVolumeLog,
		TimeReglament,
		RecordDate
		)
	SELECT fd.tid,
		tid_HistoryReglament,
		tid_UsedSpase,
		fd.UsedVolume / fd.TotalVolume * 100 AS PercentAvailableVolumeDisk,
		PercentAvailableVolumeData,
		PercentAvailableVolumeLog,
		TimeReglament,
		FD.RecordDate
	FROM DataBases db
	INNER JOIN Disks d ON d.tid = db.tid_disk
	INNER JOIN FullnessDisks fd ON d.tid = fd.tid_disk
	OUTER APPLY (
		SELECT us.UsedDataVolume / us.DataVolume * 100 AS PercentAvailableVolumeData,
			us.UsedLogVolume / us.LogVolume * 100 AS PercentAvailableVolumeLog,
			us.tid AS tid_UsedSpase
		FROM UsedSpace us
		WHERE us.tid_DataBase = db.tid
			AND DATEPART(YEAR, us.RecordDate) = DATEPART(YEAR, FD.RecordDate)
			AND DATEPART(MONTH, us.RecordDate) = DATEPART(MONTH, FD.RecordDate)
			AND DATEPART(DAY, us.RecordDate) = DATEPART(DAY, FD.RecordDate)
		) b
	OUTER APPLY (
		SELECT DATEDIFF(HOUR, h.StartDate, h.FinishDate) AS TimeReglament,
			h.tid AS tid_HistoryReglament
		FROM HistoryReglaments h
		INNER JOIN Reglaments r ON r.tid = h.tid_Reglament
		WHERE r.tid_DataBase = db.tid
			AND DATEPART(YEAR, h.RecordDate) = DATEPART(YEAR, FD.RecordDate)
			AND DATEPART(MONTH, h.RecordDate) = DATEPART(MONTH, FD.RecordDate)
			AND DATEPART(DAY, h.RecordDate) = DATEPART(DAY, FD.RecordDate)
		) c
	WHERE tid_HistoryReglament IS NOT NULL
		AND fd.RecordDate = (
			SELECT max(RecordDate)
			FROM FullnessDisks
			)
	ORDER BY RecordDate

	SELECT @expected = count(*)
	FROM dbo.HelpTable;

	SELECT @actual AS [@actual],
		@expected AS [@expected]

	EXEC tSQLt.AssertNotEquals '@actual',
		'@expected';--проверка, что количества в таблице отличаются

	IF @actual = @expected
	BEGIN
		EXEC tSQLt.Fail 'Данные не добавлены';--обработка ошибки
	END
END;
GO

SELECT count(*) AS [кол-во строк в HelpTable до теста],
	getdate() AS [Дата]
FROM HelpTable

EXEC tSQLt.Run 'testHelpDB.[test Module1]'

SELECT count(*) AS [кол-во строк в HelpTable после теста],
	getdate() AS [Дата]
FROM HelpTable
