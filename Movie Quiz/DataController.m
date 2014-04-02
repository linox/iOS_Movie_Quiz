//
//  DataController.m
//  Movie Quiz
//
//  Created by Bryan Cuevas on 3/11/14.
//  Copyright (c) 2014 Bryan Cuevas. All rights reserved.
//

#import "DataController.h"

static sqlite3 *database;

@implementation DataController

-(void)initDatabase
{
    // Create a string containing the full path to the sqlite.db inside the documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"moviequiz.db"];
    
    // Check to see if the database file already exists
    bool databaseAlreadyExists = [[NSFileManager defaultManager] fileExistsAtPath:databasePath];
    
    // Open the database and store the handle as a data member
    if (sqlite3_open([databasePath UTF8String], &databaseHandle) == SQLITE_OK)
    {
        // Create the database if it doesn't yet exists in the file system
        if (!databaseAlreadyExists)
        {
            // Create the PERSON table
            const char *sqlStatement = "CREATE TABLE IF NOT EXISTS movie (id INTEGER PRIMARY KEY, title TEXT, year TEXT, director TEXT);";
            
            char *error;
            if (sqlite3_exec(databaseHandle, sqlStatement, NULL, NULL, &error) == SQLITE_OK)
            {
                sqlStatement = "CREATE TABLE IF NOT EXISTS stars (id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, dob TEXT);";
                
                if (sqlite3_exec(databaseHandle, sqlStatement, NULL, NULL, &error) == SQLITE_OK)
                {
                    sqlStatement = "CREATE TABLE IF NOT EXISTS stars_in_movies (movie_id INTEGER, star_id INTEGER);";
                    
                    if (sqlite3_exec(databaseHandle, sqlStatement, NULL, NULL, &error) == SQLITE_OK)
                    {
                        NSLog(@"Database and all tables created.");
                    }
                    
                    else
                    {
                        NSLog(@"Error: %s", error);
                    }
                }
                
                else
                {
                    NSLog(@"Error: %s", error);
                }
            }
            
            else
            {
                NSLog(@"Error: %s", error);
            }
            
            [self loadData];
        }
    }
    
    
}

-(sqlite3 *)openDB
{
    if(database == NULL){
        sqlite3 *newDBConnection;
    
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"moviequiz.db"];
    
        if (sqlite3_open([databasePath UTF8String], &newDBConnection) == SQLITE_OK)
        {
            NSLog(@"DATABASE OPENED");
            database = newDBConnection;
        }
        else
        {
            NSLog(@"Error in opening database");
            database = NULL;
        }
    }
    return database;
}

-(void)loadData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"movies" ofType:@"csv"];
    
    NSString *fileDataString=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    NSArray *linesArray=[fileDataString componentsSeparatedByString:@"\n"];

    for(int k = 1; k < linesArray.count; k++)
    {
        //Gives u the number of items in one line separated by comma(,)
        NSString *lineString=[linesArray objectAtIndex:k];
        
        NSArray *columnArray = [lineString componentsSeparatedByString:@","];
        //Gives u the array of all components.
        
        if(columnArray.count == 4)
        {
            NSString *movie_id          = [columnArray objectAtIndex:0];
            NSString *movie_title       = [columnArray objectAtIndex:1];
            NSString *movie_year        = [columnArray objectAtIndex:2];
            NSString *movie_director    = [columnArray objectAtIndex:3];
        
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO movie (id, title, year, director) VALUES ('%@', '%@', '%@', '%@')", movie_id, movie_title, movie_year, movie_director];
        
            if ( sqlite3_exec(databaseHandle, [sql UTF8String], NULL, NULL, &error_Msg) == SQLITE_OK)
            {
                NSLog(@"Add successful!");
            }
        }
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"stars" ofType:@"csv"];
    
    fileDataString=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    linesArray=[fileDataString componentsSeparatedByString:@"\n"];
    
    for(int k = 1; k < linesArray.count; k++)
    {
        NSString *lineString=[linesArray objectAtIndex:k];
        
        NSArray *columnArray = [lineString componentsSeparatedByString:@","];
        
        if(columnArray.count == 4)
        {
            NSString *star_id      = [columnArray objectAtIndex:0];
            NSString *star_fname   = [columnArray objectAtIndex:1];
            NSString *star_lname   = [columnArray objectAtIndex:2];
            NSString *star_dob     = [columnArray objectAtIndex:3];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO stars (id, first_name, last_name, dob) VALUES ('%@', '%@', '%@', '%@')", star_id, star_fname, star_lname, star_dob];
            
            if ( sqlite3_exec(databaseHandle, [sql UTF8String], NULL, NULL, &error_Msg) == SQLITE_OK)
            {
                NSLog(@"Add successful!");
            }
        }
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"stars_in_movies" ofType:@"csv"];
    
    fileDataString=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    linesArray=[fileDataString componentsSeparatedByString:@"\n"];
    
    for(int k = 1; k < linesArray.count; k++)
    {
        NSString *lineString=[linesArray objectAtIndex:k];
        
        NSArray *columnArray = [lineString componentsSeparatedByString:@","];
        
        if(columnArray.count == 2)
        {
            NSString *star_id      = [columnArray objectAtIndex:0];
            NSString *movie_id     = [columnArray objectAtIndex:1];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO stars_in_movies (movie_id, star_id) VALUES ('%@', '%@')", movie_id, star_id];
            
            if ( sqlite3_exec(databaseHandle, [sql UTF8String], NULL, NULL, &error_Msg) == SQLITE_OK)
            {
                NSLog(@"Add successful!");
            }
        }

    }
}


@end
