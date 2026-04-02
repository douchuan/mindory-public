

## 主库设置

```sh
docker exec -it mysql-master mysql -uroot -proot
```

```sql
-- 创建itcast用户，并设置密码，该用户可在任意主机连接该MySQL服务
-- WITH mysql_native_password 的作用是：
-- 指定这个 MySQL 用户使用【老版本兼容的密码加密方式】来登录，而不是 MySQL 8.0 默认的新加密方式
CREATE USER 'itcast'@'%' IDENTIFIED WITH mysql_native_password BY 'Root@123456';

-- 为 'itcast'@'%' 用户分配主从复制权限
GRANT REPLICATION SLAVE ON *.* TO 'itcast'@'%';


-- 查看 binary log status
SHOW BINARY LOG STATUS;
```


## 从库设置

```sh
docker exec -it mysql-slave1 mysql -uroot -proot
```

```sql
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='mysql-master', 
SOURCE_USER='itcast', 
SOURCE_PASSWORD='Root@123456', 
SOURCE_LOG_FILE='binlog.000002', 
SOURCE_LOG_POS=694,
GET_SOURCE_PUBLIC_KEY=1;

-- 启动主从复制
START REPLICA;

SHOW REPLICA STATUS \G;

-- 重点关注
-- Replica_IO_Running: Yes
-- Replica_SQL_Running: Yes
```


## 测试

主库创建库表并插入数据

```sql
create database db01;
use db01;
create table tb_user(
  id int(11) primary key not null auto_increment,
  name varchar(50) not null,
  sex varchar(1) not null
) engine=InnoDB default charset=utf8mb4;
insert into tb_user(id, name, sex) 
  values (null, 'tom', '0'), (null, 'trigger', '1'), (null, 'dawn', '1');
```