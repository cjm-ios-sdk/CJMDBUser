//
//  CJMDBUser.h
//  CJMDBUser
//
//  Created by chenjm on 2020/4/5.
//

#import <Foundation/Foundation.h>
#import "CJMDBHelper.h"

@interface CJMDBUser : NSObject
@property (nonatomic, copy) NSString * _Nonnull dbName;                     /// 数据库名称，默认为 default。如果需要区分用户，可以使用userId作为唯一标示。
@property (nonatomic, copy) NSString *_Nonnull mainDirectory;               /// 数据库存放的主目录，默认为 xx/Documents/com.cjm.db
@property (nonatomic, readonly) NSString *_Nonnull dbPath;                  /// 数据库路径，由 Documents，directoryPath 和 userId 拼接而成的路径
@property (nonatomic, strong, readonly) FMDatabaseQueue * _Nonnull queue;   /// 数据库操作队列


#pragma mark - 初始化

- (instancetype _Nonnull)initWithDbName:(NSString *_Nullable)dbName;
- (instancetype _Nonnull)initWithDbName:(NSString *_Nullable)dbName mainDirectory:(NSString * _Nullable)mainDirectory;


#pragma mark - 创建和删除表

/**
 * @brief 创建和记录，每创建一个表都会向version表添加一个记录。
 * @param tableName 表名
 * @param tableFields 表的标签
 * @return YES：创建成功或者已经存在；NO：创建失败。
 */
- (BOOL)createTableAndInsertRecordIfNotExists:(NSString *_Nonnull)tableName withTableFields:(NSDictionary *_Nonnull)tableFields;

/**
 * @brief 删除表和记录，每删除一个表都会把版本记录表「SLDBVersionTableName」删除一个记录。
 * @param tableName 表名
 * @return YES：删除表成功；NO：删除表失败。
 */
- (BOOL)dropTableAndDeleteRecordIfExists:(NSString *_Nonnull)tableName;


#pragma mark - 添加主键

/**
 * @brief 添加主键。
 * @param tableName 表名
 * @param primaryKeys 复合主键
 * @return YES：创建成功或者已经存在；NO：创建失败。
 */
- (BOOL)updateTable:(NSString *_Nonnull)tableName addPimaryKeys:(NSArray *_Nonnull)primaryKeys;


#pragma mark - 删除数据

/**
 * @brief 删除
 * @param tableName 表名
 * @param condition 查询的条件 key=value AND key=value AND key<value AND key>value
 * @return YES：操作成功, NO：操作失败
 */
- (BOOL)deleteFromTable:(NSString *_Nonnull)tableName withCondition:(NSString *_Nullable)condition;


#pragma mark - 查询数据

/**
 * @brief 是否存在表
 * @param tableName 表名
 * @return YES：存在；NO：不存在。
 */
- (BOOL)isExistTable:(NSString *_Nonnull)tableName;

/**
 * @brief 查询符合条件的个数
 * @param tableName 表名
 * @param condition 查询条件
 * @return 个数
 */
- (NSInteger)selectCountFromTable:(NSString *_Nonnull)tableName withCondition:(NSString *_Nullable)condition;

/**
 * @brief 查询数据
 * @param tableName 表名
 * @param condition 查询的条件 key=value AND key=value AND key<value AND key>value
 * @param order 排序。升序：@"key ASC"；降序：@"key DESC"
 * @param limit 限制，可用于分页查询，第n页：@"limit 5*(n-1), 5"
 * @return 返回查询的结果
 */
- (NSArray *_Nonnull)selectAllFromTable:(NSString *_Nonnull)tableName
                          withCondition:(NSString *_Nullable)condition
                                  order:(NSString *_Nullable)order
                                  limit:(NSString *_Nullable)limit;


#pragma mark - 插入数据

/**
 * @brief 插入一行
 * @param tableName 表名
 * @param values 要插入的数据
 * @return YES：插入成功；NO：插入失败
 */
- (BOOL)insertIntoTable:(NSString *_Nonnull)tableName withValues:(NSDictionary *_Nonnull)values;

/**
 * @brief 插入一行
 * @param tableName 表名
 * @param values 要插入的数据
 * @param lastRowId 返回插入的最新id
 * @return YES：插入成功；NO：插入失败
 */
- (BOOL)insertIntoTable:(NSString *_Nonnull)tableName
             withValues:(NSDictionary *_Nonnull)values
              lastRowId:(NSInteger *_Nullable)lastRowId;


#pragma mark - 替换数据

/**
 * @brief 替换一行
 * @param tableName 表名
 * @param values 要替换的数据
 * @return YES：替换成功；NO：替换失败
 */
- (BOOL)replaceIntoTable:(NSString *_Nonnull)tableName withValues:(NSDictionary *_Nonnull)values;
/**
 * @brief 替换一行
 * @param tableName 表名
 * @param values 要替换的数据
 * @param lastRowId 返回替换后的最新id
 * @return YES：替换成功；NO：替换失败
 */
- (BOOL)replaceIntoTable:(NSString *_Nonnull)tableName
              withValues:(NSDictionary *_Nonnull)values
               lastRowId:(NSInteger *_Nullable)lastRowId;


#pragma mark - 更新数据

/**
 * @brief 更新一行
 * @param tableName 表名
 * @param values 更新数据
 * @param condition 查询的条件 key=value AND key=value AND key<value AND key>value
 * @return YES：成功, NO：失败
 */
- (BOOL)updateTable:(NSString *_Nonnull)tableName
         withValues:(NSDictionary *_Nonnull)values
          condition:(NSString *_Nullable)condition;

@end


