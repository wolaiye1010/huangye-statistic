package com.bj58.huangye.statistic.core.redis;

/**
 * Created by zhudongchang on 2017/7/5.
 */
public enum RedisConfigEnum {
    GROUP_FUWU(new RedisConfig(){{
        setHost("test19656.rdb.58dns.org");
        setPort(6050);
        setAuth("7b48e904612cdcdf");
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