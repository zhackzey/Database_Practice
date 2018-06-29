--�ȴ����û���Ӱ�������������Ԫ����������
use ml;
create table User_Movie_Matrix(
	rowid int ,
	colid int,
	rating float
)


--����Ratings���ÿһ��Ԫ�飬��ѯ���ű�RowId2UserId ��ColId2MovieId ����ȡ��Ӧ��rowid �� colid,�ٰ��µ���Ԫ����뵽�������
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

insert into User_Movie_Matrix
select T.rowid, T.colid ,T.rating
from 
(select dbo.ColId2MovieId.colid,dbo.RowId2UserId.rowid, dbo.Ratings.rating
from dbo.Ratings,dbo.ColId2MovieId,dbo.RowId2UserId
where dbo.Ratings.movieId = dbo.ColId2MovieId.movieid
and dbo.Ratings.userId = dbo.RowId2UserId.userid
) as T