//
//  DLAVUsecase.m
//  DLAlertView
//
//  Created by Vincent Esche on 01/11/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import "DLAVUsecase.h"

@interface DLAVUsecase ()

@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, strong, nonatomic) NSString *sectionName;
@property (readwrite, strong, nonatomic) DLAVUsecaseBlock block;

@end

@implementation DLAVUsecase

- (id)initWithName:(NSString *)name sectionName:(NSString *)sectionName block:(DLAVUsecaseBlock)block {
    self = [self init];
    if (self) {
        _name = name;
		_sectionName = sectionName;
		_block = block;
    }
    return self;
}

+ (instancetype)usecaseWithName:(NSString *)name sectionName:(NSString *)sectionName block:(DLAVUsecaseBlock)block {
	return [[self alloc] initWithName:name sectionName:sectionName block:block];
}

@end
