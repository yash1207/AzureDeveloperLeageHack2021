/****** Object:  StoredProcedure [the_night_owls].[sp_BlobsMetaData]    Script Date: 4/11/2021 11:19:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------------------------------------------------------------------*/
/*========================================================================================================================================================
       BUSINESS RULES 
================================================================================================================================================================ 
              1. Inputs 
                     Not Required 
              2. Outputs 
                     NA 
              3. Internal Actions 
                     a. This procedure used to populate BlobsList and BlobAttributes
-------------------------------------------------------------------------------------------------------------------------------------*/
/*======================================================================================================================================================== 
 
  
Parameter Info 
   Not Required 
  
Return Info 
   NA 
  
Test Scripts   
   EXEC [the_night_owls].[sp_BlobsMetaData]
  
Revision History: 
Date				Author				Description 
==================================================== 
10/04/2021			The Night Owls			Created
=================================================================*/
ALTER PROCEDURE [the_night_owls].[sp_BlobsMetaData]
AS
BEGIN TRY
	SET NOCOUNT ON
	   
	/*Code Begin*/

	IF NOT EXISTS (SELECT * FROM sys.objects 
	WHERE (OBJECT_ID(N'[the_night_owls].[BlobsList]')>0 AND type in (N'U'))
		AND (OBJECT_ID(N'[the_night_owls].[BlobAttributes]')>0 AND type in (N'U')))
	BEGIN
	
		DROP TABLE IF EXISTS [the_night_owls].[BlobsList]
		DROP TABLE IF EXISTS [the_night_owls].[BlobAttributes]
	
		CREATE TABLE [the_night_owls].[BlobsList] (
		 [Blob_Key] [bigint] NOT NULL,
		 [Blob_Path] [varchar](255) NOT NULL
		)

		CREATE TABLE [the_night_owls].[BlobAttributes] (
		 [Blob_Key] [bigint] NOT NULL,
		 [Creation_Time] [varchar](255) NULL,
		 [Access_Time] [varchar](255) NULL,
		 [Container_Name] [varchar](255) nULL,
		 [File_Type] [varchar](255) NULL,
		 [Modified_Time] [varchar](255) NULL,
		 [Current_Tier] [varchar](255) NULL,
		 [Size] [bigint] NULL,
		 [Scanned_Time] [varchar](255) NULL,
		 [Is_Recent_Record] [bit] NULL
		)

	END

	DECLARE @max_number bigint
	SELECT @max_number=ISNULL(MAX([Blob_Key]),0) FROM [the_night_owls].[BlobsList]

	DROP TABLE IF EXISTS #Temp;
	SELECT DISTINCT A.[Blob_Path]
	INTO #Temp
	FROM [the_night_owls].[StorageMetadata] A WITH (NOLOCK)
	LEFT JOIN [the_night_owls].[BlobsList] B WITH (NOLOCK)
		ON A.[Blob_Path] = B.[Blob_Path]
	WHERE B.[Blob_Path] IS NULL

	INSERT INTO [the_night_owls].[BlobsList]
	WITH (TABLOCK) (
		[Blob_Key] 
		,[Blob_Path]
	)
	SELECT (ROW_NUMBER()OVER(ORDER BY [Blob_Path]) +  @max_number) AS [Blob_Key]
		,[Blob_Path]
	FROM #Temp

	-------------Attributes-------------
	DELETE C
	FROM [the_night_owls].[StorageMetadata] A WITH (NOLOCK)
	INNER JOIN [the_night_owls].[BlobsList] B WITH (NOLOCK)
	ON A.[Blob_Path] = B.[Blob_Path]
	INNER JOIN [the_night_owls].[BlobAttributes] C WITH (NOLOCK)
	ON B.[Blob_Key] = C.[Blob_Key] 
		AND C.[Is_Recent_Record] = 1
		AND CONVERT(DATE,A.[Access_Time]) = CONVERT(DATE,C.[Access_Time]) 
		AND CONVERT(DATE,A.[Modified_Time]) = CONVERT(DATE,C.[Modified_Time]) 
		AND CONVERT(DATE,A.[Creation_Time]) = CONVERT(DATE,C.[Creation_Time])
	
	DROP TABLE IF EXISTS #TempAttributes
	SELECT B.[Blob_Key]
		,A.[Creation_Time]
		,A.[Access_Time]
		,A.[Container_Name]
		,A.[File_Type]
		,A.[Modified_Time]
		,A.[Current_Tier]
		,A.[Size]
		,A.[Scanned_Time]
	INTO #TempAttributes
	FROM [the_night_owls].[StorageMetadata] A WITH (NOLOCK)
	INNER JOIN [the_night_owls].[BlobsList] B WITH (NOLOCK)
	ON A.[Blob_Path] = B.[Blob_Path]
	UNION ALL
	SELECT A.[Blob_Key]
		,A.[Creation_Time]
		,A.[Access_Time]
		,A.[Container_Name]
		,A.[File_Type]
		,A.[Modified_Time]
		,A.[Current_Tier]
		,A.[Size]
		,A.[Scanned_Time]
	FROM [the_night_owls].[BlobAttributes] A WITH (NOLOCK)

	TRUNCATE TABLE [the_night_owls].[BlobAttributes];
	INSERT INTO [the_night_owls].[BlobAttributes]
	WITH (TABLOCK) (
		[Blob_Key]
      ,[Creation_Time]
      ,[Access_Time]
      ,[Container_Name]
      ,[File_Type]
      ,[Modified_Time]
      ,[Current_Tier]
	  ,[Size]
      ,[Scanned_Time]
	  ,[Is_Recent_Record]
	)
	SELECT A.[Blob_Key]
		,A.[Creation_Time]
		,A.[Access_Time]
		,A.[Container_Name]
		,A.[File_Type]
		,A.[Modified_Time]
		,A.[Current_Tier]
		,A.[Size]
		,A.[Scanned_Time]
		,CASE WHEN (ROW_NUMBER() OVER(PARTITION BY Blob_Key ORDER BY Access_Time DESC,Scanned_Time DESC)) = 1 THEN 1 ELSE 0 END AS [Is_Recent_Record]
	FROM #TempAttributes A

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ISNULL(ERROR_MESSAGE(), 'NULL Message');
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY();;
	DECLARE @ErrorState INT = ERROR_STATE();

	RAISERROR (
			@ErrorMessage
			,@ErrorSeverity
			,@ErrorState
			)
END CATCH
