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

-- 列出观影用户数量超过一定阈值（自定）且平均用户评分排在最高（最低）前十的电影
-- 下面求最高 （如果要求最低改为ASC即可）
select top 10 newratings.movieId, AVG(rating) as AVG_Rating, Audience_Number
from newratings, 
	(select movieId, Audience_Number
		from (select Tag_Number+Rating_Number as Audience_Number, T.movieId as movieId
				from
				(
					select count(movieId) as Tag_Number, movieId
					from newtags
					group by movieId
				)  T 
				full outer join 
				(
					select count(movieId) as Rating_Number, movieId
					from newratings
					group by movieId
				)  R
				on T.movieId = R.movieId
				where Tag_Number  is not NULL and  Rating_Number is not NULL
			) as Audience
		where Audience_Number > 300 
	) as MovieHaveMoreThan300
where MovieHaveMoreThan300.movieId = newratings.movieId
group by newratings.movieId, Audience_Number
order by AVG(rating) desc

-- 列出每个genre下观影用户数量超过一定阈值(300)且平均用户评分排在最高（最低）前十的电影
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
	*/
select movieId_genre.genre, newratings.movieId, AVG(rating) as AVG_Rating
from newratings ,movieId_genre
where newratings.movieId in
	(select top 10 newratings.movieId
	from newratings, movieId_genre
	where newratings.movieId = movieId_genre.movieId
	and newratings.movieId in	(select movieId
								from (select Tag_Number+Rating_Number as Audience_Number, T.movieId as movieId
									 from
									(
									select count(movieId) as Tag_Number, movieId
									from newtags
									group by movieId
									)  T 
									full outer join 
									(
									select count(movieId) as Rating_Number, movieId
									from newratings
									group by movieId
									)  R
									on T.movieId = R.movieId
									where Tag_Number  is not NULL and  Rating_Number is not NULL
									) as Audience
								where Audience_Number > 300)
	group by movieId_genre.genre, newratings.movieId
	order by AVG(rating) DESC
	)
group by movieId_genre.genre, newratings.movieId
order by movieId_genre.genre
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

-- 另一种实现方式：依照个体用户来，将特定用户两类电影评分都计算出来，然后进行对比

if exists (select * from sysobjects where id=object_id('User_Tag_AVG'))
	drop table User_Tag_AVG
create table User_Tag_AVG(userId int , AVG_Rating_WithTag float)

insert into User_Tag_AVG
select T.userId, T.AVG_Rating_WithTag
from (select dbo.newratings.userId, AVG(rating) as AVG_Rating_WithTag
	 from dbo.newratings
	 where exists 
		(select userId,movieId
		from dbo.newtags 
		where userId = dbo.newratings.userId and movieId = dbo.newratings.movieId
		)
	 group by dbo.newratings.userId
	) as T

if exists (select * from sysobjects where id=object_id('User_NoTag_AVG'))
	drop table User_NoTag_AVG
create table User_NoTag_AVG(userId int , AVG_Rating_WithoutTag float)
insert into User_NoTag_AVG
select T.userId, T.AVG_Rating_WithoutTag
from (select dbo.newratings.userId, AVG(rating) as AVG_Rating_WithoutTag
	 from dbo.newratings
	 where not exists 
		(select userId,movieId
		from dbo.newtags 
		where userId = dbo.newratings.userId and movieId = dbo.newratings.movieId
		)
	 group by dbo.newratings.userId
	) as T

select User_Tag_AVG.userid , User_Tag_AVG.AVG_Rating_WithTag, User_NoTag_AVG.AVG_Rating_WithoutTag
from User_Tag_AVG, User_NoTag_AVG 
where User_Tag_AVG.userId = User_NoTag_AVG.userId
order by User_Tag_AVG.userid