use ml;
--先创建用户电影关联矩阵表，用三元组存这个矩阵
if exists (select * from sysobjects where id=object_id('User_Movie_Matrix'))
	drop table User_Movie_Matrix

create table User_Movie_Matrix(
	rowid int ,
	colid int,
	rating float PRIMARY KEY (rowid,colid)
)

insert into User_Movie_Matrix
select T.rowid, T.colid ,T.rating
from 
(select dbo.ColId2MovieId.colid,dbo.RowId2UserId.rowid, dbo.Ratings.rating
from dbo.Ratings,dbo.ColId2MovieId,dbo.RowId2UserId
where dbo.Ratings.movieId = dbo.ColId2MovieId.movieid
and dbo.Ratings.userId = dbo.RowId2UserId.userid
) as T