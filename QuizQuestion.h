//
//  QuizQuestion.h
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/12/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuizQuestion : NSObject

@property (nonatomic, readonly) NSString *question;
@property (nonatomic, readonly) NSArray *answers;
@property (nonatomic, readonly) NSInteger answerIndex;

-(id)initWithQuestion:(NSString *)question answers:(NSArray *)answers answerIndex:(NSInteger)answerIndex;

@end
