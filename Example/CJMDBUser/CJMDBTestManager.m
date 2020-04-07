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
@"status":         @"text"\
}

@implementation CJMDBTestManager

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // 初始化1，dbName：默认是 default，mainDirectory：默认是 xx/Documents/com.cjm.db
        _dbUser = [[CJMDBUser alloc] initWithDbName:@"user_101"
                                      mainDirectory:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CJMDB"]];
        
//        // 初始化2
//        _dbUser = [[CJMDBUser alloc] init];
//        
//        // 修改数据库名称，默认是 default
//        _dbUser.dbName = @"user_102";
//        
//        // 修改主目录，默认是 xx/Documents/com.cjm.db
//        _dbUser.mainDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CJMDB2"];
        
        // 创建表，SenderTableName：表名；SenderTableFields：表的字段定义
        [_dbUser createTableAndInsertRecordIfNotExists:SenderTableName withTableFields:SenderTableFields];
        
        
        // 插入数据
        [_dbUser insertIntoTable:SenderTableName withValues:@{@"msg_id":@"1", @"msg":@"hello1", @"sender":@"101", @"peer":@"101", @"status":@0}];
        [_dbUser insertIntoTable:SenderTableName withValues:@{@"msg_id":@"2", @"msg":@"hello2", @"sender":@"102", @"peer":@"102", @"status":@0}];

        NSLog(@"select count=%ld", [_dbUser selectCountFromTable:SenderTableName withCondition:nil]);
        
        NSArray *valuesArray = [_dbUser selectAllFromTable:SenderTableName
                                             withCondition:[NSString stringWithFormat:@"msg_id=%@", CJMDBValue(@"1")]
                                                     order:@"msg_id ASC"
                                                     limit:@"1"];
        NSLog(@"valuesArray=%@", valuesArray);
        
        // 更新数据
        [_dbUser updateTable:SenderTableName
                  withValues:@{@"msg_id":@"1", @"status":@1}
                   condition:[NSString stringWithFormat:@"msg_id=%@", CJMDBValue(@"1")]];
        
        NSArray *valuesArray2 = [_dbUser selectAllFromTable:SenderTableName
                                             withCondition:[NSString stringWithFormat:@"msg_id=%@", CJMDBValue(@"1")]
                                                     order:@"msg_id ASC"
                                                     limit:@"1"];
        NSLog(@"valuesArray2=%@", valuesArray2);
        
        // 删除数据
        [_dbUser deleteFromTable:SenderTableName withCondition:[NSString stringWithFormat:@"msg_id=%@", CJMDBValue(@"1")]];

        NSLog(@"select count=%ld", [_dbUser selectCountFromTable:SenderTableName withCondition:nil]);
        
        // 删除表
        [_dbUser dropTableAndDeleteRecordIfExists:SenderTableName];

    }
    return self;
}

@end
