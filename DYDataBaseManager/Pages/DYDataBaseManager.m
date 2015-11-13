//
//  DYDataBaseManager.m
//  DYDataBaseManager
//
//  Created by qianfeng on 15/11/12.
//  Copyright © 2015年 myOwn. All rights reserved.
//

#import "DYDataBaseManager.h"

#import <sqlite3.h>


#define CreateDataBaseVersionTable @"CREATE TABLE IF NOT EXISTS dataBaseVersion_info (v_key TEXT PRIMARY KEY,v_value TEXT);"


@interface DYDataBaseManager (){
    sqlite3 * dataBase;
}

@property (nonatomic) NSInteger dbVersion;

@end

@implementation DYDataBaseManager

#pragma mark -查找表记录(第一种方法，查询表中记录，不带通配符)
-(NSArray *)selectFromTable:(NSString *)selectSQL propertyArray:(NSArray *)propertyArray{
    
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) != SQLITE_OK){
        return nil;
    }
    char * sqlString = (char *)[selectSQL UTF8String];
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(dataBase, sqlString, -1, &stmt, nil);
    if(result != SQLITE_OK){
        return nil;
    }
    
    NSMutableArray * mutableArray = [NSMutableArray array];
    //执行查询语句
    while(sqlite3_step(stmt) == SQLITE_ROW){
        NSMutableDictionary * houseDict = [NSMutableDictionary dictionary];
        
        for(int i=0;i<propertyArray.count;i++){
            char * object = (char *)sqlite3_column_text(stmt, i);
            
            
            NSString * property = [NSString stringWithUTF8String:strdup(object)];
            
            [houseDict setValue:property forKey:propertyArray[i]];
        }
        
        [mutableArray addObject:houseDict];
    }
    
    
    return mutableArray;
}
#pragma mark -查找表记录(第二种方法，查询表中记录，条件查询，带通配符)
-(NSArray *)selectFromTable:(NSString *)selectSQL withPropertyName:(NSArray *)selectAccording propertyArray:(NSArray *)propertyArray{
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) != SQLITE_OK){
        return nil;
    }
    char * sqlString = (char *)[selectSQL UTF8String];
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(dataBase, sqlString, -1, &stmt, nil);
    if(result != SQLITE_OK){
        return nil;
    }
    //设置条件
    for(int i=0;i<selectAccording.count;i++){
        sqlite3_bind_text(stmt, i+1, [selectAccording[i] UTF8String], -1, NULL);
    }
    
    NSMutableArray * mutableArray = [NSMutableArray array];
    //执行查询语句
    while(sqlite3_step(stmt) == SQLITE_ROW){
        NSMutableDictionary * houseDict = [NSMutableDictionary dictionary];
        
        for(int i=0;i<propertyArray.count;i++){
            char * object = (char *)sqlite3_column_text(stmt, i);
            NSString * property = [NSString stringWithUTF8String:strdup(object)];
            
            [houseDict setValue:property forKey:propertyArray[i]];
        }
        
        [mutableArray addObject:houseDict];
    }
    return mutableArray;
}
#pragma mark -在表格里删除一条记录(第一种方法，带通配符的)
-(BOOL)removeATable:(NSString *)deleteSQL info:(NSString *)propertyId{
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) != SQLITE_OK){
        return NO;
    }
    char * sqlString = (char *)[deleteSQL UTF8String];
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(dataBase, sqlString, -1, &stmt, nil);
    if(result != SQLITE_OK){
        return NO;
    }
    sqlite3_bind_text(stmt, 1, [propertyId UTF8String], -1, NULL);
    int ret = sqlite3_step(stmt);
    if(ret == SQLITE_DONE){
        sqlite3_finalize(stmt);
        sqlite3_close(dataBase);
        return YES;
    }
    
    return NO;
}
#pragma mark -在表格里删除一条记录(第二种方法，不带通配符的)
-(BOOL)removeATable:(NSString *)deleteSQL{
    return [self excuteSQl:deleteSQL];
}
#pragma mark -往表格里添加一条记录(第一种方法，带通配符的)
-(BOOL)insertIntoTable:(NSString *)insertSQL info:(NSArray *)propertyArray{
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) != SQLITE_OK){
        return NO;
    }
    char * sql = (char *)[insertSQL UTF8String];
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(dataBase, sql, -1, &stmt, nil);
    if(result != SQLITE_OK){
        return NO;
    }
    for(int i=0;i<propertyArray.count;i++){
        sqlite3_bind_text(stmt, i+1, [propertyArray[i] UTF8String], -1, NULL);
    }
    
    int ret = sqlite3_step(stmt);
    if(ret == SQLITE_DONE){
        sqlite3_finalize(stmt);
        sqlite3_close(dataBase);
        return YES;
    }
    
    return NO;
}
#pragma mark -往表格里添加一条记录(第二种方法，不带通配符的)
-(BOOL)insertIntoTable:(NSString *)insertSQL{
    return [self excuteSQl:insertSQL];
}

#pragma mark -获取数据库文件路径
-(NSString*)documentPath:(NSString*)fileName

{
    if(fileName == nil)
        return nil;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex: 0];
    NSString* documentsPath = [documentsDirectory stringByAppendingPathComponent: fileName];
    return documentsPath;
}
-(NSString *)getSQLPath{
    return [self documentPath:@"sqllite.db"];
}
#pragma mark -判断文件是否存在
-(BOOL)isExistFile{
    NSLog(@"sqlitePath : %@",[self getSQLPath]);
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getSQLPath]];
}
#pragma mark -单例
+(instancetype)shareManager{
    static DYDataBaseManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!manager){
            manager = [[DYDataBaseManager alloc] init];
        }
    });
    return manager;
}
#pragma mark -初始化
-(instancetype)init{
    self = [super init];
    if(self){
        self.dbVersion = 1;
        if(![self isExistFile]){
            //创建表格，直到创建成功，但创建三次还是失败则返回self；
            NSInteger countCreate = 0;
            while (![self createDataBase]) {
                if(countCreate > 3){
                    return self;
                }
                countCreate ++;
            }
        }else{
            char * info = NULL;
            [self getDataBaseVersionInfoWithKey:"dBVersion" value:&info];
            if(info == NULL){
                return self;
            }
            self.dbVersion = atoi(info);
            free(info);
        }
       
    }

    return self;
}
#pragma mark -版本控制
-(BOOL)excuteSomeMainSQL:(NSString *)SQL{
    NSString * sqlSign = [[SQL componentsSeparatedByString:@" "] firstObject];
    NSString * subSign = [sqlSign lowercaseString];
    if([subSign isEqualToString:@"create"] || [subSign isEqualToString:@"alter"]){
        if(self.dbVersion == 1){
             [self excuteSQl:CreateDataBaseVersionTable];
        }
       
        BOOL isExcuteSuccess = [self excuteSQl:SQL];
        [self setDBInfoValueWithKey:"db_version" value:[[NSString stringWithFormat:@"%ld",(self.dbVersion + 1)] UTF8String]];
        return isExcuteSuccess;
    }
    return [self excuteSQl:SQL];
}
#pragma mark -设置数据库版本信息
-(BOOL)setDBInfoValueWithKey:(const char *)key value:(const char *)value{
    char * info = NULL;
    //查询数据库版本是否以存在
    [self getDataBaseVersionInfoWithKey:key value:&info];
    if(info != NULL){
        //存在，则更新该版本
        [self updateDataBaseVersionInfoWithKey:key value:value];
    }else{
        //不存在，则插入新版本
        [self insertDataBaseVersionInfoWithKey:key value:value];
    }
    free(info);  //手动释放指针
    return YES;
}

#pragma mark -执行语句
-(BOOL)excuteSQl:(NSString *)SQL{
    
    char * error = NULL;
    
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) != SQLITE_OK){
        return NO;
    }
    const char * sql = [SQL UTF8String];
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(dataBase, sql, -1, &stmt, nil);
    if(result != SQLITE_OK){
        return NO;
    }
    if(sqlite3_exec(dataBase, sql, NULL, NULL, &error) == SQLITE_OK){
        sqlite3_finalize(stmt);
        sqlite3_close(dataBase);
        return YES;
    }
    
    return NO;
}
#pragma mark -获取版本信息
-(void)getDataBaseVersionInfoWithKey:(const char *)key value:(char **)value{
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) != SQLITE_OK){
        return;
    }
    char * sql = "SELECT * FROM dataBaseVersion_info WHERE v_key = ?;";
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(dataBase, sql, -1, &stmt, nil);
    if(result != SQLITE_OK){
        return;
    }
    sqlite3_bind_text(stmt, 1, key, -1, NULL);
    if(sqlite3_step(stmt) == SQLITE_ROW){
        char * v = (char *)sqlite3_column_text(stmt, 1);
        *value = strdup(v);
    }
    sqlite3_finalize(stmt);
    
}
#pragma mark -更新数据版本信息
-(BOOL)updateDataBaseVersionInfoWithKey:(const char *)key value:(const char *)value{
    int ret = 0;
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) != SQLITE_OK){
        return NO;
    }
    char * sql = "UPDATE dataBaseVersion_info SET v_value = ? WHERE v_key = ?";
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(dataBase, sql, -1, &stmt, nil);
    if(result != SQLITE_OK){
        return NO;
    }
    sqlite3_bind_text(stmt, 1, value, -1, NULL);
    sqlite3_bind_text(stmt, 1, key, -1, NULL);
    
    ret = sqlite3_step(stmt);
    if(ret == SQLITE_DONE){
        sqlite3_finalize(stmt);
        sqlite3_close(dataBase);
        return YES;
    }
    
    return NO;
}
#pragma mark -插入数据版本信息
-(BOOL)insertDataBaseVersionInfoWithKey:(const char *)key value:(const char *)value{
    
    int ret = 0;
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) != SQLITE_OK){
        return NO;
    }
    char * sql = "INSERT INTO dataBaseVersion_info (v_key,v_value) values(?,?)";
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(dataBase, sql, -1, &stmt, nil);
    if(result != SQLITE_OK){
        return NO;
    }
    sqlite3_bind_text(stmt, 1, key, -1, NULL);
    sqlite3_bind_text(stmt, 1, value, -1, NULL);
    ret = sqlite3_step(stmt);
    if(ret == SQLITE_DONE){
        sqlite3_finalize(stmt);
        sqlite3_close(dataBase);
        return YES;
    }
    
    return NO;
}
#pragma mark -创建数据库
-(BOOL)createDataBase{
    if(sqlite3_open([[self getSQLPath] UTF8String], &dataBase) == SQLITE_OK){
        return YES;
    }
    
    return NO;
}


@end
