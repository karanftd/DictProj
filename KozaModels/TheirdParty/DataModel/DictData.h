//
//  DictData.h
//  KozaModels
//
//  Created by Karan Patel on 17/02/15.
//  Copyright (c) 2015 Koaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictData : NSObject


@property (nonatomic, strong) NSNumber *mID;
@property (nonatomic, strong) NSString *mWord;
@property (nonatomic, strong) NSString *mPronunciation;
@property (nonatomic, strong) NSString *mMeaning;
@property (nonatomic) BOOL mHistory;
@property (nonatomic) BOOL mFavorit;


@end
