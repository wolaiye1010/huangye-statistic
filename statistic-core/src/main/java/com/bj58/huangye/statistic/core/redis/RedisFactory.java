package com.bj58.huangye.statistic.core.redis;

import redis.clients.jedis.Jedis;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by zhudongchang on 2017/7/5.
 */
public class RedisFactory {
    private static Map<RedisConfigEnum,Jedis> container=new ConcurrentHashMap<RedisConfigEnum, Jedis>();

    public static Jedis getClient(RedisConfigEnum redisConfigEnum){
        if(container.containsKey(redisConfigEnum)){
            return container.get(redisConfigEnum);
        }

        synchronized (RedisFactory.class){
            if(container.containsKey(redisConfigEnum)){
                return container.get(redisConfigEnum);
            }

            RedisConfig redisConfig=redisConfigEnum.getRedisConfig();

            Jedis jedis = new Jedis(redisConfig.getHost(), redisConfig.getPort());
            jedis.auth(redisConfig.getAuth());
            container.put(redisConfigEnum,jedis);
            return jedis;
        }
    }
}