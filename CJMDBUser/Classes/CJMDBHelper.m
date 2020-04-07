//
//  CJMDBHelper.m
//  CJMDBUser
//
//  Created by chenjm on 2020/4/4.
//

#import "CJMDBHelper.h"

NSString *CJMDBValue(id value) {
    if ([value isKindOfClass:[NSValue class]]) {
        return [NSString stringWithFormat:@"%@", value];
    } else {
        return [NSString stringWithFormat:@"'%@'", value];
    }
}


@implementation CJMDBHelper


#pragma mark - 创建表

/**
 * @brief 如果表不存在，则创建表
 * @param tableName 表名
 * @param tableFields 表字段
 * @param db 数据库
 * @return 表是否创建成功。YES：表已经创建了，即是之前已经存在也返回YES。NO：表示创建表失败。
 */
+ (BOOL)createTableIfNotExists:(NSString *_Nonnull)tableName
               withTableFields:(NSDictionary *_Nullable)tableFields
                          inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(db);
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", tableName];
    
    NSArray *allKeys = tableFields.allKeys;
    for (NSString *key in allKeys) {
        sql = [sql stringByAppendingFormat:@"%@ %@,", key, tableFields[key]];
    }
    
    // 截掉末尾的@","
    if ([sql hasSuffix:@","]) {
        sql = [sql substringToIndex:sql.length - 1];
    }
    
    sql = [sql stringByAppendingString:@");"];
    
    BOOL result = [db executeUpdate:sql];
    if (!result) {
        NSLog(@"CJMDBUsers warning: Can't create table:%@", tableName);
    }
    
    return result;
}


#pragma mark - 删除表

/**
 * @brief 如果表存在，则删除表
 * @param tableName 表名
 * @param db 数据库
 * @return YES：删除成功，NO：删除失败
 */
+ (BOOL)dropTableIfExists:(NSString *_Nonnull)tableName inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(db);
    
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;", tableName];
    BOOL result = [db executeUpdate:sql];
    // TODO:如果不存在，result的YES和NO表示什么意思？
    
    return result;
}


#pragma mark - 删除数据

/**
 * @brief 删除表中符合条件的数据
 * @param tableName 表名
 * @param condition 查询的条件 @“key=value AND key=value AND key<value AND key>value”
 * @param db 数据库
 * @return YES：操作成功, NO：操作失败
 */
+ (BOOL)deleteFromTable:(NSString *_Nonnull)tableName
          withCondition:(NSString *_Nullable)condition
                   inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(db);
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    
    if (condition && [condition isKindOfClass:[NSString class]]) {
        sql = [NSString stringWithFormat:@" %@ WHERE %@", sql, condition];
    }
    
    BOOL flag = [db executeUpdate:sql];
    
    return flag;
}


#pragma mark - 查询数据

/**
 * @brief 是否存在表
 * @param tableName 表名
 * @param db 数据库
 * @return YES：存在, NO：不存在
 */
+ (BOOL)isExistTable:(NSString *_Nonnull)tableName inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(db);
    
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) AS 'count' FROM sqlite_master WHERE type ='table' AND name = '%@'", tableName];
    FMResultSet *rs = [db executeQuery:sql];
    
    BOOL flag = NO;
    
    while ([rs next]) {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count) {
            flag = NO;
        } else {
            flag = YES;
        }
        
        break;
    }
    
    [rs close];
    
    return flag;
}

/**
 * @brief 查询符合条件的数据的个数
 * @param tableName 表名
 * @param condition 查询的条件 @“key=value AND key=value AND key<value AND key>value”
 * @param db 数据库
 * @return 符合条件的数据个数
 */
+ (NSInteger)selectCountFromTable:(NSString *_Nonnull)tableName
                    withCondition:(NSString *_Nullable)condition
                             inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(db);
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS countNum FROM %@", tableName];
    if (condition && [condition isKindOfClass:[NSString class]]) {
        sql = [NSString stringWithFormat:@"%@ WHERE %@", sql, condition];
    }
    
    FMResultSet *rs = [db executeQuery:sql];
    
    NSInteger count = 0;
    
    while ([rs next]) {
        count = [rs intForColumn:@"countNum"];
        break;
    }
    
    [rs close];
    
    return count;
}

/**
 * @brief 查询数据
 * @param tableName 表名
 * @param condition 查询的条件 @“key=value AND key=value AND key<value AND key>value”
 * @param order 排序。升序：@"key ASC"；降序：@"key DESC"
 * @param limit 限制，可用于分页查询，第n页：@"limit 5*(n-1), 5"
 * @param db 数据库
 * @return 返回符合条件的数据
 */
+ (NSArray *_Nonnull)selectAllFromTable:(NSString *_Nonnull)tableName
                          withCondition:(NSString *_Nullable)condition
                                  order:(NSString *_Nullable)order
                                  limit:(NSString *_Nullable)limit
                                   inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(db);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    if (condition && [condition isKindOfClass:[NSString class]]) {
        sql = [NSString stringWithFormat:@"%@ WHERE %@", sql, condition];
    }
    
    if (order && [order isKindOfClass:[NSString class]]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY %@", sql, order];
    }
    
    if (limit) {
        sql = [NSString stringWithFormat:@" %@ limit %@", sql, limit];
    }
    
    FMResultSet *rs = [db executeQuery:sql];
    
    while ([rs next]) {
        NSDictionary *resutlDic = [rs resultDictionary];
        [array addObject:resutlDic];
    }
    
    [rs close];
    
    return array;
}


#pragma mark - 插入数据

/**
 * @brief 插入一行数据
 * @param tableName 表名
 * @param values 要插入的数据
 * @param db 数据库
 * @return YES：操作成功，NO：操作失败
*/
+ (BOOL)insertIntoTable:(NSString *_Nonnull)tableName
             withValues:(NSDictionary *_Nonnull)values
                   inDB:(FMDatabase *_Nonnull)db {
    return [self insertIntoTable:tableName withValues:values lastRowId:NULL inDB:db];
}

/**
 * @brief 插入一行数据
 * @param values 要插入的数据
 * @param lastRowId 返回的最新的row id
 * @param db 数据库
 * @return YES：操作成功，NO：操作失败
 */
+ (BOOL)insertIntoTable:(NSString *_Nonnull)tableName
             withValues:(NSDictionary *_Nonnull)values
              lastRowId:(out NSInteger *_Nullable)lastRowId
                   inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(values);
    NSParameterAssert(db);
    
    NSString *titleSql = [NSString stringWithFormat:@"INSERT INTO %@ (", tableName];
    NSString *valueSql = @") VALUES(";
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *key in values.allKeys) {
        id value = [self converJSONObject:values[key]];
        if (!value || [value isEqual:[NSNull null]]) {
            continue;
        }
        titleSql = [titleSql stringByAppendingFormat:@"%@,", key];
        valueSql = [valueSql stringByAppendingFormat:@"?,"];
        [array addObject:value];
    }
    
    if ([titleSql hasSuffix:@","]) {
        titleSql = [titleSql substringToIndex:titleSql.length - 1];
    }
    
    if ([valueSql hasSuffix:@","]) {
        valueSql = [valueSql substringToIndex:valueSql.length - 1];
    }
    
    NSString *sql = [titleSql stringByAppendingFormat:@"%@)", valueSql];
    
    BOOL result = [db executeUpdate:sql withArgumentsInArray:array];
    
    if (!result) {
        NSLog(@"%s error=%@", __func__, values);
    }
    
    if (lastRowId) {
        *lastRowId = [db lastInsertRowId];
    }
    
    return result;
}


#pragma mark - 替换数据

/**
 * @brief 替换一行数据
 * @param tableName 表名
 * @param values 要替换的数据
 * @param db 数据库
 * @return YES：操作成功，NO：操作失败
 */
+ (BOOL)replaceIntoTable:(NSString *_Nonnull)tableName
              withValues:(NSDictionary *_Nonnull)values
                    inDB:(FMDatabase *_Nonnull)db {
    return [self replaceIntoTable:tableName withValues:values inDB:db];
}

/**
 * @brief 替换一行数据
 * @param tableName 表名
 * @param values 要替换的数据
 * @param lastRowId 返回的最新id
 * @param db 数据库
 * @return YES：操作成功，NO：操作失败
 */
+ (BOOL)replaceIntoTable:(NSString *_Nonnull)tableName
              withValues:(NSDictionary *_Nonnull)values
               lastRowId:(out NSInteger *_Nullable)lastRowId
                    inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(values);
    NSParameterAssert(db);
    
    NSString *titleSql = [NSString stringWithFormat:@"REPLACE INTO %@ (", tableName];
    NSString *valueSql = @") VALUES(";
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *key in values.allKeys) {
        id value = [self converJSONObject:values[key]];
        titleSql = [titleSql stringByAppendingFormat:@"%@,", key];
        valueSql = [valueSql stringByAppendingFormat:@"?,"];
        
        [array addObject:value];
    }
    
    if ([titleSql hasSuffix:@","]) {
        titleSql = [titleSql substringToIndex:titleSql.length - 1];
    }
    
    if ([valueSql hasSuffix:@","]) {
        valueSql = [valueSql substringToIndex:valueSql.length - 1];
    }
    
    NSString *sql = [titleSql stringByAppendingFormat:@"%@)", valueSql];
    
    BOOL result = [db executeUpdate:sql withArgumentsInArray:array];
    
    if (!result) {
        NSLog(@"%s error=%@", __func__, values);
    }
        
    if (lastRowId) {
        *lastRowId = [db lastInsertRowId];
    }
    
    return result;
    
}


#pragma mark - 更新数据

/**
 * @brief 更新信息
 * @param condition 查询的条件 @“key=value AND key=value AND key<value AND key>value”
 * @param db 数据库
 * @return YES：操作成功，NO：操作失败
 */
+ (BOOL)updateTable:(NSString *_Nonnull)tableName
         withValues:(NSDictionary *_Nonnull)values
          condition:(NSString *_Nonnull)condition
               inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(values);
    NSParameterAssert(db);
    
    BOOL result = NO;
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET ", tableName];
    
    for (NSString *tmpKey in values.allKeys) {
        id tmpValue = [self converJSONObject:values[tmpKey]];
        sql = [sql stringByAppendingFormat:@"%@=%@,", tmpKey, CJMDBValue(tmpValue)];
    }
    
    if ([sql hasSuffix:@","]) {
        sql = [sql substringToIndex:sql.length - 1];
    }
    
    if (condition && [condition isKindOfClass:[NSString class]]) {
        sql = [sql stringByAppendingFormat:@" WHERE %@", condition];
    }
    
    result = [db executeUpdate:sql];
    
    if (!result) {
        NSLog(@"%s error=%@", __func__, values);
    }
    
    return result;
}

/*
 * @brief 添加主键
 * @param tableName 表名
 * @param primaryKeys 复合主键
 * @return YES：添加成功；NO：添加失败。
 */
+ (BOOL)updateTable:(NSString *_Nonnull)tableName
      addPimaryKeys:(NSArray *_Nullable)primaryKeys
               inDB:(FMDatabase *_Nonnull)db {
    NSParameterAssert(tableName);
    NSParameterAssert(db);
    //alter table table_name add primary key
    NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD PRIMARY KEY (", tableName];
    
    NSArray *allKeys = [primaryKeys copy];
    for (NSString *key in allKeys) {
        sql = [sql stringByAppendingFormat:@"%@,", key];
    }
    
    // 截掉末尾的@","
    if ([sql hasSuffix:@","]) {
        sql = [sql substringToIndex:sql.length - 1];
    }
    
    sql = [sql stringByAppendingString:@");"];
    
    BOOL result = [db executeUpdate:sql];
    if (!result) {
        NSLog(@"CJMDBUsers warning: Can't add primary key for table:%@", tableName);
    }
    return result;
}


#pragma mark - 转化

/**
 * @brief 转化数据，如果是字典转化为字符串，如果是NSString或NSNumber，则不用转。
 * @param jsonObject json对象
 * @return 转化为字符串，或者NSNumber类型。
 */
+ (nonnull id)converJSONObject:(id)jsonObject {
    @try {
        if (!jsonObject) {
            return @"";
        }
        
        if ([jsonObject isKindOfClass:[NSString class]] ||
            [jsonObject isKindOfClass:[NSNumber class]] ||
            [jsonObject isKindOfClass:[NSNull class]]) {
            
            return (NSString *)jsonObject;
        } else if ([jsonObject isKindOfClass:[NSDictionary class]] ||
                   [jsonObject isKindOfClass:[NSArray class]]) {
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error];
            NSString *jsonStr = nil;
            if (error) {
                NSLog(@"%s error:%@", __func__, error.description);
            } else {
                 jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            
            return jsonStr ? : @"";
        }
    } @catch (NSException *exception) {
        return @"";
    }
}



@end
