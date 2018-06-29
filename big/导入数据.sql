use ml_big;

BULK INSERT Movie
FROM  'E:\ml-latest\movies.csv'
WITH
(
    /*FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK*/
	FORMAT = 'CSV',
	CODEPAGE='65001',
	Datafiletype = 'widechar',
	--FIELDTERMINATOR = ',',
	--ROWTERMINATOR = '\n',
	FirstRow = 2 
)
BULK INSERT Tags
FROM 'E:\ml-latest\tags.csv'
WITH
(
    /*FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK*/
	FORMAT = 'CSV',
	CODEPAGE='65001',
	Datafiletype = 'widechar',
	--FIELDTERMINATOR = ',',
	--ROWTERMINATOR = '\n',
	FirstRow = 2 
)
BULK INSERT Ratings
FROM 'E:\ml-latest\ratings.csv'
WITH
(
    /*FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK*/
	FORMAT = 'CSV',
	CODEPAGE='65001',
	Datafiletype = 'widechar',
	--FIELDTERMINATOR = ',',
	--ROWTERMINATOR = '\n',
	FirstRow = 2 
)