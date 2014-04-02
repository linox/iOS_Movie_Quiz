//
//  QuizQuestion.m
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/12/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import "QuizQuestion.h"

@implementation QuizQuestion

-(id)initWithQuestion:(NSString *)question answers:(NSArray *)answers answerIndex:(NSInteger)answerIndex
{
    self = [super init];
    
    if (self) {
        _question = question;
        _answers = answers;
        _answerIndex = answerIndex;
    }
    
    return self;
}

@end
