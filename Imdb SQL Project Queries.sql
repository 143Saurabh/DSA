use imdb;
/*SEGMENT 1*/
#	What are the different tables in the database and how are they connected to each other in the database?
/*Ans :- */ show tables; /* all the tables are connected to each other through primary & foreign key*/
#	Find the total number of rows in each table of the schema.
/*Ans :- */ select count(*) as Row_Count from director_mapping;
/*Ans :- */ select count(*) as Row_Count from genre;
/*Ans :- */ select count(*) as Row_Count from movie;
/*Ans :- */ select count(*) as Row_Count from ratings;
/*Ans :- */ select count(*) as Row_Count from role_mapping;
#	Identify which columns in the movie table have null values.
/* Ans :-*/ select * from movie order by id asc;
/*SEGMENT 2*/
# -	Determine the total number of movies released each year and analyse the month-wise trend.
/* Ans :- */ select year, month(date_published) as release_month,count(*) as movies_count from movie
			 group by year,release_month
             order by year asc , movies_count desc;
# - Calculate the number of movies produced in the USA or India in the year 2019
/* Ans :- */ select country ,count(*) as Movies_count,Year from movie where year=2019 and country in ('USA','India')
             group by country;
/*SEGMENT 3*/
#-	Retrieve the unique list of genres present in the dataset
/* Ans :-*/ Select distinct genre  from genre;          
#-	Identify the genre with the highest number of movies produced overall.
/* Ans :- */ Select genre,count(*) as movie_count from movie
             inner join genre on genre.movie_id = movie.id
             group by genre
             order by movie_count desc limit 1;             
#-	Determine the count of movies that belong to only one genre.
/*Ans :- */ Select count(*) as movie_count from (select movie_id from genre group by movie_id having count(*)=1) as Single_genre_movies;
#-	Calculate the average duration of movies in each genre.
/* Ans :-*/ Select genre,avg(duration) as duration_avg from movie
            inner join genre on genre.movie_id = movie.id
            group by genre  ;
#-	Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
SELECT genre, movie_count, RANK() OVER (ORDER BY movie_count DESC) AS genre_rank
FROM (
  SELECT genre, COUNT(*) AS movie_count
  FROM movie
  inner join genre on genre.movie_id = movie.id
  GROUP BY genre
) AS genre_counts ;
/*SEGMENT 4*/
#-	Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
/* Ans :-*/ select max(avg_rating) as max_avg_rating,max(total_votes) as max_votes
 , max(median_rating) as max_median_rating 
  ,min(avg_rating) as min_avg_rating,min(total_votes) as min_votes
 , min(median_rating) as min_median_rating  from ratings ;
#-	Identify the top 10 movies based on average rating.
/* Ans :- */ Select title as movie_name ,avg_rating from ratings
			inner join movie on movie.id = ratings.movie_id	
			order by avg_rating desc limit 10;
#-	Summarise the ratings table based on movie counts by median ratings.
/* Ans :- */ SELECT median_rating, COUNT(*) AS movie_count from ratings
             group by median_rating
             order by median_rating desc;
#-	Identify the production house that has produced the most number of hit movies (average rating > 8).
/* Ans :- */ Select production_company,avg_rating from ratings 
			 inner join movie on movie.id=ratings.movie_id
             where avg_rating >8
             order by ratings.avg_rating desc;
#-	Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
/* Ans :-*/ select count(*) as movie_count,genre.genre from movie 
			inner join ratings on ratings.movie_id = movie.id
            inner join genre on genre.movie_id = movie.id
            where month(date_published)=3 and Year=2017 
            and country='USA' and ratings.total_votes > 1000
            group by genre;
#-	Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.
/* Ans :-*/  select distinct m.title,g.genre,r.avg_rating from genre g
			 inner join movie m on m.id = g.movie_id
             inner join ratings r on r.movie_id = m.id
             where m.title like 'The%' and r.avg_rating > 8
             group by g.genre,m.title,r.avg_rating
             order by r.avg_rating desc;
/*SEGMENT 5*/            
#-	Identify the columns in the names table that have null values.
/* Ans :- */ 
#-	Determine the top three directors in the top three genres with movies having an average rating > 8.
/* Ans :- */ SELECT N.name, G.genre,R.avg_rating
			 FROM director_mapping DM
			INNER JOIN genre G ON G.movie_id = DM.movie_id
            INNER JOIN ratings R ON R.movie_id = DM.movie_id
            INNER JOIN movie M ON M.id = DM.movie_id
            INNER JOIN names N ON N.id = DM.name_id
							WHERE R.avg_rating > 8
			GROUP BY G.genre, N.name, R.avg_rating 
            ORDER BY R.avg_rating DESC
			LIMIT 3;
#-	Find the top two actors whose movies have a median rating >= 8.
/*Ans :- */ select N.name,R.median_rating from role_mapping RM
            inner join movie M on M.id = RM.movie_id
            inner join ratings R on R.movie_id = M.id
            inner join names N on N.id = RM.name_id
            where R.median_rating =8 or R.median_rating >8
            order by R.median_rating asc limit 2;
#-	Identify the top three production houses based on the number of votes received by their movies.
/* Ans :-*/  select M.title as Movie_name,M.production_company,R.total_votes from movie M
             inner join ratings R on R.movie_id = M.id
             group by M.title,M.production_company,R.total_votes
             order by R.total_votes DESC limit 3;
#-	Rank actors based on their average ratings in Indian movies released in India.
/* Ans :- */ Select DENSE_RANK() OVER (ORDER BY r.avg_rating DESC) AS Actor_Rank,N.name,R.avg_rating from names N
             inner join director_mapping DM on DM.name_id = N.id
             inner join role_mapping RM on RM.name_id = DM.name_id
             inner join movie M on M.id = DM.movie_id
             inner join ratings R on R.movie_id = M.id
             where M.country = 'India' and M.languages = 'Hindi' and RM.category = 'actor'
             group by N.name,R.avg_rating;
#-	Identify the top five actresses in Hindi movies released in India based on their average ratings.
/*Ans :- */ Select N.name,R.avg_rating from director_mapping DM
             inner join names N on N.id = DM.name_id
             inner join role_mapping RM on RM.name_id = N.id
             inner join movie M on M.id = DM.movie_id
             inner join ratings R on R.movie_id = M.id
             where M.country = 'India' and M.languages = 'Hindi' and RM.category = 'actress'
             order by R.avg_rating DESC limit 5;
/*SEGMENT 6*/
#-	Classify thriller movies based on average ratings into different categories.
/*ANs :- */ SELECT m.id,m.title as Movie_name,r.avg_rating as star_rating,
		CASE
           WHEN (r.avg_rating) >= 9 THEN 'Excellent'
           WHEN (r.avg_rating) >= 8 THEN 'Very Good'
           WHEN (r.avg_rating) >= 7 THEN 'Good'
           WHEN (r.avg_rating) >= 6 THEN 'Above Average'
           WHEN (r.avg_rating) >= 5 THEN 'Just Average'
           WHEN (r.avg_rating) >= 4 THEN 'Below Average'
           ELSE 'Flop'
       END AS rating_category
FROM movie m
INNER JOIN genre g ON m.id = g.movie_id
INNER JOIN ratings r ON m.id = r.movie_id
WHERE g.genre = 'thriller'
GROUP BY m.id,m.title
ORDER BY r.avg_rating DESC;

#-	analyse the genre-wise running total and moving average of the average movie duration
/*Ans :- */ SELECT genre, duration,
       SUM(duration) OVER (PARTITION BY genre ORDER BY duration ASC) AS running_total,
       AVG(duration) OVER (PARTITION BY genre ORDER BY duration ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_average
FROM movie
inner JOIN genre ON movie.id = genre.movie_id;

#-	Identify the five highest-grossing movies of each year that belong to the top three genres.
/*Ans :- */ SELECT M.title, M.year, M.worlwide_gross_income, G.genre
FROM (
    SELECT title, year, worlwide_gross_income, genre,
           ROW_NUMBER() OVER (PARTITION BY year, genre ORDER BY worlwide_gross_income DESC) AS rn
    FROM movie
    INNER JOIN genre ON movie.id = genre.movie_id
    WHERE genre IN (
        SELECT genre
        FROM (
            SELECT genre, SUM(worlwide_gross_income) AS total_gross
            FROM movie
            INNER JOIN genre ON movie.id = genre.movie_id
            GROUP BY genre
            ORDER BY total_gross DESC
            LIMIT 3
        ) AS top_genres
    )
) AS M
INNER JOIN genre G ON M.genre = G.genre
WHERE M.rn <= 5
group by M.title, M.year, M.worlwide_gross_income, G.genre
            
#-	Determine the top two production houses that have produced the highest number of hits among multilingual movies
/*Ans:-*/  select M.production_company,count(*) as hits_count from movie M
           inner join ratings R on R.movie_id = M.id
           where M.languages != 'English' and R.avg_rating >8 
           group by M.Production_company
           order by hits_count DESC limit 2;
             
#-	Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre
/* Ans :- */ select N.name ,RM.category,G.genre from names N
             inner join role_mapping RM on RM.name_id = N.id
             inner join genre G on G.movie_id = RM.movie_id
             inner join ratings R on R.movie_id = G.movie_id
             inner join movie M on M.id = R.movie_id
             where RM.category = 'actress' and R.avg_rating > 8 and G.genre = 'drama'
             group by RM.category,N.name limit 3;
			
#-	Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.
/* Ans :-*/ SELECT
  N.name AS director_name,
  COUNT(*) AS movie_count,
  ROUND(AVG(M.duration), 2) AS average_duration,
  ROUND(AVG(R.avg_rating), 2) AS average_rating,
  MIN(M.date_published) AS first_movie_published,
  MAX(M.date_published) AS latest_movie_published
FROM
  director_mapping DM
  INNER JOIN names N ON DM.name_id = N.id
  INNER JOIN movie M ON DM.movie_id = M.id
  INNER JOIN ratings R ON DM.movie_id = R.movie_id
GROUP BY
  N.name
ORDER BY
  movie_count DESC
LIMIT 9;

/*SEGMENT 7 */
#-	Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.
/*Ans:-*/ /*Quality Ratings: The average ratings of the top directors' movies suggest a focus
 on producing content that resonates with the audience and receives positive feedback. 
 Bolly movies should strive to maintain high-quality standards 
 and deliver movies that leave a positive impact on viewers.*/
/*Innovation and Creativity: To stand out in the industry,
 Bolly movies should encourage directors to bring innovation 
 and creativity to their projects. Embracing fresh ideas, 
 unique storytelling techniques, and unconventional approaches 
 can help create a distinct identity and attract viewers seeking something new.*/
#-	Determine the average duration of movies released by Bolly Movies compared to the industry average.
/* Ans :-*/ SELECT (select AVG(duration) from movie where country <> 'India') AS industry_average_duration
				  ,(SELECT AVG(duration) FROM movie where country = 'India') as Bolly_movies_average_duration,year
                  from movie group by year;
#-	Analyse the correlation between the number of votes and the average rating for movies produced by Bolly Movies.
/* Ans :-*/SELECT M.country,M.languages, AVG(R.avg_rating) AS average_rating, SUM(R.total_votes) AS total_votes,
         CASE
            WHEN COUNT(DISTINCT R.avg_rating) > 1 AND COUNT(DISTINCT R.total_votes) > 1 THEN
            (SUM(R.total_votes * R.avg_rating) - SUM(R.total_votes) * AVG(R.avg_rating)) /
            (SQRT(SUM(R.total_votes * R.total_votes) - SUM(R.total_votes) * SUM(R.total_votes)) *
            SQRT(SUM(R.avg_rating * R.avg_rating) - AVG(R.avg_rating) * AVG(R.avg_rating)))
	    ELSE 0 END AS correlation
     FROM movie M
    INNER JOIN ratings R ON M.id = R.movie_id
	GROUP BY M.country, M.languages;

#-	Find the production house that has consistently produced movies with high ratings over the past three years.
/*Ans:-*/ Select M.production_company,R.avg_rating from movie M
		  inner join ratings R on R.movie_id = M.id
          group by movie_id
		  order by avg_rating DESC limit 1;
#-	Identify the top three directors who have successfully delivered commercially successful movies with high ratings
/*Ans:-*/ select N.name as Director_Name,R.avg_rating from names N 
          inner join director_mapping DM on DM.name_id = N.id
          inner join movie M on M.id = DM.movie_id
          inner join ratings R on R.movie_id = DM.movie_id
          order by avg_rating DESC limit 3;


          


