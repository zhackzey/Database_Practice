--先创建用户电影关联矩阵表，用三元组存这个矩阵
/*
create table User_Movie_Matrix(
	rowid int ,
	colid int,
	rating float
)
*/

--对于Ratings里的每一个元组，查询两张表RowId2UserId 和ColId2MovieId 来换取对应的rowid 和 colid,再把新的三元组插入到矩阵表中
/*
declare @userId int
declare @movieId int
declare @rowid int
declare @colid int
declare @rating float
declare my_curs cursor for
	select userId, movieId , rating 
	from Ratings
open my_curs
fetch next from my_curs into @userId, @movieId, @rating
while @@FETCH_STATUS = 0
	begin
		select @colid = colid
		from ColId2MovieId
		where movieid = @movieId 

		select @rowid = rowid 
		from RowId2UserId
		where userid = @userId

		insert into User_Movie_Matrix select @rowid, @colid,@rating
		fetch next from my_curs into @userId, @movieId, @rating
	end
close my_curs
deallocate my_curs
*/ 