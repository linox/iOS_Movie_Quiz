//
//  StatsViewController.h
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/14/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsViewController : UIViewController


@property (strong, nonatomic) IBOutlet UILabel *quizzesTakenLabel;

@property (strong, nonatomic) IBOutlet UILabel *timePerQuestionLabel;

@property (strong, nonatomic) IBOutlet UILabel *timeSpentLabel;

@property (strong, nonatomic) IBOutlet UILabel *answersLabel;

@property (strong, nonatomic) IBOutlet UILabel *correctAnswersLabel;

@property (strong, nonatomic) IBOutlet UILabel *incorrectAnswersLabel;

@property (strong, nonatomic) IBOutlet UIButton *resetStats;


- (IBAction)resetStats:(id)sender;

@end
