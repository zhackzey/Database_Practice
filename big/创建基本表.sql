use ml_big;
create table Movie(
	movieId  int ,
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
)