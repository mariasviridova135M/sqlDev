/*
Цель:
В этом ДЗ вы поработаете с индексами.

Описание/Пошаговая инструкция выполнения домашнего задания:
Думаем какие запросы у вас будут в базе и добавляем для них индексы. Проверяем, что они используются в запросе.
*/
USE [HelpDB]
GO
-----------------------------------------------------------------------------
----были созданы ранее
-----------------------------------------------------------------------------
/*
CREATE INDEX ix_ReglamentTypes_Name ON dbo.ReglamentTypes (Name) 

CREATE INDEX ix_HistoryReglaments_Status ON dbo.HistoryReglaments (Status)
INCLUDE (StartDate, FinishDate)

CREATE INDEX ix_UsedSpace_Data ON dbo.UsedSpace (tid_DataBase)
INCLUDE (TotalVolume, DataVolume, UsedDataVolume)

CREATE INDEX ix_UsedSpace_Log ON dbo.UsedSpace (tid_DataBase)
INCLUDE (TotalVolume, LogVolume, UsedLogVolume)
*/
-----------------------------------------------------------------------------
----новые
-----------------------------------------------------------------------------


CREATE INDEX ix_FullnessDisks_Volume ON dbo.FullnessDisks (tid_disk)
INCLUDE (TotalVolume, UsedVolume)

CREATE INDEX ix_DataBaseAdmins_Email ON dbo.DataBaseAdmins (Email)
INCLUDE (FirstName, MiddleName, LastName)

CREATE INDEX ix_HelpTable_DataBase ON dbo.HelpTable (tid_HistoryReglament, tid_UsedSpase)
INCLUDE (PercentAvailableVolumeDisk, TimeReglament, PercentAvailableVolumeData, PercentAvailableVolumeLog)

-----------------------------------------------------------------------------
----проверка
-----------------------------------------------------------------------------
SELECT * 
FROM ReglamentTypes 
WHERE Name Like '%Åæåíåäåëüíîå%'

SELECT StartDate, FinishDate 
FROM HistoryReglaments  
WHERE Status = 0

SELECT TotalVolume, DataVolume, UsedDataVolume
FROM UsedSpace  
WHERE tid_DataBase = 1

SELECT TotalVolume, LogVolume, UsedLogVolume
FROM UsedSpace  
WHERE tid_DataBase = 5


SELECT TotalVolume, UsedVolume
FROM FullnessDisks  
WHERE tid_disk = 3

SELECT FirstName, MiddleName, LastName
FROM DataBaseAdmins  
WHERE Email like '%smirnov.vv@%'


SELECT PercentAvailableVolumeDisk, TimeReglament, PercentAvailableVolumeData, PercentAvailableVolumeLog
FROM HelpTable  
WHERE tid_HistoryReglament = 3
and tid_UsedSpase in (1,2,3)
