//
//  QuizViewController.h
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/13/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quiz.h"

#define TIME_LIMIT 180.0

@interface QuizViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *timerLabel;

@property (strong, nonatomic) IBOutlet UILabel *questionLabel;

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@property (strong, nonatomic) IBOutlet UILabel *answerLabel;



@property (strong, nonatomic) IBOutlet UIButton *answer1;

@property (strong, nonatomic) IBOutlet UIButton *answer2;

@property (strong, nonatomic) IBOutlet UIButton *answer3;

@property (strong, nonatomic) IBOutlet UIButton *answer4;

- (IBAction)selectAnswer:(id)sender;

@end
