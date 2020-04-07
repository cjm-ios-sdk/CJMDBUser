# CJMDBUser


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

全局说明：

CJMDBUser是基于FMDB的用户数据库管理SDK。

实现的目的主要是为了解决多用户账号切换时的数据库管理和操作。

- 支持数据库字段增加等升级问题。

- 支持只对某些字段更新。

- 查询到数据直接转为字典或数组。

- 支持分页查询等。


## 使用说明

- 初始化1

```objc
// 初始化1，dbName：默认是 default，mainDirectory：默认是 xx/Documents/com.cjm.db
_dbUser = [[CJMDBUser alloc] initWithDbName:@"user_101"
                              mainDirectory:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CJMDB"]];
```

```objc
// 初始化2
_dbUser = [[CJMDBUser alloc] init];

// 修改数据库名称，默认是 default
_dbUser.dbName = @"user_102";

// 修改主目录，默认是 xx/Documents/com.cjm.db
_dbUser.mainDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CJMDB2"];
```

- 创建表

```objc
// 创建表，SenderTableName：表名；SenderTableFields：表的字段定义
[_dbUser createTableAndInsertRecordIfNotExists:SenderTableName withTableFields:SenderTableFields];
```
- 删除表

```objc
// 删除表
[_dbUser dropTableAndDeleteRecordIfExists:SenderTableName];
```

- 插入数据

```objc
[_dbUser insertIntoTable:SenderTableName withValues:@{@"msg_id":@"1", @"msg":@"hello1", @"sender":@"101", @"peer":@"101", @"status":@0}];
```

- 更新数据
```objc
// 更新数据
[_dbUser updateTable:SenderTableName
          withValues:@{@"msg_id":@"1", @"status":@1}
           condition:[NSString stringWithFormat:@"msg_id=%@", CJMDBValue(@"1")]];
```

- 删除数据

```objc
// 删除数据
[_dbUser deleteFromTable:SenderTableName withCondition:[NSString stringWithFormat:@"msg_id=%@", CJMDBValue(@"1")]];
```

- 查询数据

```objc
NSArray *valuesArray = [_dbUser selectAllFromTable:SenderTableName
                                     withCondition:[NSString stringWithFormat:@"msg_id=%@", CJMDBValue(@"1")]
                                             order:@"msg_id ASC"
                                             limit:@"1"];
```



## 版本更新

### v0.1.0

第一个版本，实现基础的增删改查功能。


## 推送podspec

```shell
pod repo push specs CJMDBUser.podspec --allow-warnings --sources=https://github.com/CocoaPods/Specs.git --use-libraries
```

## 使用安装

CJMDBUser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CJMDBUser"
```



## 作者

chenjm
cjiemin@163.com

## License

CJMDBUser is available under the MIT license. See the LICENSE file for more info.
