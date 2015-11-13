//
//  DYDataBaseManager.h
//  DYDataBaseManager
//
//  Created by qianfeng on 15/11/12.
//  Copyright © 2015年 myOwn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYDataBaseManager : NSObject

/**
 *  执行SQL语句（主要包含建表语句，修改标信息语句）
 *
 *  返回值为执行成功，或执行失败
 */
-(BOOL)excuteSomeMainSQL:(NSString *)SQL;

/**
 *  创建单例单例
 *
 *  返回值为单例
 */
+(instancetype)shareManager;

/**
 *  往表格里添加一条记录(第一种方法，带通配符的)
 *
 *  第一个参数为插入语句（带通配符的）
 *  第二个参数为要插入的属性值，并且把每个属性值匹配到相应的通配符里
 *  返回值为布尔类型，插入成功或者插入失败
 */
-(BOOL)insertIntoTable:(NSString *)insertSQL info:(NSArray *)propertyArray;

/**
 *  往表格里添加一条记录(第二种方法，不带通配符的)
 *
 *  第一个参数为插入语句（不带通配符的）
 *  返回值为布尔类型，插入成功或者插入失败
 */
-(BOOL)insertIntoTable:(NSString *)insertSQL;

/**
 *  在表格里删除一条记录(第一种方法，带通配符的)
 *
 *  第一个参数为删除语句（带通配符的）
 *  第二个参数为根据某一属性来删除某一纪录
 *  返回值为布尔类型，删除成功或者删除失败
 */
-(BOOL)removeATable:(NSString *)deleteSQL info:(NSString *)propertyId;

/**
 *  在表格里删除一条记录(第二种方法，不带通配符的)
 *
 *  第一个参数为删除语句（不带通配符的）
 *  返回值为布尔类型，删除成功或者删除失败
 */
-(BOOL)removeATable:(NSString *)deleteSQL;

/**
 *  查找表记录(第一种方法，查询表中记录，不带通配符)
 *
 *  第一个参数为查询语句（不带通配符的）
 *  第二个参数为要查询的属性，并且根据这些属性把查询到的记录存到字典中
 *  返回值为数组，里面存的是每一条查询记录，记录以字典的形式存在
 */
-(NSArray *)selectFromTable:(NSString *)selectSQL propertyArray:(NSArray *)propertyArray;

/**
 *  查找表记录(第二种方法，查询表中记录，条件查询，带通配符)
 *
 *  第一个参数为查询语句（带通配符的）
 *  第二个参数为根据哪些属性来删除记录，以数组形式存在，数组内存放记录的一些属性，我们可以根据这些属性来删除记录
 *  第三个参数为要查询的属性，并且根据这些属性把查询到的记录存到字典中
 *  返回值为数组，里面存的是每一条查询记录，记录以字典的形式存在
 */
-(NSArray *)selectFromTable:(NSString *)selectSQL withPropertyName:(NSArray *)selectAccording propertyArray:(NSArray *)propertyArray;


@end
