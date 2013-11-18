//
//  DLAVUsecase.h
//  DLAlertView
//
//  Created by Vincent Esche on 01/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DLAVUsecaseBlock)(void);

@interface DLAVUsecase : NSObject

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSString *sectionName;
@property (readonly, strong, nonatomic) DLAVUsecaseBlock block;

- (id)initWithName:(NSString *)name sectionName:(NSString *)sectionName block:(DLAVUsecaseBlock)block;
+ (instancetype)usecaseWithName:(NSString *)name sectionName:(NSString *)sectionName block:(DLAVUsecaseBlock)block;

@end
