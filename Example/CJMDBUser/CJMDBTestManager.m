//
//  CJMDBTestManager.m
//  CJMDBUsers_Example
//
//  Created by chenjm on 2020/4/5.
//  Copyright © 2020 chenjm. All rights reserved.
//

#import "CJMDBTestManager.h"

#define SenderTableName @"sender"
#define SenderTableFields  @{\
@"msg_id":         @"text PRIMARY KEY",\
@"msg":            @"text",\
@"sender":         @"text",\
@"peer":           @"text",\
}

@implementation CJMDBTestManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _dbUser = [[CJMDBUser alloc] init];
        
        // 创建表
        [_dbUser createTableAndInsertRecordIfNotExists:SenderTableName withTableFields:SenderTableFields];
        
        
        [_dbUser insertIntoTable:SenderTableName withValues:@{@"msg_id":@"1", @"msg":@"hello1", @"sender":@"101", @"peer":@"101"}];
        [_dbUser insertIntoTable:SenderTableName withValues:@{@"msg_id":@"2", @"msg":@"hello2", @"sender":@"102", @"peer":@"102"}];
        [_dbUser insertIntoTable:SenderTableName withValues:@{@"msg_id":@"3", @"msg":@"hello3", @"sender":@"103", @"peer":@"103"}];
        [_dbUser insertIntoTable:SenderTableName withValues:@{@"msg_id":@"4", @"msg":@"hello4", @"sender":@"104", @"peer":@"103"}];
        [_dbUser insertIntoTable:SenderTableName withValues:@{@"msg_id":@"8", @"msg":@"hello8", @"sender":@"108"}];


        
    }
    return self;
}

@end
