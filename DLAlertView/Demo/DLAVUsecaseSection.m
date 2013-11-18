//
//  DLAVUsecaseSection.m
//  DLAlertView
//
//  Created by Vincent Esche on 01/11/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import "DLAVUsecaseSection.h"

@implementation DLAVUsecaseSection

- (id)initWithName:(NSString *)name objectIndexes:(NSIndexSet *)objectIndexes {
	self = [super init];
	if (self) {
		_name = name;
		_objectIndexes = objectIndexes;
	}
	return self;
}

+ (instancetype)sectionWithName:(NSString *)name objectIndexes:(NSIndexSet *)objectIndexes {
	return [[self alloc] initWithName:name objectIndexes:objectIndexes];
}

@end
