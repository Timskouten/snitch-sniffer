


#import csv as the reader to read the userreviews file
import csv
with open('userReviews.csv') as UserReviews:
    reader = csv.DictReader(UserReviews,delimiter=';')
    
    data = list(reader)

#make some lists to be able to make sublists of the original dataframe.
x = list()
y = list()

#select the movie on which the sublists can be based and see which authors made reviews on this movie
for row in data:
    if(row[next(iter(row))] == 'the-wolf-of-wall-street'):
        y.append(row['Author'])
    x.append(row['Author'])
    
print(y)

#The following lines of code make it possible to generate a list of movies that can be recommended based on the reviews that the authors have made on other movies as well. So, due to the fact that the reviewers have watched other movies as well with positive recommendations the generated list should provide movies that can be interesting to watch as well.
z = list()

for author in y:
    for row in data:
        if author == row['Author']:
            z.append(row[next(iter(row))])

f = open('movies-filtered-by-authors.txt','w')
for movie in z:
    f.write(movie + "/n")
    
print(z)