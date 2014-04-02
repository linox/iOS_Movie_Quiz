//
//  QuestionGenerator.h
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/12/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataController.h"
#import "QuizQuestion.h"
#import "QuizItem.h"

@interface QuestionGenerator : NSObject

@property(nonatomic, assign) sqlite3 *database;

-(QuizQuestion *)newQuestion;

-(QuizItem *) randomMovie;
-(QuizItem *)randomMovieWithMinStars:(NSInteger)i;

-(QuizQuestion *)getDirectorQuestion;
-(QuizQuestion *)getMovieYearQuestion;
-(QuizQuestion *)getStarInMovieQuestion;
-(QuizQuestion *)getStarsNotInMovieQuestion;
-(QuizQuestion *)getStarsAppearTogetherQuestion;
-(QuizQuestion *)getDirectorDirectStarQuestion;
-(QuizQuestion *)getDirectorNotDirectStarQuestion;
-(QuizQuestion *)getStarAppearBothMoviesQuestion;
-(QuizQuestion *)getStarNotAppearWithStarQuestion;
-(QuizQuestion *)getDirectorForStarInYearQuestion;
-(QuizQuestion *) generateQuestion: (NSString *)question withCorrectAnswer:(NSString *)answer incorrectAnswers:(NSMutableArray *)answers;

@end
