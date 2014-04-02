//
//  Quiz.h
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/13/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuizQuestion.h"
#import "QuestionGenerator.h"

@interface Quiz : NSObject

@property (nonatomic) NSInteger numQuestions;
@property (nonatomic) NSInteger numCorrect;

- (NSString *)getQuestion;
- (NSArray *)getAnswers;
- (NSInteger)getAnswerIndex;
- (BOOL)submitAnswer:(NSInteger)answerIndex time:(double)time;
- (void)nextQuestion;
- (void)finish;

@end
