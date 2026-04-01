
B 站上看到的 MySQL 数据库教程, 感觉非常好, 总结一下

[黑马程序员 MySQL数据库入门到精通](https://www.bilibili.com/video/BV1Kr4y1i7ru/?spm_id_from=333.337.search-card.all.click&vd_source=d35ed20d53eb6f2a5367984a10457da3)

# 准备学习环境

1. 创建 mysql 容器

```bash
# 创建容器
docker run --name mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:lts

# 登录
docker exec -it mysql mysql -uroot -pmy-secret-pw
```

2. 创建用户并赋予权限

```sql
-- 创建用户并赋予权限
CREATE USER 'user1'@'%' IDENTIFIED BY 'password';
GRANT CREATE, ALTER, DROP, INDEX, INSERT, UPDATE, DELETE, SELECT ON *.* TO 'user1'@'%';
FLUSH PRIVILEGES;

-- 或者更安全方式
-- CREATE DATABASE mydb;
-- GRANT ALL PRIVILEGES ON mydb.* TO 'user1'@'%';
```
 
3. 使用新创建的用户登录数据库

养成好习惯

```bash
docker exec -it mysql mysql -uuser1 -ppassword
```

# SQL 分类

1. DDL (Data Definition Language): 定义数据库结构的语言，如 CREATE、ALTER、DROP 等
2. DML (Data Manipulation Language): 操作数据库数据的语言，如 INSERT、UPDATE、DELETE 等
3. DCL (Data Control Language): 控制数据库访问的语言，如 GRANT、REVOKE 等
4. DQL (Data Query Language): 查询数据库数据的语言，如 SELECT 等

## DDL 示例

```sql
SHOW DATABASES;

-- 查询当前数据库
SELECT DATABASE();

CREATE DATABASE [IF NOT EXISTS] <db name>
  [DEFAULT CHARSET 字符集]
  [COLLATE 排序规则];

DROP DATABASE [IF EXISTS] <db name>;

USE <db name>;

-----------------------------------
-- 表操作
-----------------------------------

SHOW TABLES;
DESC 表名;
SHOW CREATE TABLE 表名;

CREATE TABLE 表名 (
    filed1 file1_type [COMMENT filed1 comment],
    filed2 file2_type [COMMENT filed2 comment]
)[COMMENT 表注释];

-- 示例
CREATE TABLE tb_user(
    id int comment '编号',
    name varchar(50) comment '姓名',
    age int comment '年龄',
    gender varchar(1) comment '性别'
) comment '用户表';

-----------------------------------
-- 表修改操作
-----------------------------------

-- 添加字段
-- ALTER TABLE 表名 ADD 字段名 类型(长度) [COMMENT 注释] [约束];

ALTER TABLE tb_user ADD nickname varchar(10) comment 'nick name';

-- 修改数据类型
ALTER TABLE 表名 MODIFY 字段名 新数据类型(长度);
-- 修改字段名和类型
ALTER TABLE 表名 CHANGE 旧字段名 新字段名 类型(长度) [COMMENT 注释] [约束];
-- 删除字段
ALTER TABLE 表名 DROP 字段名;
-- 修改表名
ALTER TABLE 表名 RENAME TO 新表名;
-- 删除表
DROP TABLE 表名;
-- 删除表, 并重新创建表
TRUNCATE TABLE 表名;

alter table tb_user change nickname username varchar(100);
```

## DML 示例

```sql
-----------------------------------
-- 插入数据
-----------------------------------

-- 指定字段
INSERT INTO 表名 (字段1, ...) VALUES(值1, );
-- 全部字段
INSERT INTO 表名 VALUES(值1, );
-- 批量
INSERT INTO 表名 VALUES(值1, ), VALUES(值1, );

-----------------------------------
-- 修改
-----------------------------------
UPDATE 表名 SET 字段名1=值1, 字段名2=值2, ... [WHERE 条件];

-----------------------------------
-- 删除
-----------------------------------
DELETE FROM 表名 [WHERE 条件];
```

## DCL

DCL 用于管理数据库用户权限, MySQL 中定义了很多种权限, 但是常用的就以下几种:

| 权限             | 说明                     |
|------------------|--------------------------|
| ALL, ALL PRIVILEGES | 所有权限                 |
| SELECT           | 查询数据                 |
| INSERT           | 插入数据                 |
| UPDATE           | 修改数据                 |
| DELETE           | 删除数据                 |
| ALTER            | 修改表结构               |
| DROP             | 删除数据库/表/视图       |
| CREATE           | 创建数据库/表            |

以下是几个高频用法

- 查询用户 

```sql
USE mysql; 
SELECT * FROM user; 
```

- 创建用户 

```sql
CREATE USER '用户名'@'主机名' IDENTIFIED BY '密码';  
```

- 修改用户密码 

```sql
ALTER USER '用户名'@'主机名' IDENTIFIED WITH mysql_native_password BY '新密码';  
```

- 删除用户 

```sql
DROP USER '用户名'@'主机名';
```

- 权限

```sql

-- 给用户user@localhost授予test库所有表的查询权限
GRANT SELECT ON test.* TO 'user'@'localhost';

-- 授予用户所有权限（生产环境慎用）
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';

-- 回收用户的删除权限
REVOKE DELETE ON test.* FROM 'user'@'localhost';

-- 刷新权限（使授权生效）
FLUSH PRIVILEGES;

-- 查看用户权限
SHOW GRANTS FOR 'user'@'localhost';
```

## DQL

DQL 用于查询数据库数据, MySQL 80% 的功能都是 DQL 语句。

语法

```sql
SELECT
   字段列表
FROM
  表名列表
WHERE
  条件列表
GROUP BY
  分组字段列表
HAVING
  分组后条件列表
ORDER BY
  排序字段列表
LIMIT 
  分页参数;

-- 别名  
SELECT 字段1 [AS 别名1], FROM 表名;

-- 去重
SELECT DISTINCT 字段列表 FROM 表名;
```


| 比较运算符       | 功能                                       |
|------------------|--------------------------------------------|
| >                | 大于                                       |
| >=               | 大于等于                                   |
| <                | 小于                                       |
| <=               | 小于等于                                   |
| =                | 等于                                       |
| <> 或 !=         | 不等于                                     |
| BETWEEN ... AND ... | 在某个范围之内(含最小、最大值)            |
| IN(...)          | 在in之后的列表中的值，多选一               |
| LIKE 占位符      | 模糊匹配(_匹配单个字符，%匹配任意个字符) |
| IS NULL          | 是NULL                                     |


| 逻辑运算符 | 功能                                       |
|------------|--------------------------------------------|
| AND 或 &&  | 并且 (多个条件同时成立)                    |
| OR 或 \|\| | 或者 (多个条件任意一个成立)                |
| NOT 或 !   | 非，不是                                   |


补充说明:

- WHERE 子句用于在查询时过滤数据，只返回满足条件的记录
- 模糊匹配中：_ 代表任意单个字符，% 代表任意长度的任意字符（包括 0 个）
- 判断空值必须使用 IS NULL 或 IS NOT NULL，不能用 = NULL
- BETWEEN a AND b 等价于 >=a AND <=b，包含边界值
- IN(...) 可以替代多个 OR 条件，例如 WHERE id IN (1,3,5)

### 分组查询

> SELECT 字段列表 FROM 表名 [WHERE 条件] GROUP BY 分组字段名 [HAVING 分组后过滤条件];

where 与 having 区别

- 执行时机不同：where 是分组之前进行过滤，不满足 where 条件，不参与分组；而 having 是分组之后对结果进行过滤
- 判断条件不同：where 不能对聚合函数进行判断，而 having 可以

### 排序

> SELECT 字段 FROM 表名 ORDER BY 字段1 排序方式, 字段2 排序方式;

### 分页查询

> SELECT 字段列表 FROM 表名 LIMIT 起始索引, 查询记录数;

- 起始索引从 0 开始，起始索引 =（查询页码 - 1）* 每页显示记录数
- 分页查询是数据库的方言，不同的数据库有不同的实现，MySQL 中是 LIMIT
- 如果查询的是第一页数据，起始索引可以省略，直接简写为 limit 10


