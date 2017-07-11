package com.bj58.huangye.statistic.core.redis;

/**
 * Created by zhudongchang on 2017/7/5.
 */
public enum RedisConfigEnum {
    TEST(new RedisConfig(){{
        setHost("10.9.193.121");
        setPort(6379);
        setAuth("f225f37463ac191c");
    }}),
    ;

    private RedisConfig redisConfig;
    RedisConfigEnum(RedisConfig redisConfig){
        this.redisConfig=redisConfig;
    }

    public RedisConfig getRedisConfig() {
        return redisConfig;
    }
}