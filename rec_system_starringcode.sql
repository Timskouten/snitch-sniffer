#create the table structure in which all the data of the file -
#'moviesFromMetacritic' can be stored

CREATE TABLE movies (
url text,
title text,
ReleaseDate text,
Distributor text,
Starring text,
Summary text,
Director text,
Genre text,
Rating text,
Runtime text,
Userscore text,
Metascore text,
scoreCounts text
);

#Copy the data from the file
\copy movies
FROM '/home/pi/RSL/moviesFromMetacritic.csv'
delimiter ';' csv header
;

#Represent the text in the Starring field in a new column called lexemesStarring
ALTER TABLE movies
ADD lexemesStarring tsvector;

UPDATE movies
SET lexemesStarring = to_tsvector(Starring);

#Select all the movies that are about pirates:
SELECT url FROM movies
WHERE lexemesStarring @@ to_tsquery('pirate');

#The following lines of code make it possible to select movies that are recommended
#based on the movie that is provided, which is in this case pirates of the caribbean-
#the curse of the black pearl. 
ALTER TABLE movies
ADD rank float4; 

UPDATE movies
SET rank = ts_rank(lexemesStarring,plainto_tsquery(
(
SELECT Starring FROM movies WHERE url='pirates-of-the-caribbean-the-curse-of-the-black-pearl'
)
));

CREATE TABLE recommendationsBasedOnStarringField AS
SELECT url, rank FROM movies WHERE rank > 0.99 ORDER by RANK DESC LIMIT 50;

\copy (SELECT * FROM recommendationsBasedOnStarringField) to
'/home/pi/RSL/top50recommendations_Starring.csv' WITH csv;

#What is different in the output in this coder, however, is that only 18 movies have been printed and that these do not have exactly the same genre as the output of the other codes. 
#Woman in black is also mentioned in this output, which is a horror movie. This should i believe not have been printed, or been recommended as a movie to watch for people who like pirates of the caribbean. 

