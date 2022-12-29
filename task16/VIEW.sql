 -----------------------------------------------------------------------------------------------
 CREATE VIEW view_HistoryReglaments
 AS 
 SELECT r.Name as [Название],  DATEDIFF( HOUR, hr.StartDate, hr.FinishDate) as [Длительность], 
 IIF( Status = 0 or Status IS NULL, 'Не успешно',  'Успех') as [Статус],
 hr.RecordDate as [Дата записи]
 FROM Reglaments R
 JOIN HistoryReglaments HR ON HR.tid_Reglament = R.tid
  GO
 select * from view_HistoryReglaments
  GO
   -----------------------------------------------------------------------------------------------
 CREATE VIEW view_FullnessDisks
 AS 
 SELECT CAST(d.Name  + ' ' + d.Path as varchar) as [Название],
 fd.TotalVolume as [Объем],
 fd.UsedVolume as [Использовано, ГБ],
100 - ((fd.UsedVolume/fd.TotalVolume)*100)  [Свободно, %],
 fd.RecordDate as [Дата]
 FROM FullnessDisks fd
 JOIN Disks d on d.tid = fd.tid_disk
  GO
 select * from view_FullnessDisks
  GO
   -----------------------------------------------------------------------------------------------
 CREATE VIEW view_UsedSpace
 AS 
 SELECT
dbt.Name as [Тип],
db.Name as [Название],
d.Path  as [Диск],
us.UsedDataVolume as [Данные, ГБ],
(us.UsedDataVolume/US.DataVolume) *100 [Заполненность данными, %],
(1 - us.UsedDataVolume/US.DataVolume) *100 [Свободно для данных, %],
us.UsedLogVolume  as [Лог, ГБ],
(us.UsedLogVolume/US.LogVolume) *100 [Заполненность лога, %],
(1 - us.UsedLogVolume/US.LogVolume) *100 [Свободно для лога, %],
us.RecordDate as [Дата]
 FROM UsedSpace us
 LEFT JOIN DataBases db on db.tid = us.tid_DataBase
 LEFT JOIN DataBaseTypes dbt on dbt.tid = db.tid_DataBasesType
 LEFT join Disks d on db.tid_disk = d.tid
  GO

 select * from view_UsedSpace
  GO
 -----------------------------------------------------------------------------------------------
CREATE VIEW view_HelpTableFullnessDisks
AS 
SELECT DISTINCT d.Name as [Диск],
100 - PercentAvailableVolumeDisk as [Заполненность диска, %],
100 - PercentAvailableVolumeData [Заполненность данными, %], 
PercentAvailableVolumeLog [Заполненность лог, %], 
ht.RecordDate [Дата]
FROM HelpTable ht
join FullnessDisks fd on ht.tid_FullnessDisk = fd.tid
join Disks d on d.tid = fd.tid_disk 
GO
 select * from view_HelpTableFullnessDisks
  GO
-----------------------------------------------------------------------------------------------