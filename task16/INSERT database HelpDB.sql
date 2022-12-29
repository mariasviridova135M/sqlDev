-------------------------------------------------------------------------------------------------
---ReglamentTypes
-------------------------------------------------------------------------------------------------
insert into ReglamentTypes (Name)
values ('Ежедневное'),
	('Еженедельное'),
	('Шринк');
-------------------------------------------------------------------------------------------------
---DataBaseTypes
-------------------------------------------------------------------------------------------------
insert into DataBaseTypes (Name)
values ('Тестовая'),
	('Рабочая'),
	('Для битья');
-------------------------------------------------------------------------------------------------
---Disks
-------------------------------------------------------------------------------------------------
insert into Disks (
	Name,
	Path,
	Description
	)
values (
	'Системный',
	'C:\',
	'SYSTEM'
	),
	(
	'Основной',
	'D:\',
	'BASE'
	),
	(
	'Тестовый',
	'A:\',
	'TEST'
	),
	(
	'Бэкап',
	'B:\',
	'BACKUP'
	);
-------------------------------------------------------------------------------------------------
---DataBaseAdmins
-------------------------------------------------------------------------------------------------
insert into DataBaseAdmins (
	LastName,
	FirstName,
	MiddleName,
	Email
	)
values (
	'Смирнов',
	'Иван',
	'Иванович',
	'smirnov@mail.ru'
	),
	(
	'Иванова',
	'Варвара',
	'Петровна',
	'ivanov@mail.ru'
	),
	(
	'Кирьянов',
	'Петр',
	'Семенович',
	'perchik98@yandex.ru'
	),
	(
	'Петров',
	'Роман',
	'Романович',
	'petrov@mail.ru'
	),
	(
	'Романов',
	'Семен',
	'Владимирович',
	'romanov@mail.ru'
	),
	(
	'Демидов',
	'Григорий',
	'Николаевич',
	'demid@google.com'
	);
-------------------------------------------------------------------------------------------------
---FullnessDisks
-------------------------------------------------------------------------------------------------
declare @counter int,
	@RandomVolume decimal(15, 6);

set @counter = 1;

while @counter < 50
begin
	set @RandomVolume = RAND() * (250 - 100) + 100

	insert into FullnessDisks (
		tid_disk,
		TotalVolume,
		UsedVolume,
		RecordDate
		)
	values (
		(
			select tid
			from Disks
			where Description like '%SYSTEM%'
			),
		256,
		@RandomVolume,
		DATEADD(DAY, - @counter, GETDATE())
		),
		(
		(
			select tid
			from Disks
			where Description like '%BASE%'
			),
		512,
		@RandomVolume - 10,
		DATEADD(DAY, - @counter, GETDATE())
		),
		(
		(
			select tid
			from Disks
			where Description like '%TEST%'
			),
		512,
		@RandomVolume + 15,
		DATEADD(DAY, - @counter, GETDATE())
		),
		(
		(
			select tid
			from Disks
			where Description like '%BACKUP%'
			),
		1024,
		@RandomVolume - 27,
		DATEADD(DAY, - @counter, GETDATE())
		);

	set @counter = @counter + 1
end;
go
-------------------------------------------------------------------------------------------------
---DataBases
-------------------------------------------------------------------------------------------------
insert into DataBases (
	Name,
	tid_DataBasesType,
	tid_disk
	)
values (
	'TMS_RZN',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%SYSTEM%'
		)
	),
	(
	'TMS_RZN_test',
	(
		select tid
		from DataBaseTypes
		where Name like '%Тестовая%'
		),
	(
		select tid
		from Disks
		where Description like '%TEST%'
		)
	),
	(
	'TMS_KZN_test',
	(
		select tid
		from DataBaseTypes
		where Name like '%Тестовая%'
		),
	(
		select tid
		from Disks
		where Description like '%TEST%'
		)
	),
	(
	'TMS_MSK_test',
	(
		select tid
		from DataBaseTypes
		where Name like '%Тестовая%'
		),
	(
		select tid
		from Disks
		where Description like '%TEST%'
		)
	),
	(
	'TMS_SPB_test',
	(
		select tid
		from DataBaseTypes
		where Name like '%Тестовая%'
		),
	(
		select tid
		from Disks
		where Description like '%TEST%'
		)
	),
	(
	'TMS_NSK_test',
	(
		select tid
		from DataBaseTypes
		where Name like '%Тестовая%'
		),
	(
		select tid
		from Disks
		where Description like '%TEST%'
		)
	),
	(
	'TMS_VLD_test',
	(
		select tid
		from DataBaseTypes
		where Name like '%Тестовая%'
		),
	(
		select tid
		from Disks
		where Description like '%TEST%'
		)
	),
	(
	'TMS_KZN',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BASE%'
		)
	),
	(
	'TMS_MSK',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BASE%'
		)
	),
	(
	'TMS_SPB',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BASE%'
		)
	),
	(
	'TMS_NSK',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BASE%'
		)
	),
	(
	'TMS_VLD',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BASE%'
		)
	),
	(
	'TMS_RZN_bk',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BACKUP%'
		)
	),
	(
	'TMS_KZN_bk',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BACKUP%'
		)
	),
	(
	'TMS_MSK_bk',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BACKUP%'
		)
	),
	(
	'TMS_SPB_bk',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BACKUP%'
		)
	),
	(
	'TMS_NSK_bk',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BACKUP%'
		)
	),
	(
	'TMS_VLD_bk',
	(
		select tid
		from DataBaseTypes
		where Name like '%Рабочая%'
		),
	(
		select tid
		from Disks
		where Description like '%BACKUP%'
		)
	),
	(
	'TMS',
	(
		select tid
		from DataBaseTypes
		where Name like '%битья%'
		),
	(
		select tid
		from Disks
		where Description like '%TEST%'
		)
	);
go
-------------------------------------------------------------------------------------------------
---Reglaments
-------------------------------------------------------------------------------------------------
insert into Reglaments (
	tid_DataBase,
	Name,
	tid_ReglamentType
	)
select db.tid,
	cast(db.Name + ' - ' + a.Name as varchar),
	a.tid
from DataBases db
outer apply (
	select tid,
		Name
	from ReglamentTypes
	) a
where db.Name not like '%_bk'
	and db.Name not like '%_test'

-------------------------------------------------------------------------------------------------
---HistoryReglaments
-------------------------------------------------------------------------------------------------

declare @counter int,
	@RandomHour int,
	@delta int;

set @counter = 1;

while @counter < 50
begin
	set @RandomHour = FLOOR(RAND() * (9)) + 1
	set @delta = FLOOR(RAND() * (3)) + 1

	insert into HistoryReglaments (
		tid_Reglament,
		StartDate,
		FinishDate,
		RecordDate,
		status
		)
	select r.tid,
		a.StartDate,
		a.FunishDate,
		a.RecordDate,
		iif((
				R.tid in (
					select TID
					from Reglaments
					where Name like '%_SPB - Еже%'
					)
				), 0, 1)
	from Reglaments r
	outer apply (
		select [StartDate] = DATEADD(HOUR, - @RandomHour, DATEADD(DAY, - @counter, GETDATE())),
			[FunishDate] = DATEADD(HOUR, - @RandomHour + @delta, DATEADD(DAY, - @counter, GETDATE())),
			[RecordDate] = DATEADD(HOUR, @delta, DATEADD(DAY, - @counter, GETDATE()))
		) a

	set @counter = @counter + 1
end;
go
-------------------------------------------------------------------------------------------------
---UsedSpace
-------------------------------------------------------------------------------------------------


declare @counter int,
	@RandomVolume int,
	@delta int;

set @counter = 1;

while @counter < 50
begin
	set @RandomVolume = RAND() * (20 - 1) + 1
	set @delta = FLOOR(RAND() * (8 - 5) + 5)

	insert into UsedSpace (
		tid_DataBase,
		TotalVolume,
		DataVolume,
		LogVolume,
		UsedDataVolume,
		UsedLogVolume,
		RecordDate
		)
	select db.tid,
		a.TotalVolume - a.TotalVolume / @delta,
		a.UsedVolume - a.UsedVolume / @delta,
		a.UsedVolume / @delta,
		(a.UsedVolume - a.UsedVolume / @delta - @RandomVolume),
		(a.UsedVolume / @delta - @RandomVolume),
		a.RecordDate
	from DataBases db
	outer apply (
		select fd.RecordDate,
			fd.UsedVolume,
			fd.TotalVolume
		from FullnessDisks fd
		inner join Disks d on d.tid = fd.tid_disk
		where d.tid = db.tid_disk
		) a

	set @counter = @counter + 1
end;
go
-------------------------------------------------------------------------------------------------
---HelpTable
-------------------------------------------------------------------------------------------------


insert into HelpTable (
	tid_FullnessDisk,
	tid_HistoryReglament,
	tid_UsedSpase,
	PercentAvailableVolumeDisk,
	PercentAvailableVolumeData,
	PercentAvailableVolumeLog,
	TimeReglament,
	RecordDate
	)
select fd.tid,
	tid_HistoryReglament,
	tid_UsedSpase,
	fd.UsedVolume / fd.TotalVolume * 100 as PercentAvailableVolumeDisk,
	PercentAvailableVolumeData,
	PercentAvailableVolumeLog,
	TimeReglament,
	FD.RecordDate
from DataBases db
inner join Disks d on d.tid = db.tid_disk
inner join FullnessDisks fd on d.tid = fd.tid_disk
outer apply (
	select us.UsedDataVolume / us.DataVolume * 100 as PercentAvailableVolumeData,
		us.UsedLogVolume / us.LogVolume * 100 as PercentAvailableVolumeLog,
		us.tid as tid_UsedSpase
	from UsedSpace us
	where us.tid_DataBase = db.tid
		and DATEPART(YEAR, us.RecordDate) = DATEPART(YEAR, FD.RecordDate)
		and DATEPART(MONTH, us.RecordDate) = DATEPART(MONTH, FD.RecordDate)
		and DATEPART(DAY, us.RecordDate) = DATEPART(DAY, FD.RecordDate)
	) b
outer apply (
	select DATEDIFF(HOUR, h.StartDate, h.FinishDate) as TimeReglament,
		h.tid as tid_HistoryReglament
	from HistoryReglaments h
	inner join Reglaments r on r.tid = h.tid_Reglament
	where r.tid_DataBase = db.tid
		and DATEPART(YEAR, h.RecordDate) = DATEPART(YEAR, FD.RecordDate)
		and DATEPART(MONTH, h.RecordDate) = DATEPART(MONTH, FD.RecordDate)
		and DATEPART(DAY, h.RecordDate) = DATEPART(DAY, FD.RecordDate)
	) c
where tid_HistoryReglament is not null
order by RecordDate
