//
//  DLAVUsecaseSection.h
//  DLAlertView
//
//  Created by Vincent Esche on 01/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLAVUsecaseSection : NSObject

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSIndexSet *objectIndexes;

- (id)initWithName:(NSString *)name objectIndexes:(NSIndexSet *)objectIndexes;
+ (instancetype)sectionWithName:(NSString *)name objectIndexes:(NSIndexSet *)objectIndexes;

@end
