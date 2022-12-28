/*
Цель:
В этом ДЗ вы потренируетесь создавать таблицы и представления.


Описание/Пошаговая инструкция выполнения домашнего задания:

Начало проектной работы.
Создание таблиц и представлений для своего проекта.
Нужно написать операторы DDL для создания БД вашего проекта:

Создать базу данных.
3-4 основные таблицы для своего проекта.
Первичные и внешние ключи для всех созданных таблиц.
1-2 индекса на таблицы.
Наложите по одному ограничению в каждой таблице на ввод данных.
Обязательно (если еще нет) должно быть описание предметной области.
*/




---------------------------------------------------------------------------------------------------------------------------------------------------
---ОПИСАНИЕ ПРЕДМЕТНОЙ ОБЛАСТИ 
---------------------------------------------------------------------------------------------------------------------------------------------------

/*
Актуальность и практическая значимость подтверждаются тем, что к настоящему времени появилось большое число проблем, 
которые вызваны из-за недостатка информации о состоянии БД на предприятии. Одной из важнейших задач аудита ИС является 
формализация показателей качества и методологии их расчета, на основе которых должна быть получена оценка состояния 
информационной системы в целом и отдельных ее компонентов. Существуют различные стандарты оценки качества и процесса
ее разработки. Их анализ показывает, что актуальной является задача разработки системы обобщенных и частных количественных показателей,
позволяющих оценить качество ИС. Такая система показателей должна базироваться на общепринятых стандартах качества ИС и комплексной модели ИС, 
отражающей все элементы ее архитектуры. База данных - основной объект любой информационной системы.
Если система не будет введена в эксплуатацию, то компания не сможет вовремя принимать управленческие решения в случае возникновения перебоев в работе в период нагрузки. 

Создание новой базы данных позволит на основе анализа состояния сервера отслеживать причины, которые 
негативно влияют на производительность. Разработка позволит на основе стандартных  решений СУБД Microsoft SQL Server
устранить неполноту информации о состоянии сервера, установить причинно-следственные связи между ежедневными действиями над базами данных на сервере,
которые отражаются на производительности, объединить и получить полную подробную информации о базах данных и сервере, 
по которой можно судить о качестве сервера. Кроме того, с помощью новой базы техподдержка ИС сможет получать 
рекомендации для принятия решений на основе ежедневного автоматического мониторинга состояния базы данных. Новая база данных
будет способствовать целям бизнеса, позволяя сокращать расходы на поддержку и восстановление ИС в случае аварийных и форс-мажорных ситуаций.

В разработанной БД будет хранится информация об истории обслуживании, заполнении диска с течением времени, использовании прострастранства данными и логами.
Данные о такой служебной информации будут отправлятся администраторам БД по почте для анализа показателей сервера и базы данных.

Для всех связанных таблиц предусмотрено каскадное удаление/обновление.
В Поле "Дата записи" в таблицах должно проставляться автоматическое значение, равное текущей дате на момент создания записи в таблице.
Все первичные ключи в таблицах - автоинкрементные поля с шагом 1.
*/

---------------------------------------------------------------------------------------------------------------------------------------------------
---СОЗДАННАЯ БАЗА ДАННЫХ 
---------------------------------------------------------------------------------------------------------------------------------------------------

USE [master]
GO
/****** Object:  Database [HelpDB]    Script Date: 28.12.2022 11:02:13 ******/
CREATE DATABASE [HelpDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HelpDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\HelpDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'HelpDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\HelpDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [HelpDB] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [HelpDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [HelpDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [HelpDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [HelpDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [HelpDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [HelpDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [HelpDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [HelpDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [HelpDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [HelpDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [HelpDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [HelpDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [HelpDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [HelpDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [HelpDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [HelpDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [HelpDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [HelpDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [HelpDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [HelpDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [HelpDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [HelpDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [HelpDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [HelpDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [HelpDB] SET  MULTI_USER 
GO
ALTER DATABASE [HelpDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [HelpDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [HelpDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [HelpDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [HelpDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [HelpDB] SET QUERY_STORE = OFF
GO
USE [HelpDB]
GO
/****** Object:  Table [dbo].[DataBaseAdmins]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataBaseAdmins](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[MiddleName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NOT NULL,
	[Email] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataBases]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataBases](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[tid_DataBasesType] [int] NOT NULL,
	[tid_disk] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unique_DataBasesName] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataBaseTypes]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataBaseTypes](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unique_DataBaseTypesName] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Disks]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Disks](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Path] [varchar](255) NOT NULL,
	[Description] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FullnessDisks]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FullnessDisks](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[tid_disk] [int] NOT NULL,
	[TotalVolume] [decimal](15, 6) NOT NULL,
	[UsedVolume] [decimal](15, 6) NOT NULL,
	[RecordDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HelpTable]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HelpTable](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[tid_FullnessDisk] [int] NOT NULL,
	[tid_HistoryReglament] [int] NOT NULL,
	[tid_UsedSpase] [int] NOT NULL,
	[PercentAvailableVolumeDisk] [decimal](15, 6) NOT NULL,
	[TimeReglament] [decimal](15, 6) NOT NULL,
	[PercentAvailableVolumeData] [decimal](15, 6) NOT NULL,
	[PercentAvailableVolumeLog] [decimal](15, 6) NOT NULL,
	[RecordDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HistoryReglaments]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HistoryReglaments](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[tid_Reglament] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[FinishDate] [datetime] NOT NULL,
	[Status] [bit] NOT NULL,
	[RecordDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reglaments]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reglaments](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[tid_ReglamentType] [int] NULL,
	[tid_DataBase] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unique_Name] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unique_ReglamentsName] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReglamentTypes]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReglamentTypes](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UsedSpace]    Script Date: 28.12.2022 11:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsedSpace](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[tid_DataBase] [int] NOT NULL,
	[TotalVolume] [decimal](15, 6) NOT NULL,
	[DataVolume] [decimal](15, 6) NOT NULL,
	[LogVolume] [decimal](15, 6) NOT NULL,
	[UsedDataVolume] [decimal](15, 6) NOT NULL,
	[UsedLogVolume] [decimal](15, 6) NOT NULL,
	[RecordDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [ix_HistoryReglaments_Name]    Script Date: 28.12.2022 11:02:14 ******/
CREATE NONCLUSTERED INDEX [ix_HistoryReglaments_Name] ON [dbo].[HistoryReglaments]
(
	[Status] ASC
)
INCLUDE([StartDate],[FinishDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_ReglamentTypes_Name]    Script Date: 28.12.2022 11:02:14 ******/
CREATE NONCLUSTERED INDEX [ix_ReglamentTypes_Name] ON [dbo].[ReglamentTypes]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_UsedSpace_Data]    Script Date: 28.12.2022 11:02:14 ******/
CREATE NONCLUSTERED INDEX [ix_UsedSpace_Data] ON [dbo].[UsedSpace]
(
	[tid_DataBase] ASC
)
INCLUDE([TotalVolume],[DataVolume],[UsedDataVolume]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_UsedSpace_Log]    Script Date: 28.12.2022 11:02:14 ******/
CREATE NONCLUSTERED INDEX [ix_UsedSpace_Log] ON [dbo].[UsedSpace]
(
	[tid_DataBase] ASC
)
INCLUDE([TotalVolume],[LogVolume],[UsedLogVolume]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FullnessDisks] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dbo].[HelpTable] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dbo].[HistoryReglaments] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dbo].[UsedSpace] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dbo].[DataBases]  WITH CHECK ADD  CONSTRAINT [FK_DataBases_DataBaseTypes] FOREIGN KEY([tid_DataBasesType])
REFERENCES [dbo].[DataBaseTypes] ([tid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DataBases] CHECK CONSTRAINT [FK_DataBases_DataBaseTypes]
GO
ALTER TABLE [dbo].[DataBases]  WITH CHECK ADD  CONSTRAINT [FK_DataBases_Disks] FOREIGN KEY([tid_disk])
REFERENCES [dbo].[Disks] ([tid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DataBases] CHECK CONSTRAINT [FK_DataBases_Disks]
GO
ALTER TABLE [dbo].[FullnessDisks]  WITH CHECK ADD  CONSTRAINT [FK_FullnessDisks_Disks] FOREIGN KEY([tid_disk])
REFERENCES [dbo].[Disks] ([tid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FullnessDisks] CHECK CONSTRAINT [FK_FullnessDisks_Disks]
GO
ALTER TABLE [dbo].[HelpTable]  WITH CHECK ADD  CONSTRAINT [FK_HelpTable_FullnessDisk] FOREIGN KEY([tid_FullnessDisk])
REFERENCES [dbo].[FullnessDisks] ([tid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HelpTable] CHECK CONSTRAINT [FK_HelpTable_FullnessDisk]
GO
ALTER TABLE [dbo].[HelpTable]  WITH CHECK ADD  CONSTRAINT [FK_HelpTable_HistoryReglaments] FOREIGN KEY([tid_HistoryReglament])
REFERENCES [dbo].[HistoryReglaments] ([tid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HelpTable] CHECK CONSTRAINT [FK_HelpTable_HistoryReglaments]
GO
ALTER TABLE [dbo].[HelpTable]  WITH CHECK ADD  CONSTRAINT [FK_HelpTable_UsedSpase] FOREIGN KEY([tid_UsedSpase])
REFERENCES [dbo].[UsedSpace] ([tid])
GO
ALTER TABLE [dbo].[HelpTable] CHECK CONSTRAINT [FK_HelpTable_UsedSpase]
GO
ALTER TABLE [dbo].[HistoryReglaments]  WITH CHECK ADD  CONSTRAINT [FK_HistoryReglaments_Reglaments] FOREIGN KEY([tid_Reglament])
REFERENCES [dbo].[Reglaments] ([tid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HistoryReglaments] CHECK CONSTRAINT [FK_HistoryReglaments_Reglaments]
GO
ALTER TABLE [dbo].[Reglaments]  WITH CHECK ADD  CONSTRAINT [FK_Reglaments_ReglamentTypes] FOREIGN KEY([tid_ReglamentType])
REFERENCES [dbo].[ReglamentTypes] ([tid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Reglaments]  WITH CHECK ADD  CONSTRAINT [FK_Reglaments_DataBases] FOREIGN KEY([tid_DataBase])
REFERENCES [dbo].[DataBases] ([tid])
ON DELETE NO ACTION
ON UPDATE NO ACTION
GO
ALTER TABLE [dbo].[Reglaments] CHECK CONSTRAINT [FK_Reglaments_ReglamentTypes]
GO
ALTER TABLE [dbo].[UsedSpace]  WITH CHECK ADD  CONSTRAINT [FK_UsedSpace_DataBases] FOREIGN KEY([tid_DataBase])
REFERENCES [dbo].[DataBases] ([tid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsedSpace] CHECK CONSTRAINT [FK_UsedSpace_DataBases]
GO
ALTER TABLE [dbo].[DataBaseAdmins]  WITH CHECK ADD  CONSTRAINT [check_DataBaseAdminsEmail] CHECK  (([LastName] like '%@%'))
GO
ALTER TABLE [dbo].[DataBaseAdmins] CHECK CONSTRAINT [check_DataBaseAdminsEmail]
GO
ALTER TABLE [dbo].[DataBaseAdmins]  WITH CHECK ADD  CONSTRAINT [check_DataBaseAdminsFirstName] CHECK  (([FirstName] like '%[^ .а-Я]%'))
GO
ALTER TABLE [dbo].[DataBaseAdmins] CHECK CONSTRAINT [check_DataBaseAdminsFirstName]
GO
ALTER TABLE [dbo].[DataBaseAdmins]  WITH CHECK ADD  CONSTRAINT [check_DataBaseAdminsLastName] CHECK  (([LastName] like '%[^ .а-Я]%'))
GO
ALTER TABLE [dbo].[DataBaseAdmins] CHECK CONSTRAINT [check_DataBaseAdminsLastName]
GO
ALTER TABLE [dbo].[FullnessDisks]  WITH CHECK ADD  CONSTRAINT [check_FullnessDisksVolume] CHECK  (([UsedVolume]<[TotalVolume]))
GO
ALTER TABLE [dbo].[FullnessDisks] CHECK CONSTRAINT [check_FullnessDisksVolume]
GO
ALTER TABLE [dbo].[HelpTable]  WITH CHECK ADD  CONSTRAINT [check_HelpTablePercentAvailableVolumeUsedSpace] CHECK  (([PercentAvailableVolumeLog]<[PercentAvailableVolumeData]))
GO
ALTER TABLE [dbo].[HelpTable] CHECK CONSTRAINT [check_HelpTablePercentAvailableVolumeUsedSpace]
GO
ALTER TABLE [dbo].[HistoryReglaments]  WITH CHECK ADD  CONSTRAINT [check_HistoryReglamentsDate] CHECK  (([StartDate]<[FinishDate]))
GO
ALTER TABLE [dbo].[HistoryReglaments] CHECK CONSTRAINT [check_HistoryReglamentsDate]
GO
ALTER TABLE [dbo].[ReglamentTypes]  WITH CHECK ADD  CONSTRAINT [check_ReglamentTypesName] CHECK  (([Name] like '%[^ .а-Я]%'))
GO
ALTER TABLE [dbo].[ReglamentTypes] CHECK CONSTRAINT [check_ReglamentTypesName]
GO
ALTER TABLE [dbo].[ReglamentTypes]  WITH CHECK ADD  CONSTRAINT [checkName] CHECK  (([Name] like '%[^ .а-Я]%'))
GO
ALTER TABLE [dbo].[ReglamentTypes] CHECK CONSTRAINT [checkName]
GO
ALTER TABLE [dbo].[UsedSpace]  WITH CHECK ADD  CONSTRAINT [check_UsedSpaceVolumeData] CHECK  (([DataVolume]<[TotalVolume]))
GO
ALTER TABLE [dbo].[UsedSpace] CHECK CONSTRAINT [check_UsedSpaceVolumeData]
GO
ALTER TABLE [dbo].[UsedSpace]  WITH CHECK ADD  CONSTRAINT [check_UsedSpaceVolumeLog] CHECK  (([LogVolume]<[TotalVolume]))
GO
ALTER TABLE [dbo].[UsedSpace] CHECK CONSTRAINT [check_UsedSpaceVolumeLog]
GO
USE [master]
GO
ALTER DATABASE [HelpDB] SET  READ_WRITE 
GO
