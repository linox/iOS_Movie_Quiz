//
//  DataController.h
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/11/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DataController : NSObject {
    sqlite3 *databaseHandle;
    
    char * error_Msg;
}

-(void)initDatabase;
-(sqlite3 *) openDB;
-(void)loadData;

@end
