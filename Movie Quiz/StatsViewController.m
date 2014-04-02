//
//  StatsViewController.m
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/14/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import "StatsViewController.h"

@interface StatsViewController ()

- (void)reloadStats;
- (void)reset;

@end

@implementation StatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadStats];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidLoad];
    
    [self reloadStats];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetStats:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                    message:@"Are you sure you want to reset your statistics?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Reset", nil];
    
    [alert show];
}

-(void)reloadStats
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Show number of quizzes taken
    NSInteger quizzesTaken = [prefs integerForKey:@"quizzesTaken"];
    self.quizzesTakenLabel.text = [NSString stringWithFormat:@"Quizzes Taken: %d", (int)quizzesTaken];
    
    // Show time spent
    double totalTime = [prefs floatForKey:@"totalTime"];
    self.timeSpentLabel.text = [NSString stringWithFormat:@"Time Spent: %.1f seconds", totalTime];
    
    // Show average time per question
    NSInteger totalAnswers = [prefs integerForKey:@"totalAnswers"];
    
    if (totalAnswers != 0) {
        self.timePerQuestionLabel.text = [NSString stringWithFormat:@"Time per Question: %.1f seconds", (totalTime / totalAnswers)];
    } else {
        self.timePerQuestionLabel.text = [NSString stringWithFormat:@"Time per Question: 0.0 seconds"];
    }
    
    // Show total number of answers
    self.answersLabel.text = [NSString stringWithFormat:@"Answers: %d", (int)totalAnswers];
    
    // Show number of correct answers
    NSInteger correctAnswers = [prefs integerForKey:@"correctAnswers"];
    self.correctAnswersLabel.text = [NSString stringWithFormat:@"Correct Answers: %d", (int)correctAnswers];
    
    // Show number of incorrect answers
    NSInteger incorrectAnswers = [prefs integerForKey:@"incorrectAnswers"];
    self.incorrectAnswersLabel.text = [NSString stringWithFormat:@"Incorrect Answers: %d", (int)incorrectAnswers];
}

-(void)reset
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:@"quizzesTaken"];
    [prefs removeObjectForKey:@"totalTime"];
    [prefs removeObjectForKey:@"totalAnswers"];
    [prefs removeObjectForKey:@"correctAnswers"];
    [prefs removeObjectForKey:@"incorrectAnswers"];
    
    [self reloadStats];
}

#pragma mark - UIAlertViewDelegate

// Reset stats confirmation alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        [self reset];
    }
}

@end
