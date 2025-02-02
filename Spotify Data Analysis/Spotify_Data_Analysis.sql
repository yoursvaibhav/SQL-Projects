-- Advance SQL Project  - Spotify Data Analysis 

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EDA (Exploratory Data Analysis)
----------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT COUNT(*) FROM spotify;                      --20594 total rows

SELECT COUNT(DISTINCT artist) FROM spotify;        --2074

SELECT COUNT(DISTINCT album) FROM spotify;         --11854

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;  		-- remove those songs whose duration is 0

SELECT * FROM spotify WHERE duration_min = 0;    --3 rows with 0 duraton song delete that

DELETE FROM spotify
WHERE duration_min = 0;

SELECT * FROM spotify WHERE duration_min = 0;

SELECT DISTINCT most_played_on FROM spotify;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Business Problems To Address (Data Analysis)
----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1) Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify 
LIMIT 3;

SELECT track FROM spotify
WHERE stream > 1000000000;

-- 2) List all albums along with their respective artists.

SELECT artist, album
FROM spotify 
GROUP BY artist, album;

-- 3) Get the total number of comments for tracks where licensed = TRUE

SELECT SUM(comments) AS total_number_of_comments
FROM spotify
WHERE licensed = 'true';

-- 4) Find all tracks that belong to the album type single.

SELECT track
FROM spotify
WHERE album_type = 'single';

-- 5) Count the total number of tracks by each artist.

SELECT artist, COUNT(track) AS total_number_tracs
FROM spotify
GROUP BY artist
ORDER BY COUNT(track) DESC;

-- 6) Calculate the average danceability of tracks in each album.

SELECT * FROM spotify 
LIMIT 3;

SELECT album, AVG(danceability) AS avg_danceability
FROM spotify 
GROUP BY 1     -- instead of doing GROUP BY album, u can specify the number of column ie album is on first so we write 1


-- 7) Find the top 5 tracks with the highest energy values.
SELECT track, MAX(energy)
FROM spotify
GROUP BY 1                           -- why group by becz one track has multiple record so will group them
ORDER BY 2 DESC
LIMIT 5

-- 8) List all tracks along with their views and likes where official_video = TRUE

SELECT track, SUM(views) AS total_views, SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1

-- 9) For each album, calculate the total views of all associated tracks.

SELECT album, track, SUM(views) AS total_views
FROM spotify
GROUP BY 1,2

-- 10) Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(SELECT track, 
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS streamed_on_youtube, 
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_spotify
FROM spotify
GROUP BY 1) AS a
WHERE streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube <> 0


-- 11) Find the top 3 most-viewed tracks for each artist using window functions.

WITH cte AS 
(SELECT
		artist,
		track,
		SUM(views) AS total_view,
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rnk
FROM spotify
GROUP BY 1,2
ORDER BY 1, 3 DESC)
SELECT * FROM cte
WHERE rnk <= 3

-- 12) Write a query to find tracks where the liveness score is above the average

SELECT * FROM spotify LIMIT 3

SELECT track, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)


-- 13) Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH cte AS
(SELECT 
	album,  
	MAX(energy) AS heighest_energy, MIN(energy) AS lowest_energy
FROM spotify
GROUP BY 1)
SELECT 
		album,
		heighest_energy - lowest_energy AS energy_difference
FROM cte
ORDER BY 2 DESC


-- 14) Find tracks where the energy-to-liveness ratio is greater than 1.2.

WITH cte AS
(SELECT
		track,
		(energy / liveness) as ratio
FROM spotify)
SELECT track, ratio
FROM cte 
WHERE ratio > 1.2

-- OR witjout using cte

SELECT 
    track,
    (energy / liveness) AS ratio
FROM 
    spotify
WHERE 
    (energy / liveness) > 1.2;


------------------------------------------------------------------------------------------------------------------------------------
--Query Optimization
------------------------------------------------------------------------------------------------------------------------------------

EXPLAIN ANALYZE
WITH cte AS
(SELECT 
	album,  
	MAX(energy) AS heighest_energy, MIN(energy) AS lowest_energy
FROM spotify
GROUP BY 1)
SELECT 
		album,
		heighest_energy - lowest_energy AS energy_difference
FROM cte
ORDER BY 2 DESC







