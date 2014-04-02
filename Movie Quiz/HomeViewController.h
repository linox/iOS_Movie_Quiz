//
//  HomeViewController.h
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/11/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataController.h"
#import "QuestionGenerator.h"

@interface HomeViewController : UIViewController

@property (nonatomic, retain) DataController *dataController;
@property (nonatomic, retain) QuestionGenerator *gen;

@end
