use ml;

--将Tags表中的时间戳timestamp转为数据库中的日期
if exists( select * from sysobjects where id=object_id('newtags') )
	drop table newtags

select userId,movieId,tag,DATEADD(s, timestamp+8*3600, '1970-01-01 00:00:00') time
into newtags
from Tags

--将Ratings表中的时间戳timestamp转为数据库中的日期
if exists( select * from sysobjects where id=object_id('newratings') )
	drop table newratings

select userId,movieId,rating,DATEADD(s, timestamp+8*3600, '1970-01-01 00:00:00') time
into newratings
from Ratings


--转为上映日期表
if exists( select * from sysobjects where id=object_id('movie_title_pub_date') )
	drop table movie_title_pub_date

select movieId, substring(title, 0, len(title) - 5) as title, substring(title, PATINDEX('%([0-9][0-9][0-9][0-9])%', title) + 1, 4) as pub_date
into movie_title_pub_date from Movie
where len(title) >5


update Movie set genres = genres +'|';
with movieId_genres as (
  select
    movieId,
    genres,
    charindex('|', genres)     sta,
    charindex('|', genres) - 1 lens
  from Movie
  union all
  select
    movieId,
    genres,
    charindex('|', genres, sta + 1)             sta,
    charindex('|', genres, sta + 1) - sta - 1 lens
  from movieId_genres
  where sta != 0)

--select * from moveId_genres


select movieId, substring(genres, sta - lens, lens) as genre into movieId_genre  from movieId_genres
where sta != 0 order by movieId ;
go
-- 生成RowId2UserId
if exists(select * from sysobjects where id=object_id('RowId2UserId') )
	drop table RowId2UserId

create table RowId2UserId
(
rowid int ,
userid int 
)
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
go
-- 生成ColId2MovieId
if exists(select * from sysobjects where id=object_id('ColId2MovieId') )
	drop table ColId2MovieId
create table ColId2MovieId
(
colid int,
movieid int
)


--下面这段用于生成colid  到movieid的转换表ColId2MovieId

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


