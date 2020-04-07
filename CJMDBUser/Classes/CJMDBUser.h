//
//  CJMDBUser.h
//  CJMDBUser
//
//  Created by chenjm on 2020/4/5.
//

#import <Foundation/Foundation.h>
#import "CJMDBHelper.h"

@interface CJMDBUser : NSObject
@property (nonatomic, copy) NSString *dbName;                   /// 数据库名称，默认为 default。如果需要区分用户，可以使用userId作为唯一标示。
@property (nonatomic, copy) NSString *mainDirectory;            /// 数据库存放的主目录，默认为 xx/documents/com.cjm.db
@property (nonatomic, readonly) NSString *dbPath;               /// 数据库路径，由 directoryPath 和 userId 拼接而成的路径
@property (nonatomic, strong, readonly) FMDatabaseQueue *queue; /// 数据库操作队列


#pragma mark - 初始化

- (instancetype)initWithDbName:(NSString *)dbName;
- (instancetype)initWithDbName:(NSString *)dbName mainDirectory:(NSString *)mainDirectory;


#pragma mark - 创建和删除表

/**
 * @brief 创建和记录，每创建一个表都会向version表添加一个记录。
 * @param tableName 表名
 * @param tableFields 表的标签
 * @return YES：创建成功或者已经存在；NO：创建失败。
 */
- (BOOL)createTableAndInsertRecordIfNotExists:(NSString *)tableName withTableFields:(NSDictionary *)tableFields;

/**
 * @brief 删除表和记录，每删除一个表都会把版本记录表「SLDBVersionTableName」删除一个记录。
 * @param tableName 表名
 * @return YES：删除表成功；NO：删除表失败。
 */
- (BOOL)dropTableAndDeleteRecordIfExists:(NSString *)tableName;


#pragma mark - 添加主键

/**
 * @brief 添加主键。
 * @param tableName 表名
 * @param primaryKeys 复合主键
 * @return YES：创建成功或者已经存在；NO：创建失败。
 */
- (BOOL)updateTable:(NSString *)tableName addPimaryKeys:(NSArray *)primaryKeys;


#pragma mark - 删除数据

/**
 * @brief 删除
 * @param tableName 表名
 * @param condition 查询的条件 key=value AND key=value AND key<value AND key>value
 * @return YES：操作成功, NO：操作失败
 */
- (BOOL)deleteFromTable:(NSString *)tableName withCondition:(NSString *)condition;


#pragma mark - 查询数据

/**
 * @brief 是否存在表
 * @param tableName 表名
 * @return YES：存在；NO：不存在。
 */
- (BOOL)isExistTable:(NSString *)tableName;

/**
 * @brief 查询符合条件的个数
 * @param tableName 表名
 * @param condition 查询条件
 * @return 个数
 */
- (NSInteger)selectCountFromTable:(NSString *)tableName withCondition:(NSString *)condition;

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
                          limit:(NSString *)limit;


#pragma mark - 插入数据

/**
 * @brief 插入一行
 * @param tableName 表名
 * @param values 要插入的数据
 * @return YES：插入成功；NO：插入失败
 */
- (BOOL)insertIntoTable:(NSString *)tableName withValues:(NSDictionary *)values;

/**
 * @brief 插入一行
 * @param tableName 表名
 * @param values 要插入的数据
 * @param lastRowId 返回插入的最新id
 * @return YES：插入成功；NO：插入失败
 */
- (BOOL)insertIntoTable:(NSString *)tableName
             withValues:(NSDictionary *)values
              lastRowId:(NSInteger *)lastRowId;


#pragma mark - 替换数据

/**
 * @brief 替换一行
 * @param tableName 表名
 * @param values 要替换的数据
 * @return YES：替换成功；NO：替换失败
 */
- (BOOL)replaceIntoTable:(NSString *)tableName withValues:(NSDictionary *)values;
/**
 * @brief 替换一行
 * @param tableName 表名
 * @param values 要替换的数据
 * @param lastRowId 返回替换后的最新id
 * @return YES：替换成功；NO：替换失败
 */
- (BOOL)replaceIntoTable:(NSString *)tableName
              withValues:(NSDictionary *)values
               lastRowId:(NSInteger *)lastRowId;


#pragma mark - 更新数据

/**
 * @brief 更新一行
 * @param tableName 表名
 * @param values 更新数据
 * @param condition 查询的条件 key=value AND key=value AND key<value AND key>value
 * @return YES：成功, NO：失败
 */
- (BOOL)updateTable:(NSString *)tableName
         withValues:(NSDictionary *)values
          condition:(NSString *)condition;

@end


