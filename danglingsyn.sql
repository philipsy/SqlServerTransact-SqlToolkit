SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[danglingsyn]
--DROP PROCEDURE [dbo].[danglingsyn]
--ALTER PROCEDURE [dbo].[danglingsyn]
AS
/*
provides list of "dangling" synonyms which no longer have a matching base object
danglingsyn
*/
BEGIN
	CREATE TABLE #SynonymName
	(
	unmatched_synonym sysname COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY 
	,base_object_name sysname COLLATE DATABASE_DEFAULT NOT NULL
	,space_replaced_base_name sysname COLLATE DATABASE_DEFAULT NOT NULL
	)

	INSERT INTO
	#SynonymName
	(
	unmatched_synonym
	,base_object_name
	,space_replaced_base_name
	)
	SELECT
	name
	,base_object_name
	,REPLACE(base_object_name, ' ', '') as space_trimmed_name
	FROM sys.synonyms s

	SELECT * FROM #SynonymName #s
	WHERE Not EXISTS(SELECT Null FROM sys.objects so WHERE #s.space_replaced_base_name = '[' + SCHEMA_NAME(so.schema_id) + '].[' + so.name + ']')

END
GO
