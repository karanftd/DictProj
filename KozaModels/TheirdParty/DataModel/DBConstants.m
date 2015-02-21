//
//  DBConstants.m
//  Koza_models
//
//  Created by Karan Patel on 28/01/15.
//  Copyright (c) 2015 Koaz. All rights reserved.
//

#import "DBConstants.h"



@implementation DBConstants

-(id) init
{
    self = [super init];
    if (self) {
        //creating database
        [self initializeDatabase];
    }
    return self;
}

-(void) initializeDatabase
{
    
    NSString *UPDATES = @"Updates";
    NSString *UPDATES_ID = @"_id";
    NSString *MESSAGE = @"Message";
    NSString *CREATE_UPDATES_TABLE = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ INTEGER PRIMARY KEY AUTOINCREMENT,%@ TEXT )",UPDATES, UPDATES_ID, MESSAGE];
}

@end