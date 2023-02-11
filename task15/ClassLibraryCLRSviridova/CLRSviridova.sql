CREATE FUNCTION SplitString (@text NVARCHAR(max), @delimiter nchar(1))
RETURNS @Tbl TABLE (part nvarchar(max), ID_ORDER integer) AS
BEGIN
  declare @index integer
  declare @part  nvarchar(max)
  declare @i   integer
  set @index = -1
  set @i=1
  while (LEN(@text) > 0) begin
    set @index = CHARINDEX(@delimiter, @text)
    if (@index = 0) AND (LEN(@text) > 0) BEGIN
      set @part = @text
      set @text = ''
    end else if (@index > 1) begin
      set @part = LEFT(@text, @index - 1)
      set @text = RIGHT(@text, (LEN(@text) - @index))
    end else begin
      set @text = RIGHT(@text, (LEN(@text) - @index))
    end
    insert into @Tbl(part, ID_ORDER) values(@part, @i)
    set @i=@i+1
  end
  RETURN
END
go


select part 
into #tmpIDs 
from SplitString('11,22,33,44', ',')

select *
from #tmpIDs
go
-------------------------------------------------------------------------------
SELECT name, principal_id, assembly_id, clr_name, permission_set, permission_set_desc, is_visible, create_date, modify_date, is_user_defined
FROM sys.assemblies;
GO
-------------------------------------------------------------------------------
sp_configure 'clr enabled', 1
go
reconfigure
go

CREATE ASSEMBLY CLRFunctions FROM 'C:\work\ClassLibraryCLRSviridova.dll'
go


CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nchar](1))
RETURNS TABLE (
part nvarchar(max),
ID_ODER int
) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [CLRFunctions].[ClassLibraryCLRSviridova.UserDefinedFunctions].SplitString
go

select *
from SplitStringCLR ('11,22,33,44', ',')