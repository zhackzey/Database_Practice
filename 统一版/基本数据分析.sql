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

-- �г���Ӱ�û���������һ����ֵ���Զ�����ƽ���û�����������ߣ���ͣ�ǰʮ�ĵ�Ӱ
-- ��������� �����Ҫ����͸�ΪASC���ɣ�
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

-- �г�ÿ��genre�¹�Ӱ�û���������һ����ֵ(300)��ƽ���û�����������ߣ���ͣ�ǰʮ�ĵ�Ӱ
select distinct  movieId_genre.genre, newratings.movieId, AVG(rating) as average_rating
into temp
  from movieId_genre, newratings
  where movieId_genre.movieId = newratings.movieId
  and newratings.movieId in (
          select newratings.movieId
          from newratings
          group by newratings.movieId having count(newratings.movieId) > 300
        )
  group by movieId_genre.genre, newratings.movieId

select *
from temp a
where 10 > (
  select count(*)
  from temp b where b.genre = a.genre and b.average_rating > a.average_rating
)
order by a.genre, a.average_rating
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

-- ��һ��ʵ�ַ�ʽ�����ո����û��������ض��û������Ӱ���ֶ����������Ȼ����жԱ�

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