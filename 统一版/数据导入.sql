USE master;

-- Drop database
IF DB_ID('ml') IS NOT NULL DROP DATABASE ml;

CREATE DATABASE ml;
use ml;
create table Movie(
	movieId  int primary key,
	title nvarchar(max),
	genres nvarchar(max)
)
create table Tags
(
	userId int,
	movieId int,
	tag nvarchar(max),
	timestamp int
)

create table Ratings
(
	userId int,
	movieId int,
	rating float,
	timestamp int
	PRIMARY key (userId, movieId)
)

BULK INSERT Movie
FROM  'E:\ml-latest\movies.csv'
WITH
(
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
	FORMAT = 'CSV',
	CODEPAGE='65001',
	Datafiletype = 'widechar',
	--FIELDTERMINATOR = ',',
	--ROWTERMINATOR = '\n',
	FirstRow = 2 
)