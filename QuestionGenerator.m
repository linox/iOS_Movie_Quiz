//
//  QuestionGenerator.m
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/12/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import "QuestionGenerator.h"

@implementation QuestionGenerator

@synthesize database;

-(id)init
{
    self = [super init];
    
    if (self)
    {
        DataController *d = [[DataController alloc] init];
        database = [d openDB];
    }
    
    return self;
}

-(QuizQuestion *)newQuestion
{
    QuizQuestion *currentQuestion;
    int qType = arc4random() % 10;
    
    switch (qType)
    {
        case 0:
            currentQuestion = [self getDirectorQuestion];
            break;
        case 1:
            currentQuestion = [self getMovieYearQuestion];
            break;
        case 2:
            currentQuestion = [self getStarInMovieQuestion];
            break;
        case 3:
            currentQuestion = [self getStarsNotInMovieQuestion];
            break;
        case 4:
            currentQuestion = [self getStarsAppearTogetherQuestion];
            break;
        case 5:
            currentQuestion = [self getDirectorDirectStarQuestion];
            break;
        case 6:
            currentQuestion = [self getDirectorNotDirectStarQuestion];
            break;
        case 7:
            currentQuestion = [self getStarAppearBothMoviesQuestion];
            break;
        case 8:
            currentQuestion = [self getStarNotAppearWithStarQuestion];
            break;
        case 9:
            currentQuestion = [self getDirectorForStarInYearQuestion];
            break;
    }
    
    return currentQuestion;
}

-(QuizItem *)randomMovie
{
    NSString *sql = @"SELECT id, title, director from movie WHERE (SELECT count(stars_in_movies.star_id) from stars_in_movies WHERE stars_in_movies.movie_id=movie.id) >= 1 ORDER BY RANDOM() LIMIT 1;";
    
    sqlite3_stmt *statement;
    
    QuizItem *movie;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSNumber *temp_id    = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
            NSInteger movie_id  = [temp_id integerValue];
            NSString *title      = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
            NSString *director   = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
            movie = [[QuizItem alloc] initWithId:movie_id title:title director:director];
        }
    }
    
    return movie;
}

-(QuizItem *)randomMovieWithMinStars:(NSInteger)i
{
    NSString *sql = [NSString stringWithFormat:@"SELECT id, title, director FROM movie, stars_in_movies WHERE (SELECT count(stars_in_movies.star_id) FROM stars_in_movies WHERE stars_in_movies.movie_id=movie.id) >= %i ORDER BY RANDOM() LIMIT 1;", (int)i];
    
    sqlite3_stmt *statement;
    
    NSInteger movie_id;
    NSString *title;
    NSString *director;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            NSNumber *temp_id    = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
            movie_id   = [temp_id integerValue];
            title      = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
            director   = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
        }
    }
    else
    {
        return NULL;
    }
    
    QuizItem *item = [[QuizItem alloc] initWithId:movie_id title:title director:director];
    
    NSLog(@"%@", item.title);
    
    return item;
}


-(QuizQuestion *)getDirectorQuestion
{
    QuizItem *movie = [self randomMovie];
    NSString *sql   = [NSString stringWithFormat:@"SELECT director FROM movie WHERE director!='%@' ORDER BY RANDOM() LIMIT 3;", movie.director];
    
    sqlite3_stmt *statement;
    
    NSMutableArray *incorrectAnswers = [[NSMutableArray alloc] init];
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *director = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            [incorrectAnswers addObject:director];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"Who directed the movie %@?", movie.title];
    NSLog(@"%@", question);
    //NSLog(@"%@", movie.director);
    
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:movie.director incorrectAnswers:incorrectAnswers];
    
    return quizQuestion;
}

-(QuizQuestion *)getMovieYearQuestion
{
    QuizItem *movie = [self randomMovie];
    NSString *sqlCorrectAnswer = [NSString stringWithFormat:@"SELECT year FROM movie WHERE id='%i';", (int)movie.movie_id];
    
    sqlite3_stmt *correctStatement;
    
    NSString *answer;
    
    if (sqlite3_prepare_v2(database, [sqlCorrectAnswer UTF8String], -1, &correctStatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(correctStatement) == SQLITE_ROW)
        {
            answer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(correctStatement, 0)];
            
        }
    }
    
    
    NSString *sqlIncorrectAnswer = [NSString stringWithFormat:@"SELECT year FROM movie WHERE year!='%@' ORDER BY RANDOM() LIMIT 3;", answer];
    
    sqlite3_stmt *incorrectStatement;
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [sqlIncorrectAnswer UTF8String], -1, &incorrectStatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(incorrectStatement) == SQLITE_ROW)
        {
            NSString *wrong_year = [NSString stringWithUTF8String:(char *)sqlite3_column_text(incorrectStatement, 0)];
            
            [answerOptions addObject:wrong_year];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"When was the movie %@ released?", movie.title];
    
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:answer incorrectAnswers:answerOptions];
    NSLog(@"%@", quizQuestion.question);
    return quizQuestion;
}

-(QuizQuestion *)getStarInMovieQuestion
{
    QuizItem *movie = [self randomMovie];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name FROM stars, stars_in_movies WHERE stars_in_movies.movie_id='%i' AND stars_in_movies.star_id=stars.id ORDER BY RANDOM() LIMIT 1;", (int)movie.movie_id];
    
    NSString *correctFirstName;
    NSString *correctLastName;
    NSString *star;
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            correctFirstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            correctLastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            star = [NSString stringWithFormat:@"%@ %@", correctFirstName, correctLastName];
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT first_name, last_name FROM stars, stars_in_movies WHERE first_name!='%@' AND last_name!='%@' AND stars_in_movies.star_id=stars.id AND stars_in_movies.movie_id!='%i' ORDER BY RANDOM() LIMIT 3;", correctFirstName, correctLastName, (int)movie.movie_id];
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    
    NSLog(@"%@", sql);
    NSString *incorrectFirstName;
    NSString *incorrectLastName;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            incorrectFirstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            incorrectLastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            NSString *incorrectStar = [NSString stringWithFormat:@"%@ %@", incorrectFirstName, incorrectLastName];
            
            [answerOptions addObject:incorrectStar];
        }
    }
    
    NSString *question = [NSString stringWithFormat: @"Which star was in the movie %@?", movie.title];
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:star incorrectAnswers:answerOptions];
    NSLog(@"%d", (int)quizQuestion.answers.count);
    NSLog(@"%@", quizQuestion.question);
    return quizQuestion;
}

-(QuizQuestion *)getStarsNotInMovieQuestion
{
    QuizItem *movie = [self randomMovieWithMinStars:3];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name, stars.id AS s FROM stars WHERE NOT EXISTS (SELECT stars.id FROM stars, stars_in_movies WHERE stars_in_movies.star_id=s AND stars_in_movies.movie_id='%i') ORDER BY RANDOM() LIMIT 1;", (int)movie.movie_id];
    
    sqlite3_stmt *statement;
    
    NSString *answer;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            answer = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name FROM stars, stars_in_movies WHERE stars_in_movies.star_id=stars.id AND stars_in_movies.movie_id='%i' ORDER BY RANDOM() LIMIT 3;", (int)movie.movie_id];
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            NSString *wrongAnswer = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            [answerOptions addObject:wrongAnswer];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"Which star was not in %@?", movie.title];
    
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:answer incorrectAnswers:answerOptions];
    return quizQuestion;
}

-(QuizQuestion *)getStarsAppearTogetherQuestion
{
    QuizItem *movie = [self randomMovieWithMinStars:3];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name, stars.id FROM stars, stars_in_movies WHERE stars_in_movies.movie_id='%i' AND stars_in_movies.star_id=stars.id ORDER BY RANDOM() LIMIT 2;", (int)movie.movie_id];
    
    sqlite3_stmt *statement;
    
    NSInteger starID;
    NSString *star1;
    NSString *star2;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            if(star1 == nil || star1 == NULL)
            {
                star1 = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                starID = [[NSNumber numberWithInt:sqlite3_column_int(statement, 0)] integerValue];
            }
            else if(star2 == nil || star2 == NULL)
            {
                star2 = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            }
        }
    }
    else
    {
        NSLog(@"ERROR IN SQL STATEMENT");
        return NULL;
    }
    
    sql = [NSString stringWithFormat:@"SELECT title, movie.id AS m FROM movie WHERE NOT EXISTS(SELECT star_id FROM stars_in_movies WHERE star_id='%i' AND movie_id=m) ORDER BY RANDOM() LIMIT 3;", (int)starID];
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            [answerOptions addObject:title];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"In which movie did the stars %@ and %@ appear together?", star1, star2];
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:movie.title incorrectAnswers:answerOptions];
    
    return quizQuestion;
}

-(QuizQuestion *)getDirectorDirectStarQuestion
{
    QuizItem *movie = [self randomMovie];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name, stars.id FROM stars, stars_in_movies WHERE stars_in_movies.movie_id='%i' AND stars_in_movies.star_id=stars.id ORDER BY RANDOM() LIMIT 1;", (int)movie.movie_id];
    
    sqlite3_stmt *statement;
    
    NSString *star;
    NSInteger starID = 0;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            starID = [[NSNumber numberWithInt:sqlite3_column_int(statement, 2)] integerValue];
            
            star = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    
    sql = [NSString stringWithFormat:@"SELECT director, movie.id AS m FROM movie WHERE NOT EXISTS(SELECT star_id FROM stars_in_movies WHERE star_id='%i' AND movie_id=m) ORDER BY RANDOM() LIMIT 3;", (int)starID];
    
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *director = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            
            [answerOptions addObject:director];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"Who directed the star %@?", star];
    
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:movie.director incorrectAnswers:answerOptions];
    NSLog(@"%@", quizQuestion.question);
    return quizQuestion;
}

-(QuizQuestion *)getDirectorNotDirectStarQuestion
{
    NSString *sql = [NSString stringWithFormat:@"SELECT first_name, last_name, id FROM stars WHERE (SELECT COUNT(DISTINCT director) FROM stars_in_movies AS s, movie AS m WHERE stars.id=s.star_id AND m.id=s.movie_id) >= 3 ORDER BY RANDOM() LIMIT 1;"];
    
    sqlite3_stmt *statement;
    
    NSString *star;
    NSInteger starID = 0;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            starID = [[NSNumber numberWithInt:sqlite3_column_int(statement, 2)] integerValue];
            
            star = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT director FROM movie AS m, stars_in_movies AS s WHERE NOT EXISTS (SELECT stars_in_movies.movie_id FROM stars_in_movies WHERE stars_in_movies.movie_id=m.id AND stars_in_movies.star_id='%i') ORDER BY RANDOM() LIMIT 1;", (int)starID];
    
    NSString *answer;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *director = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            
            answer = director;
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT DISTINCT director FROM movie NATURAL JOIN stars_in_movies WHERE stars_in_movies.star_id='%i' AND stars_in_movies.movie_id=id ORDER BY RANDOM() LIMIT 3;", (int)starID];
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *director = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            [answerOptions addObject:director];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"Who did not direct the star %@?", star];
    
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:answer incorrectAnswers:answerOptions];
    NSLog(@"%@", quizQuestion.question);
    return quizQuestion;
}

-(QuizQuestion *)getStarAppearBothMoviesQuestion
{
    NSString *sql = [NSString stringWithFormat:@"SELECT stars.id, stars.first_name, stars.last_name from stars, stars_in_movies as s, stars_in_movies as m WHERE m.star_id = stars.id AND s.star_id = stars.id AND m.movie_id != s.movie_id ORDER BY RANDOM() LIMIT 1;"];
    
    NSString *answer;
    NSInteger starID = 0;
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            starID = [[NSNumber numberWithInt:sqlite3_column_int(statement, 0)] integerValue];
            
            answer = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT movie.title, movie.id from movie, stars_in_movies WHERE stars_in_movies.star_id='%i' AND stars_in_movies.movie_id = movie.id ORDER BY RANDOM() LIMIT 2;", (int)starID];
    
    NSMutableArray *movieNames = [[NSMutableArray alloc] init];
    NSMutableArray *movieIDs = [[NSMutableArray alloc] init];
    NSNumber *movie_id;

    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *movieTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            movie_id = [NSNumber numberWithInt:sqlite3_column_int(statement, 1)];
            
            [movieNames addObject:movieTitle];
            [movieIDs addObject:movie_id];
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name from stars, stars_in_movies WHERE stars_in_movies.star_id = stars.id AND stars_in_movies.movie_id!='%i' ORDER BY RANDOM() LIMIT 3;", (int)movie_id];
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            NSString *temp = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            [answerOptions addObject:temp];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"Which star appears in both %@ and %@?", [movieNames objectAtIndex:0], [movieNames objectAtIndex:1]];
    
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:answer incorrectAnswers:answerOptions];
    NSLog(@"%@", quizQuestion.question);
    NSLog(@"%@", answer);
    return quizQuestion;
}

-(QuizQuestion *)getStarNotAppearWithStarQuestion
{
    NSString *sql = [NSString stringWithFormat:@"SELECT movie.id from movie, stars_in_movies WHERE (SELECT count (distinct stars.last_name) from stars, stars_in_movies WHERE stars_in_movies.movie_id=movie.id and stars_in_movies.star_id = stars.id) >= 4 ORDER BY RANDOM() LIMIT 1;"];
    
    NSInteger movieID = 0;
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            movieID = [[NSNumber numberWithInt:sqlite3_column_int(statement, 0)] integerValue];
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name from stars, stars_in_movies WHERE stars_in_movies.star_id=stars.id AND stars_in_movies.movie_id ='%i' ORDER BY RANDOM() LIMIT 1;", (int)movieID];
    
    NSString *star;
    NSString *starFirstName;
    NSString *starLastName;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            starFirstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            starLastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            star = [NSString stringWithFormat:@"%@ %@", starFirstName, starLastName];
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name FROM stars, stars_in_movies WHERE stars_in_movies.star_id=stars.id AND stars_in_movies.movie_id!='%i' ORDER BY RANDOM() LIMIT 1;", (int)movieID];
    
    NSString *answer;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            answer = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    
    sql = [NSString stringWithFormat:@"SELECT distinct stars.first_name, stars.last_name from stars, stars_in_movies WHERE stars_in_movies.star_id=stars.id AND stars_in_movies.movie_id='%i' AND stars.first_Name!='%@' AND stars.last_name!='%@' ORDER BY RANDOM() LIMIT 3;", (int)movieID, starFirstName, starLastName];
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            NSString *temp = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            [answerOptions addObject:temp];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"Which star did not appear in the same movie with %@?", star];
    
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:answer incorrectAnswers:answerOptions];
    NSLog(@"%@", quizQuestion.question);
    return quizQuestion;
}

-(QuizQuestion *)getDirectorForStarInYearQuestion
{
    QuizItem *movie = [self randomMovie];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT stars.first_name, stars.last_name, stars.id, movie.year, movie.id from stars, movie, stars_in_movies WHERE stars_in_movies.star_id=stars.id AND stars_in_movies.movie_id='%i' AND movie.id='%i' ORDER BY RANDOM() LIMIT 1;", (int)movie.movie_id, (int)movie.movie_id];
    
    NSString *star;
    NSString *year;
    NSInteger starID;
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            star = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            year = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            
            starID = [[NSNumber numberWithInt:sqlite3_column_int(statement, 2)] integerValue];
        }
    }
    else
    {
        NSLog(@"QUERY FAILED");
        return NULL;
    }
    
    sql = [NSString stringWithFormat:@"SELECT movie.director from movie, stars_in_movies WHERE stars_in_movies.movie_id=movie.id AND stars_in_movies.star_id!='%i' ORDER BY RANDOM() LIMIT 3;", (int)starID];
    
    NSMutableArray *answerOptions = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *director = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            [answerOptions addObject:director];
        }
    }
    
    NSString *question = [NSString stringWithFormat:@"Who directed %@ in %@", star, year];
    
    QuizQuestion *quizQuestion = [self generateQuestion:question withCorrectAnswer:movie.director incorrectAnswers:answerOptions];
    
    NSLog(@"%@", quizQuestion.question);
    return quizQuestion;
}

-(QuizQuestion *)generateQuestion:(NSString *)question withCorrectAnswer:(NSString *)answer incorrectAnswers:(NSMutableArray *)answers
{
    int answerIndex = arc4random() % 4;
    [answers insertObject:answer atIndex:answerIndex];
    
    QuizQuestion *quizQuestion = [[QuizQuestion alloc] initWithQuestion:question answers:answers answerIndex:answerIndex];
    return quizQuestion;
}

@end
