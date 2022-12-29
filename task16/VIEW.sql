 -----------------------------------------------------------------------------------------------
 CREATE VIEW view_HistoryReglaments
 AS 
 SELECT r.Name as [��������],  DATEDIFF( HOUR, hr.StartDate, hr.FinishDate) as [������������], 
 IIF( Status = 0 or Status IS NULL, '�� �������',  '�����') as [������],
 hr.RecordDate as [���� ������]
 FROM Reglaments R
 JOIN HistoryReglaments HR ON HR.tid_Reglament = R.tid
  GO
 select * from view_HistoryReglaments
  GO
   -----------------------------------------------------------------------------------------------
 CREATE VIEW view_FullnessDisks
 AS 
 SELECT CAST(d.Name  + ' ' + d.Path as varchar) as [��������],
 fd.TotalVolume as [�����],
 fd.UsedVolume as [������������, ��],
100 - ((fd.UsedVolume/fd.TotalVolume)*100)  [��������, %],
 fd.RecordDate as [����]
 FROM FullnessDisks fd
 JOIN Disks d on d.tid = fd.tid_disk
  GO
 select * from view_FullnessDisks
  GO
   -----------------------------------------------------------------------------------------------
 CREATE VIEW view_UsedSpace
 AS 
 SELECT
dbt.Name as [���],
db.Name as [��������],
d.Path  as [����],
us.UsedDataVolume as [������, ��],
(us.UsedDataVolume/US.DataVolume) *100 [������������� �������, %],
(1 - us.UsedDataVolume/US.DataVolume) *100 [�������� ��� ������, %],
us.UsedLogVolume  as [���, ��],
(us.UsedLogVolume/US.LogVolume) *100 [������������� ����, %],
(1 - us.UsedLogVolume/US.LogVolume) *100 [�������� ��� ����, %],
us.RecordDate as [����]
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
SELECT DISTINCT d.Name as [����],
100 - PercentAvailableVolumeDisk as [������������� �����, %],
100 - PercentAvailableVolumeData [������������� �������, %], 
PercentAvailableVolumeLog [������������� ���, %], 
ht.RecordDate [����]
FROM HelpTable ht
join FullnessDisks fd on ht.tid_FullnessDisk = fd.tid
join Disks d on d.tid = fd.tid_disk 
GO
 select * from view_HelpTableFullnessDisks
  GO
-----------------------------------------------------------------------------------------------