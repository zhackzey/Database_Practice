-- 基本数据分析
use ml;

-- 统计每个genre下的电影数量
select  S.genre Movie_Genre, count(*) as Total_Number
from dbo.movieId_genre S
group by S.genre
order by genre ASC

-- 统计每个genre下电影的平均用户评分
select  T.genre Movie_Genre, avg(T.rating) as Average_Rating 
from 
	(select dbo.newratings.movieId , dbo.newratings.rating , dbo.movieId_genre.genre
	from dbo.newratings , dbo.movieId_genre
	where dbo.newratings.movieId = dbo.movieId_genre.movieId) as T
group by T.genre
order by T.genre ASC

-- 注释：下面的这两个函数第一次创建之后就要注释掉了，不允许重复创建函数
 
/*  给定movieId,返回观影用户人数
	观影用户：给电影有过评分或者打过标签
*/
/*
go
create function Audience_Number(@movieId int)
returns int
as
begin
declare @num int
set @num = (select count(T.userId)
			from
				((select dbo.newratings.userId
				from dbo.newratings
				where dbo.newratings.movieId= @movieId)
				union 
				(select dbo.newtags.userId
				from dbo.newtags
				where dbo.newtags.movieId = @movieId))
				as T
			)
return @num
end
*/

/*	给定movieId，返回平均用户评分
*/
/*
go
create function AVG_Rating(@movieId int)
returns float
as 
begin
declare @rating float
set @rating =  (select AVG(dbo.newratings.rating)
				from dbo.newratings
				where dbo.newratings.movieId = @movieId 
				)
return @rating
end

go
*/

-- 列出观影用户数量超过一定阈值（自定）且平均用户评分排在最高（最低）前十的电影
/*
go
select top 10 *
from 
	(select T.movieId , T.title , dbo.AVG_Rating(T.movieId) as AVG_Rating 
	 from dbo.movie_title_pub_date T
	 where dbo.Audience_Number(T.movieId) > 0.05 * (select count(distinct userId) from dbo.newratings)
	) as S
order by S.AVG_Rating DESC 

select top 10 *
from 
	(select T.movieId , T.title , dbo.AVG_Rating(T.movieId) as AVG_Rating 
	 from dbo.movie_title_pub_date T
	 where dbo.Audience_Number(T.movieId) > 0.05 * (select count(distinct userId) from dbo.newratings)
	) as S
order by S.AVG_Rating ASC
*/

-- 列出每个genre下观影用户数量超过一定阈值且平均用户评分排在最高（最低）前十的电影
-- 这个真的比较慢。。
/*
select *
from 
	(select distinct dbo.movieId_genre.genre from dbo.movieId_genre) as GENRES
cross apply
	(select top 10 R.movieId,R.title, dbo.AVG_Rating(R.movieId) as AVG_Rating
	from dbo.movie_title_pub_date R, dbo.movieId_genre G
	where R.movieId = G.movieId 
	and G.genre = GENRES.genre
	and  dbo.Audience_Number(R.movieId)>20
	order by dbo.AVG_Rating(R.movieId) DESC) as S

select *
from 
	(select distinct dbo.movieId_genre.genre from dbo.movieId_genre) as GENRES
cross apply
	(select top 10 R.movieId,R.title, dbo.AVG_Rating(R.movieId) as AVG_Rating
	from dbo.movie_title_pub_date R, dbo.movieId_genre G
	where R.movieId = G.movieId 
	and G.genre = GENRES.genre
	and  dbo.Audience_Number(R.movieId)>20
	order by dbo.AVG_Rating(R.movieId) ASC) as S
*/

-- 在用户评分过的电影中，有些是打过标签的，有些则没有，比较一下用户在这两类电影评分上的不同  
-- 实现方式：选出两类电影，求这两类电影的平均分
select sum(rating)/count(*) as "没有打过标签的平均分"
from dbo.newratings
where not EXISTS
	(
		select *
		from dbo.newtags
		where dbo.newtags.movieId = dbo.newratings.movieId
	)

select sum(rating)/count(*) as "打过标签的平均分"
from dbo.newratings
where  EXISTS
	(
		select *
		from dbo.newtags
		where dbo.newtags.movieId = dbo.newratings.movieId
	)
-- 可以看出打过标签的平均分比较高