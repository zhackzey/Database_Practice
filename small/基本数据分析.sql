-- �������ݷ���
use ml;

-- ͳ��ÿ��genre�µĵ�Ӱ����
select  S.genre Movie_Genre, count(*) as Total_Number
from dbo.movieId_genre S
group by S.genre
order by genre ASC

-- ͳ��ÿ��genre�µ�Ӱ��ƽ���û�����
select  T.genre Movie_Genre, avg(T.rating) as Average_Rating 
from 
	(select dbo.newratings.movieId , dbo.newratings.rating , dbo.movieId_genre.genre
	from dbo.newratings , dbo.movieId_genre
	where dbo.newratings.movieId = dbo.movieId_genre.movieId) as T
group by T.genre
order by T.genre ASC

-- ע�ͣ������������������һ�δ���֮���Ҫע�͵��ˣ��������ظ���������
 
/*  ����movieId,���ع�Ӱ�û�����
	��Ӱ�û�������Ӱ�й����ֻ��ߴ����ǩ
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

/*	����movieId������ƽ���û�����
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

-- �г���Ӱ�û���������һ����ֵ���Զ�����ƽ���û�����������ߣ���ͣ�ǰʮ�ĵ�Ӱ
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

-- �г�ÿ��genre�¹�Ӱ�û���������һ����ֵ��ƽ���û�����������ߣ���ͣ�ǰʮ�ĵ�Ӱ
-- �����ıȽ�������
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

-- ���û����ֹ��ĵ�Ӱ�У���Щ�Ǵ����ǩ�ģ���Щ��û�У��Ƚ�һ���û����������Ӱ�����ϵĲ�ͬ  
-- ʵ�ַ�ʽ��ѡ�������Ӱ�����������Ӱ��ƽ����
select sum(rating)/count(*) as "û�д����ǩ��ƽ����"
from dbo.newratings
where not EXISTS
	(
		select *
		from dbo.newtags
		where dbo.newtags.movieId = dbo.newratings.movieId
	)

select sum(rating)/count(*) as "�����ǩ��ƽ����"
from dbo.newratings
where  EXISTS
	(
		select *
		from dbo.newtags
		where dbo.newtags.movieId = dbo.newratings.movieId
	)
-- ���Կ��������ǩ��ƽ���ֱȽϸ�