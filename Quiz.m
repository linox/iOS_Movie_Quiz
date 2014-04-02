//
//  Quiz.m
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/13/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import "Quiz.h"


@interface Quiz()
{
    QuizQuestion *currentQuestion;
    QuestionGenerator *questionGenerator;
    double lastQuestionAnsweredTime;
}

@end

@implementation Quiz

-(id)init
{
    self = [super init];
    
    if(self)
    {
        questionGenerator = [[QuestionGenerator alloc] init];
    }
    
    return self;
}

-(NSString *)getQuestion
{
    return currentQuestion.question;
}

-(NSArray *)getAnswers
{
    return currentQuestion.answers;
}

-(NSInteger)getAnswerIndex
{
    return currentQuestion.answerIndex;
}

-(BOOL)submitAnswer:(NSInteger)answerIndex time:(double)time
{
    
    BOOL correctAnswer = (answerIndex == currentQuestion.answerIndex);
    
    self.numQuestions++;
    
    lastQuestionAnsweredTime = time;
    
    if(correctAnswer)
    {
        self.numCorrect++;
        return true;
    }
    else
        return false;
}

-(void)nextQuestion
{
    currentQuestion = [questionGenerator newQuestion];
}

-(void)finish
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Update number of quizzes taken
    NSInteger quizzesTaken = [prefs integerForKey:@"quizzesTaken"];
    quizzesTaken++;
    
    [prefs setInteger:quizzesTaken forKey:@"quizzesTaken"];
    
    // Update total time spent
    double totalTime = [prefs integerForKey:@"totalTime"];
    totalTime += lastQuestionAnsweredTime;
    
    [prefs setFloat:totalTime forKey:@"totalTime"];
    
    // Update total number of answers
    NSInteger totalAnswers = [prefs integerForKey:@"totalAnswers"];
    totalAnswers += self.numQuestions;
    
    [prefs setInteger:totalAnswers forKey:@"totalAnswers"];
    
    // Update number of correct answers
    NSInteger correctAnswers = [prefs integerForKey:@"correctAnswers"];
    correctAnswers += self.numCorrect;
    
    [prefs setInteger:correctAnswers forKey:@"correctAnswers"];
    
    // Update number of incorrect answers
    NSInteger incorrectAnswers = [prefs integerForKey:@"incorrectAnswers"];
    incorrectAnswers += (self.numQuestions - self.numCorrect);
    
    [prefs setInteger:incorrectAnswers forKey:@"incorrectAnswers"];
}


@end
