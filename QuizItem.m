//
//  QuizItem.m
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/12/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import "QuizItem.h"

@implementation QuizItem

-(id)initWithId:(NSInteger)movie_id title:(NSString *)title director:(NSString *)director
{
    self = [super init];
    
    if(self)
    {
        _movie_id = movie_id;
        _title = title;
        _director = director;
    }
    
    return self;
}

@end
