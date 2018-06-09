--下面这段用于生成colid  到movieid的转换表ColId2MovieId
/*
declare @i int
declare @movieid int
set @i = 1
declare my_curs cursor for
	select movieId
	from dbo.Movie
open my_curs
fetch next from my_curs into @movieid
while @@FETCH_STATUS = 0
	begin 
		insert into ColId2MovieId select @i, @movieid
		set @i =@i +1
		fetch next from my_curs into @movieid
	end
close my_curs
deallocate my_curs
*/

--下面这段用于生成rowid  到userid的转换表RowId2UserId
declare @i int
declare @userid int
set @i = 1
declare my_curs cursor for
	select distinct userid
	from dbo.Ratings
	order by userid ASC
open my_curs
fetch next from my_curs into @userid
while @@FETCH_STATUS = 0
	begin 
		insert into RowId2UserId select @i, @userid
		set @i =@i +1
		fetch next from my_curs into @userid
	end
close my_curs
deallocate my_curs