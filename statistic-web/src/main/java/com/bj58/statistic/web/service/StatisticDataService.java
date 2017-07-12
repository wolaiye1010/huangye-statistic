package com.bj58.statistic.web.service;

import com.alibaba.fastjson.JSON;
import com.bj58.huangye.statistic.core.redis.RedisConfigEnum;
import com.bj58.huangye.statistic.core.redis.RedisConst;
import com.bj58.huangye.statistic.core.redis.RedisFactory;
import org.springframework.stereotype.Service;
import redis.clients.jedis.Jedis;

import javax.annotation.PostConstruct;
import java.util.*;

/**
 * Created by zhudongchang on 2017/7/11.
 */
@Service
public class StatisticDataService {

    private Jedis client;

    @PostConstruct
    private void init(){
        client = RedisFactory.getClient(RedisConfigEnum.TEST);
    }

    public List<Map<String, Object>> getList(){
        List<String> lrange = client.lrange(RedisConst.XHPROF_KEY, 0, -1);
        List<Map<String,Object>> list=new ArrayList<>();
        lrange.forEach(x->{
            Map map = JSON.parseObject(x, Map.class);
            Map server = (Map)map.get("server");
            map.put("url",String.format("http://%s%s",
                    server.get("HTTP_HOST"),server.get("REQUEST_URI")));

//            String firstCallKey = map.keySet().stream().filter(item -> {
//                return item.toString().contains("main()==>");
//            }).findFirst().get().toString();
//            map.put("first_call",firstCallKey.replace("main()==>",""));
            map.put("request_time",new Date(Long.valueOf(server.get("REQUEST_TIME").toString())*1000));
            map.put("xhprof_data",x);
            double totalTime=(Integer)(((Map)map.get("main()")).get("wt"))/1000.0;
            map.put("total_time",totalTime);
            String className="";
            if(totalTime>100){
                className="danger";
            }else if(totalTime>10){
                className="warning";
            }

            map.put("class_name",className);
            list.add(map);
        });
        return list;
    }


    public String getNativeData(Integer index) {
        String jsonString=client.lindex(RedisConst.XHPROF_KEY,index);
        Map map = JSON.parseObject(jsonString, Map.class);
        map.remove("server");
        map.remove("url");
        return JSON.toJSONString(map,true);
    }

    public boolean clearList() {
        client.del(RedisConst.XHPROF_KEY);
        return true;
    }
}
