//
//  QuizItem.h
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/12/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuizItem : NSObject

@property(nonatomic, readonly) NSInteger movie_id;
@property(nonatomic, readonly) NSString  *title;
@property(nonatomic, readonly) NSString  *director;

-(id)initWithId:(NSInteger)id title:(NSString *)title director:(NSString *)director;

@end
