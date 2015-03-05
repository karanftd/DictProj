//
//  DBHelper.m
//  Koza_models
//
//  Created by Karan Patel on 29/01/15.
//  Copyright (c) 2015 Koaz. All rights reserved.
//

#import "DBHelper.h"
#import "FMDB.h"
#import "Constans.h"
#import "DictData.h"

#define DM_DISPATCH_START dispatch_async(dispatch_get_main_queue(), ^{
#define DM_DISPATCH_END });

@interface DBHelper (){
    
    NSString *DefaultDatabase;
    FMDatabase *db;
    dispatch_queue_t DatabaseQueue;
    
}

@property (strong, nonatomic) NSString *databasePath;

@end

@implementation DBHelper

    +(DBHelper *) sharedInstance
    {
        static DBHelper *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[DBHelper alloc] init];
        });
        return sharedInstance;
    }



-(void) initializeDatabase
{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    _databasePath   = [docsPath stringByAppendingPathComponent:DB_Name];
    DatabaseQueue = dispatch_queue_create("com.database.queue", 0);
    db     = [FMDatabase databaseWithPath:_databasePath];
    assert(db);
    

}

#pragma mark - class level methods
-(void) getRecord:(NSString *)string finishBlock:(void (^)(NSArray *record ,NSError *err))finishBlock
{
    
    //Setting up finalBlock
    __block NSMutableArray *rows = [[NSMutableArray alloc] init];
    void (^fBlock)(NSError *err) = ^(NSError *err){
        DM_DISPATCH_START
        if (err) { //Failed
            finishBlock(nil,err);
        }else { //Success
            finishBlock(rows, nil);
        }
        DM_DISPATCH_END
    };
    
    if (!DatabaseQueue) {
        DatabaseQueue = dispatch_queue_create("com.database.queue", 0);
    }
    dispatch_async(DatabaseQueue, ^{
        
        if (![db open]) {
            NSError *err = [self errObjectWithMsg:@"Could not open database"];
            fBlock(err);
            return;
        }
        NSString *query;
        if(string && string.length == 0){
            
            query = [NSString stringWithFormat:@"SELECT * FROM hindi WHERE word LIMIT 5000"];
            
        }
        else if (string.length > 0)
        {
            query = [NSString stringWithFormat:@"SELECT * FROM hindi WHERE word BETWEEN '%@' AND '%@'", string,string];
        }
        
        FMResultSet *results = [db executeQuery:query];
        while([results next])
        {
            
            DictData *dicData = [[DictData alloc] init];
            dicData.mID = @([results intForColumnIndex:0]);
            dicData.mWord = [results stringForColumnIndex:1];
            dicData.mPronunciation = [results stringForColumnIndex:2];
            dicData.mMeaning = [results stringForColumnIndex:3];
            dicData.mHistory = [results stringForColumnIndex:4];
            dicData.mFavorit = [results stringForColumnIndex:5];
            
            [rows addObject:dicData];
        }
        
        if(rows){
            fBlock(nil);
        }
        else{
            NSError *err = [self errObjectWithMsg:@"No row found"];
            fBlock(err);
            [db close];
            return;
        }
        [db close];
    });
}

// get word and meaning
-(void) getRow:(NSNumber *)ID  finishBlock:(void (^)(DictData *record ,NSError *err))finishBlock
{
    
    __block DictData *row = [[DictData alloc] init];
    
    void (^fBlock)(NSError *err) = ^(NSError *err){
        DM_DISPATCH_START
        if (err) { //Failed
            finishBlock(nil,err);
        }else { //Success
            finishBlock(row, nil);
        }
        DM_DISPATCH_END
    };
    
    if (!DatabaseQueue) {
        DatabaseQueue = dispatch_queue_create("com.database.queue", 0);
    }
    dispatch_async(DatabaseQueue, ^{
        
        if (![db open]) {
            NSError *err = [self errObjectWithMsg:@"Could not open database"];
            fBlock(err);
            return;
        }
        
        NSString *query = [NSString stringWithFormat:@"SELECT _id, word, pronunciation, meaning, history, favourite FROM hindi WHERE _id = '%@'", ID];
        FMResultSet *results = [db executeQuery:query];
        
        
        while([results next])
        {
            
            row.mID = @([results intForColumnIndex:0]);
            row.mWord = [results stringForColumnIndex:1];
            row.mPronunciation = [results stringForColumnIndex:2];
            row.mMeaning = [results stringForColumnIndex:3];
            row.mHistory = [results boolForColumnIndex:4];
            row.mFavorit = [results boolForColumnIndex:5];
            
        }
        
        if(row.mID){
            fBlock(nil);
        }
        else{
            NSError *err = [self errObjectWithMsg:@"No row found"];
            fBlock(err);
            [db close];
            return;
        }
        [db close];
    });
}

//
-(void) updateColumn                                                                                                                                                                                                                                                               :(NSNumber *)ID val:(BOOL)val forColName:(NSString*)colName
{
    
    if (!DatabaseQueue) {
        DatabaseQueue = dispatch_queue_create("com.database.queue", 0);
    }
    dispatch_async(DatabaseQueue, ^{
        
        if (![db open]) {
            return;
        }
        
        NSLog(@"update table row ..");
        //Builing query
        NSString *querySt = @"UPDATE hindi set ? = ? where  _id = ? ";
        BOOL success = [db executeUpdate:querySt withArgumentsInArray:@[colName,[NSNumber numberWithBool:val],ID]];
    
        if(success){
            NSLog(@"Record updated ..");
        }else{
            return;
        }
        [db close];
    });
    
}


//clear History
-(void) clearHistory{
    
    if (!DatabaseQueue) {
        DatabaseQueue = dispatch_queue_create("com.database.queue", 0);
    }
    dispatch_async(DatabaseQueue, ^{
        
        if (![db open]) {
            return;
        }
        
        NSLog(@"update table row ..");
        //Builing query
        NSString *querySt = @"UPDATE hindi set history = 0 ";
        BOOL success = [db executeUpdate:querySt];
        
        if(success){
            NSLog(@"Record updated ..");
        }else{
            return;
        }
        [db close];
    });

}

//clear Favorite
-(void) clearFavorite{
    
    if (!DatabaseQueue) {
        DatabaseQueue = dispatch_queue_create("com.database.queue", 0);
    }
    dispatch_async(DatabaseQueue, ^{
        
        if (![db open]) {
            return;
        }
        
        NSLog(@"update table row ..");
        //Builing query
        NSString *querySt = @"UPDATE hindi set favourite = 0 ";
        BOOL success = [db executeUpdate:querySt];
        
        if(success){
            NSLog(@"Record updated ..");
        }else{
            return;
        }
        [db close];
    });
    
}


//Get Random Words With Meaning
-(void) getRandomWords:(NSNumber *)numWords finishBlock:(void (^)(NSArray *record ,NSError *err))finishBlock
{
    
    //Setting up finalBlock
    __block NSMutableArray *rows = [[NSMutableArray alloc] init];
    void (^fBlock)(NSError *err) = ^(NSError *err){
        DM_DISPATCH_START
        if (err) { //Failed
            finishBlock(nil,err);
        }else { //Success
            finishBlock(rows, nil);
        }
        DM_DISPATCH_END
    };
    
    if (!DatabaseQueue) {
        DatabaseQueue = dispatch_queue_create("com.database.queue", 0);
    }
    dispatch_async(DatabaseQueue, ^{
        
        if (![db open]) {
            NSError *err = [self errObjectWithMsg:@"Could not open database"];
            fBlock(err);
            return;
        }
        NSString *query;
        FMResultSet *results;
        if(numWords > 0){
            
            query = [NSString stringWithFormat:@"SELECT * FROM hindi ORDER BY RANDOM() LIMIT %@",numWords];
            results = [db executeQuery:query];
            
        }
        
        while([results next])
        {
            
            DictData *dicData = [[DictData alloc] init];
            dicData.mID = @([results intForColumnIndex:0]);
            dicData.mWord = [results stringForColumnIndex:1];
            dicData.mPronunciation = [results stringForColumnIndex:2];
            dicData.mMeaning = [results stringForColumnIndex:3];
            dicData.mHistory = [results stringForColumnIndex:4];
            dicData.mFavorit = [results stringForColumnIndex:5];
            
            [rows addObject:dicData];
        }
        
        if(rows){
            fBlock(nil);
        }
        else{
            NSError *err = [self errObjectWithMsg:@"No row found"];
            fBlock(err);
            [db close];
            return;
        }
        [db close];
    });
}





#pragma mark - helper methods

-(NSError *) errObjectWithMsg:(NSString *) msg
{
    NSError *err = [NSError errorWithDomain:@"DataManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: msg}];
    return err;
}

@end
