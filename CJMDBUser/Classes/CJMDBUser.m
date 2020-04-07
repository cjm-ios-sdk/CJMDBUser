//
//  CJMDBUser.m
//  CJMDBUser
//
//  Created by chenjm on 2020/4/5.
//

#import "CJMDBUser.h"

#define CJMDBDefaultName @"default"

#define CJMDBVersionTableName @"version"

#define CJMDBVersionTableFields  @{\
@"table_name":         @"text PRIMARY KEY",\
@"version":            @"text"\
}

@interface CJMDBUser ()
@property (nonatomic, copy) NSString *appShortVersion;
@end


@implementation CJMDBUser
@synthesize queue = _queue;
@synthesize dbPath = _dbPath;


#pragma mark - 初始化

- (instancetype)init {
    return [self initWithDbName:nil mainDirectory:nil];
}

- (instancetype)initWithDbName:(NSString *)dbName {
    return [self initWithDbName:dbName mainDirectory:nil];
}

- (instancetype)initWithDbName:(NSString *)dbName mainDirectory:(NSString *)mainDirectory {
    self = [super init];
    if (self) {
        _appShortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        if (!_appShortVersion) {
            _appShortVersion = @"0";
        }

        _dbName = dbName ? [dbName copy] : CJMDBDefaultName;
        
        _mainDirectory = mainDirectory ? [mainDirectory copy] : [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/com.cjmdb.multisuer"];
        
        _dbPath = [_mainDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _dbName]];
        
        NSLog(@"_dbPath=%@", _dbPath);
    }
    return self;
}


#pragma mark - Accessor

- (void)setDbName:(NSString *)dbName {
    if ([_dbName isEqualToString:dbName]) {
        return;
    }
    
    _dbName = [dbName copy];
    _dbPath = [_mainDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _dbName]];
}

- (void)setMainDirectory:(NSString *)mainDirectory {
    if ([_mainDirectory isEqualToString:_mainDirectory]) {
        return;
    }
    _mainDirectory = [mainDirectory copy];
    _dbPath = [_mainDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _dbName]];
}

/// 检查更新队列，当 dbPath 发生变化时，队列也需要重新创建。
- (FMDatabaseQueue *)queue {
    if (_queue && _queue.path && [_queue.path isEqualToString:_dbPath]) {
        return _queue;
    }
    
    // 创建目录
    [self cjm_createMainDirectoryIfNotExists];
    
    // 初始化队列
    _queue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    
    // 创建version表
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL flag = NO;
        flag = [CJMDBHelper createTableIfNotExists:CJMDBVersionTableName withTableFields:CJMDBVersionTableFields inDB:db];
        if (!flag) {
            NSLog(@"创建version表失败。");
        }
    }];
    
    return _queue;
}


#pragma mark - Private Method

/// 创建一个主目录，如果不存在的话。
- (void)cjm_createMainDirectoryIfNotExists {
    if (![[NSFileManager defaultManager] fileExistsAtPath:_mainDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_mainDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];;
    }
}

/// 检查升级
- (void)cjm_checkUpgradeWithTableName:(NSString *)tableName withTableFields:(NSDictionary *)tableFields {
    NSString *condition = [NSString stringWithFormat:@"table_name=%@", CJMDBValue(tableName)];
    NSArray *tableInfos = [self selectAllFromTable:CJMDBVersionTableName
                                     withCondition:condition
                                             order:nil
                                             limit:@"1"];
    
    // 判断是否要更新数据库
    if (tableInfos.count > 0) {
        NSDictionary *tableInfo = tableInfos[0];
        NSString *recordVersion = tableInfo[@"version"];
        
        NSComparisonResult result = [recordVersion compare:_appShortVersion options:NSNumericSearch];
        if (result == NSOrderedAscending) {
            [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                for (NSString *key in tableFields.allKeys) {
                    if (![db columnExists:key inTableWithName:tableName]) {
                        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", tableName, key, tableFields[key]];
                        
                        BOOL worked = [db executeUpdate:alertStr];
                        if (!worked) {
                            NSLog(@"worked 失败");
                        }
                    }
                }
                
                NSDictionary *info = @{@"version": _appShortVersion};
                NSString *condition = [NSString stringWithFormat:@"table_name=%@", CJMDBValue(tableName)];
                [CJMDBHelper updateTable:CJMDBVersionTableName withValues:info condition:condition inDB:db];
            }];
        }
    }
}


#pragma mark - 创建和删除表

/**
 * @brief 创建和记录，每创建一个表都会向version表添加一个记录。
 * @param tableName 表名
 * @param tableFields 表的标签
 * @return YES：创建成功或者已经存在；NO：创建失败。
*/
- (BOOL)createTableAndInsertRecordIfNotExists:(NSString *)tableName withTableFields:(NSDictionary *)tableFields {
    NSParameterAssert(tableName);
    NSParameterAssert(tableFields);
    
    // 如果是version表，不操作，返回失败。
    if ([tableName isEqualToString:CJMDBVersionTableName]) {
        return NO;
    }

    __block BOOL flag = NO;
    
    // 如果不存在，创建一个新的表
    [self.queue inDatabase:^(FMDatabase *db) {
        flag = [CJMDBHelper createTableIfNotExists:tableName withTableFields:tableFields inDB:db];
        if (!flag) {
            NSLog(@"创建失败：%@", tableName);
        }
    }];
    
    NSString *condition = [NSString stringWithFormat:@"table_name=%@", CJMDBValue(tableName)];
    NSInteger count = [self selectCountFromTable:CJMDBVersionTableName withCondition:condition];
    
    // 查询该表有没有记录到version表，如果没有，则插入一条新的。
    if (0 == count) { 
        NSDictionary *values = @{@"version":_appShortVersion,
                                 @"table_name":tableName};
        
        BOOL insertFlag = [self insertIntoTable:CJMDBVersionTableName withValues:values lastRowId:nil];
        if (insertFlag) {
            NSLog(@"插入 %@ 到version表，成功", tableName);
        } else {
            NSLog(@"插入 %@ 到version表，失败", tableName);
        }
    } else {
        [self cjm_checkUpgradeWithTableName:tableName withTableFields:tableFields];
    }
    
    return flag;
}

/**
 * @brief 删除表和记录，每删除一个表都会把版本记录表「SLDBVersionTableName」删除一个记录。
 * @param tableName 表名
 * @return YES：删除表成功；NO：删除表失败。
 */
- (BOOL)dropTableAndDeleteRecordIfExists:(NSString *)tableName {
    NSParameterAssert(tableName);
    
    if ([tableName isEqualToString:CJMDBVersionTableName]) {
        return NO;
    }
    
    __block BOOL flag = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        flag = [CJMDBHelper dropTableIfExists:tableName inDB:db];
        
        NSString *condition = [NSString stringWithFormat:@"table_name=%@", CJMDBValue(tableName)];
        if ([CJMDBHelper selectCountFromTable:CJMDBVersionTableName withCondition:condition inDB:db] > 0) {
            flag = [CJMDBHelper deleteFromTable:CJMDBVersionTableName withCondition:condition inDB:db];
        }
    }];
    
    return flag;
}


#pragma mark - 添加主键

/**
 * @brief 添加主键。
 * @param tableName 表名
 * @param primaryKeys 复合主键
 * @return YES：创建成功或者已经存在；NO：创建失败。
 */
- (BOOL)updateTable:(NSString *)tableName addPimaryKeys:(NSArray *)primaryKeys {
    NSParameterAssert(tableName);
    NSParameterAssert(primaryKeys);

    if ([tableName isEqualToString:CJMDBVersionTableName]) {
        return NO;
    }
    
    __block BOOL flag = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        flag = [CJMDBHelper updateTable:tableName addPimaryKeys:primaryKeys inDB:db];
    }];
    return flag;
}

#pragma mark - 删除数据

/**
 * @brief 删除
 * @param tableName 表名
 * @param condition 查询的条件 key=value AND key=value AND key<value AND key>value
 * @return YES：操作成功, NO：操作失败
 */
- (BOOL)deleteFromTable:(NSString *)tableName withCondition:(NSString *)condition {
    __block BOOL flag = NO;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            flag = [CJMDBHelper deleteFromTable:tableName withCondition:condition inDB:db];
        } @catch (NSException *exception) {
            NSLog(@"%s exception=%@", __func__, exception.description);
            
            *rollback = YES;
            flag = NO;
        }
    }];

    return flag;
}


#pragma mark - 查询数据

/**
 * @brief 是否存在表
 * @param tableName 表名
 * @return YES：存在；NO：不存在。
 */
- (BOOL)isExistTable:(NSString *)tableName {
    __block BOOL isExist = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        isExist = [CJMDBHelper isExistTable:tableName inDB:db];
    }];
    
    return isExist;
}

/**
 * @brief 查询符合条件的个数
 * @param tableName 表名
 * @param condition 查询条件
 * @return 个数
 */
- (NSInteger)selectCountFromTable:(NSString *)tableName withCondition:(NSString *)condition {
    __block NSInteger count = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        count = [CJMDBHelper selectCountFromTable:tableName withCondition:condition inDB:db];
    }];
    
    return count;
}

/**
 * @brief 查询数据
 * @param tableName 表名
 * @param condition 查询的条件 key=value AND key=value AND key<value AND key>value
 * @param order 排序。升序：@"key ASC"；降序：@"key DESC"
 * @param limit 限制，可用于分页查询，第n页：@"limit 5*(n-1), 5"
 * @return 返回查询的结果
 */
- (NSArray *)selectAllFromTable:(NSString *)tableName
                  withCondition:(NSString *)condition
                          order:(NSString *)order
                          limit:(NSString *)limit {
    __block NSArray *array = nil;
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            array = [CJMDBHelper selectAllFromTable:tableName
                                      withCondition:condition
                                              order:order
                                              limit:limit
                                               inDB:db];
        } @catch (NSException *exception) {
            *rollback = YES;
            array = nil;
            
            NSLog(@"%s, %@", __func__, exception.description);
        }
    }];
    
    return array;
}


#pragma mark - 插入

/**
 * @brief 插入一行
 * @param tableName 表名
 * @param values 要插入的数据
 * @return YES：插入成功；NO：插入失败
 */
- (BOOL)insertIntoTable:(NSString *)tableName withValues:(NSDictionary *)values {
    return [self insertIntoTable:tableName withValues:values lastRowId:nil];
}

/**
 * @brief 插入一行
 * @param tableName 表名
 * @param values 要插入的数据
 * @param lastRowId 返回插入的最新id
 * @return YES：插入成功；NO：插入失败
 */
- (BOOL)insertIntoTable:(NSString *)tableName
             withValues:(NSDictionary *)values
              lastRowId:(NSInteger *)lastRowId {
    __block BOOL result = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        @try {
            result = [CJMDBHelper insertIntoTable:tableName withValues:values lastRowId:lastRowId inDB:db];
            if (lastRowId) {
                *lastRowId = [db lastInsertRowId];
            }
        } @catch (NSException *exception) {
            result = nil;
            
            NSLog(@"%s exception=%@", __func__, exception.description);
        }
    }];
    
    return result;
}


#pragma mark - 替换

/**
 * @brief 替换一行
 * @param tableName 表名
 * @param values 要替换的数据
 * @return YES：替换成功；NO：替换失败
 */
- (BOOL)replaceIntoTable:(NSString *)tableName withValues:(NSDictionary *)values {
    return [self replaceIntoTable:tableName withValues:values];
}

/**
 * @brief 替换一行
 * @param tableName 表名
 * @param values 要替换的数据
 * @param lastRowId 返回替换后的最新id
 * @return YES:插入成功 NO:插入失败
 */
- (BOOL)replaceIntoTable:(NSString *)tableName withValues:(NSDictionary *)values lastRowId:(NSInteger *)lastRowId {
    __block BOOL result = NO;    
    [self.queue inDatabase:^(FMDatabase *db) {
        @try {
            result = [CJMDBHelper replaceIntoTable:tableName withValues:values lastRowId:lastRowId inDB:db];
            if (lastRowId) {
                *lastRowId = [db lastInsertRowId];
            }
        } @catch (NSException *exception) {
            NSLog(@"%s exception=%@", __func__, exception.description);
        }
    }];
    
    return result;
}


#pragma mark - 更新

/**
 * @brief 更新一行
 * @param tableName 表名
 * @param values 更新数据
 * @param condition 查询的条件 key=value AND key=value AND key<value AND key>value
 * @return YES：成功, NO：失败
 */
- (BOOL)updateTable:(NSString *)tableName
         withValues:(NSDictionary *)values
          condition:(NSString *)condition {
    __block BOOL result = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        @try {
            result = [CJMDBHelper updateTable:tableName withValues:values condition:condition inDB:db];
        } @catch (NSException *exception) {
            NSLog(@"%s exception=%@", __func__, exception.description);
        }
    }];
    
    return result;
}

@end
