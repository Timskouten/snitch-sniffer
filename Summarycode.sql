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

#Represent the text in the Summary field in a new column called lexemesSummary
ALTER TABLE movies
ADD lexemesSummary tsvector;
UPDATE movies
SET lexemesSummary = to_tsvector(Summary);

#Select all the movies that are about pirates:
SELECT url FROM movies
WHERE lexemesSummary @@ to_tsquery('pirate');

#The following lines of code make it possible to select movies that are recommended
#based on the movie that is provided, which is in this case pirates of the caribbean-
#the curse of the black pearl. 

ALTER TABLE movies
ADD rank float4; 

UPDATE movies
SET rank = ts_rank(lexemesSummary,plainto_tsquery(
(
SELECT Summary FROM movies WHERE url='pirates-of-the-caribbean-the-curse-of-the-black-pearl'
)
));

CREATE TABLE recommendationsBasedOnSummaryField AS
SELECT url, rank FROM movies WHERE rank > 0.99 ORDER by RANK DESC LIMIT 50;

\copy (SELECT * FROM recommendationsBasedOnSummaryField) to
'/home/pi/RSL/top50recommendations_summary.csv' WITH csv;

#According to the output of this file, it can be seen that most of the movies that are displayed are known to be adventurous/action movies as well, which is logic as this is the same genre for the pirates of of the carribean.
#Furthermore, some other pirates of the caribbean movies are mentioned in the output file as well, as these would be interesting as well for people who like these kind of movies. 
