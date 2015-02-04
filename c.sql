/****** Object:  StoredProcedure [DEV].[c]    Script Date: 04/02/2015 10:08:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--CREATE PROCEDURE [dbo].[c]
ALTER PROCEDURE [dbo].[c]
@i_TableName sysname = Null
,@i_Debug int = 0
AS
/* SAMPLE CALLS
c tblBook
c 'tblBook' 
c 'dbo.tblBook'
--development--
c tblBook, 1
c 'dbo.tblBook', 1
--testing--
c 
c '      ', 1
c 'dbo.', 1
c '.tblBook', 1
c 'Non-existent', 1
*/
SET NOCOUNT ON

DECLARE @Msg nvarchar(4000)
DECLARE @SchemaName sysname
DECLARE @TableName sysname
DECLARE @TextOutput nvarchar(4000) = ''
DECLARE @crlf char(2) = CHAR(13) + CHAR(10)

--validate inputs--
IF COALESCE(LTRIM(RTRIM(@i_TableName)), '') = ''
BEGIN
	SET @Msg = 'USAGE: @i_TableName must be passed in.'
	+ 'It should be prefixed with the schema name ("{Schema}.{Table}") if the table exists in more than one schema.'
	+ @crlf + 'Set @i_Debug > 0 only if you are modifying the code of this procedure'
END
ELSE IF @i_TableName Like '%.%' And (@i_TableName Like '.%' Or @i_TableName Like '.%')
BEGIN
	SET @Msg = 'Schema Name must be passed in.'
END
ELSE IF @i_TableName Like '%.%' And (@i_TableName Like '.%' Or @i_TableName Like '%.')
BEGIN
	SET @Msg = 'Table Name must be passed in.'
END

IF @Msg Is Not Null
BEGIN
	RAISERROR(@Msg, 16, 1, 1)
	RETURN
END

DECLARE @DotPos int = CHARINDEX('.', @i_TableName)
IF @DotPos = 0
--table name passed in with no schema
BEGIN
	SET @TableName = @i_TableName
	IF @i_Debug > 0 PRINT 'Table Name:' + @TableName
END
ELSE
BEGIN
	SET @SchemaName = LEFT(@i_TableName, @DotPos-1)
	IF @i_Debug > 1 PRINT 'Schema Name:' + @SchemaName 

	IF SCHEMA_ID(@SchemaName) Is Not Null
	BEGIN
		IF @i_Debug > 0 PRINT  'Schema name:' + @SchemaName
		SET @TableName = RIGHT(@i_TableName, LEN(@i_TableName) - LEN(@SchemaName) -1)
		IF @i_Debug > 0 PRINT 'Table name:' + @TableName

	END
	ELSE
	BEGIN
		SET @Msg = 'Schema' + ' ' + @SchemaName + ' ' + 'not found'
		RAISERROR(@Msg, 16, 1, 1)
		RETURN

	END

END

--read metadata for column names--
SELECT name + CASE WHEN column_id < MAX(column_id) OVER (PARTITION BY object_id) THEN ',' ELSE '' END
FROM sys.columns
WHERE OBJECT_NAME(object_id) = @TableName
ORDER BY column_id

IF @@ROWCOUNT = 0
BEGIN
	SET @Msg = 'Table' + ' ' + '"' + COALESCE(@TableName, '{Null}') + '"' + ' ' + 'not found.'
	RAISERROR(@Msg, 16, 1, 1)
END


GO


