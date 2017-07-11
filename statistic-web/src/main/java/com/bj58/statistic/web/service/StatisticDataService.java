package com.bj58.statistic.web.service;

import com.alibaba.fastjson.JSON;
import com.bj58.huangye.statistic.core.redis.RedisConfigEnum;
import com.bj58.huangye.statistic.core.redis.RedisConst;
import com.bj58.huangye.statistic.core.redis.RedisFactory;
import org.springframework.stereotype.Service;
import redis.clients.jedis.Jedis;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by zhudongchang on 2017/7/11.
 */
@Service
public class StatisticDataService {
    public List<Map<String, Object>> getList(){
        Jedis client = RedisFactory.getClient(RedisConfigEnum.TEST);
        List<String> lrange = client.lrange(RedisConst.XHPROF_KEY, 0, -1);
        List<Map<String,Object>> list=new ArrayList<>();
        lrange.forEach(x->{
            Map map = JSON.parseObject(x, Map.class);
            Map server = (Map)map.get("server");
            map.put("url",String.format("http://%s%s",
                    server.get("HTTP_HOST"),server.get("REQUEST_URI")));
            map.put("request_time",new Date(Long.valueOf(server.get("REQUEST_TIME").toString())*1000));
            map.put("xhprof_data",x);
            list.add(map);
        });
        return list;
    }
}
