//
//  CJMDBHelper.h
//  CJMDBUser
//
//  Created by chenjm on 2020/4/4.
//

#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>

@class FMDatabase;

extern NSString * _Nonnull CJMDBValue(_Nonnull id value);


@interface CJMDBHelper : NSObject


#pragma mark - 创建表

/**
 * @brief 如果表不存在，则创建表
 * @param tableName 表名
 * @param tableFields 表字段
 * @param db 数据库
 * @return YES：创建成功；NO：创建失败
 */
+ (BOOL)createTableIfNotExists:(NSString *_Nonnull)tableName
               withTableFields:(NSDictionary *_Nullable)tableFields
                          inDB:(FMDatabase *_Nonnull)db;


#pragma mark - 删除表

/**
 * @brief 如果表存在，则删除表
 * @param tableName 表名
 * @param db 数据库
 * @return YES：删除成功，NO：删除失败
 */
+ (BOOL)dropTableIfExists:(NSString *_Nonnull)tableName inDB:(FMDatabase *_Nonnull)db;


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
                   inDB:(FMDatabase *_Nonnull)db;


#pragma mark - 查询数据

/**
 * @brief 是否存在表
 * @param tableName 表名
 * @param db 数据库
 * @return YES：存在, NO：不存在
 */
+ (BOOL)isExistTable:(NSString *_Nonnull)tableName inDB:(FMDatabase *_Nonnull)db;

/**
 * @brief 查询符合条件的数据的个数
 * @param tableName 表名
 * @param condition 查询的条件 @“key=value AND key=value AND key<value AND key>value”
 * @param db 数据库
 * @return 符合条件的数据个数
 */
+ (NSInteger)selectCountFromTable:(NSString *_Nonnull)tableName
                    withCondition:(NSString *_Nullable)condition
                             inDB:(FMDatabase *_Nonnull)db;

/**
 * @brief 查询数据
 * @param tableName 表名
 * @param condition 查询的条件。 eg: @“key=value AND key=value AND key<value AND key>value”
 * @param order 排序。升序：@"key ASC"；降序：@"key DESC"
 * @param limit 限制，可用于分页查询，第n页：@"limit 5*(n-1), 5"
 * @param db 数据库
 * @return 返回符合条件的数据
 */
+ (NSArray *_Nonnull)selectAllFromTable:(NSString *_Nonnull)tableName
                          withCondition:(NSString *_Nullable)condition
                                  order:(NSString *_Nullable)order
                                  limit:(NSString *_Nullable)limit
                                   inDB:(FMDatabase *_Nonnull)db;


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
                   inDB:(FMDatabase *_Nonnull)db;

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
                   inDB:(FMDatabase *_Nonnull)db;


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
                    inDB:(FMDatabase *_Nonnull)db;

/**
 * @brief 替换一行数据
 * @param tableName 表名
 * @param values 要替换的数据
 * @param lastRowId 返回的最新 row id，
 * @param db 数据库
 * @return YES：操作成功，NO：操作失败
 */
+ (BOOL)replaceIntoTable:(NSString *_Nonnull)tableName
              withValues:(NSDictionary *_Nonnull)values
               lastRowId:(out NSInteger *_Nullable)lastRowId
                    inDB:(FMDatabase *_Nonnull)db;


#pragma mark - 更新数据

/**
 * @brief 更新信息
 * @param condition 查询的条件 @“key=value AND key=value AND key<value AND key>value”
 * @param db 数据库
 * @return YES：操作成功，NO：操作失败
 */
+ (BOOL)updateTable:(NSString *_Nonnull)table
         withValues:(NSDictionary *_Nonnull)values
          condition:(NSString *_Nonnull)condition
               inDB:(FMDatabase *_Nonnull)db;

/*
 * @brief 添加主键
 * @param tableName 表名
 * @param primaryKeys 复合主键
 * @return YES：添加成功；NO：添加失败。
 */
+ (BOOL)updateTable:(NSString *_Nonnull)tableName
      addPimaryKeys:(NSArray *_Nullable)primaryKeys
               inDB:(FMDatabase *_Nonnull)db;


@end
