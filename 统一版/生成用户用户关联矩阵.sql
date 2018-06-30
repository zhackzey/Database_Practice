use ml;
create table User_User_Matrix(
	userid1 int ,
	userid2 int,
	relation float PRIMARY KEY (userid1,userid2)
)

if exists (select * from sysobjects where id=object_id('twoNorm'))
	drop table twoNorm

create table twoNorm(userid int primary key, s float)

insert into twoNorm
	select userId, sum(rating*rating) sq from newratings group by userId

go 

if exists (select * from sysobjects where id = object_id('user_RatingNum'))
	drop table user_RatingNum

create table user_RatingNum(userid int primary key, s int)

insert into user_RatingNum
	select userId, count(userId) from newratings group by userId

if exists(select * from sysobjects where xtype = 'tf' and name ='TOP10')
	drop function TOP10
go 

create function TOP10(@i int)
returns @t table (id1 int, id2 int, relation float)
as 
begin 
	insert into @t
	select top 10 r1.userId id1, r2.userId id2, sum(r1.rating*r2.rating)/((select s from twoNorm where userId=r2.userId)*(select s from twoNorm where userId=r1.userId)) relation from newratings r1, newratings r2
	where r1.userId=@i and r2.userId != r1.userId and r1.movieId = r2.movieId and (select s from user_RatingNum where r2.userId=user_RatingNum.userId) > 3000
	group by r1.userId, r2.userId
	order by relation desc
	return
end 
go 

insert into User_User_Matrix
select id1, id2, relation from (select distinct userId from newratings where (select s from user_RatingNum where newratings.userId=user_RatingNum.userId) > 3000) as A cross apply TOP10(A.userId) as B
