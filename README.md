# 使用bloom加速gitbase统计代码的api的访问

## 原理

很简单，以前是直接通过sqler进行数据访问，目前数据放到bloom
基于redis进行数据存储，同时集成sqler的cron能力，调用webhook请求
自动按照定时任务刷新cache（数据预热，减少因为数据）