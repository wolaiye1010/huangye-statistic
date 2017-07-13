package com.bj58.statistic.web.service;

import com.alibaba.fastjson.JSON;
import com.bj58.huangye.statistic.core.redis.RedisConfigEnum;
import com.bj58.huangye.statistic.core.redis.RedisConst;
import com.bj58.huangye.statistic.core.redis.RedisFactory;
import com.bj58.huangye.statistic.core.util.CalendarUtil;
import com.bj58.statistic.web.util.HttpRequest;
import org.springframework.stereotype.Service;
import redis.clients.jedis.Jedis;

import javax.annotation.PostConstruct;
import java.util.*;

/**
 * Created by zhudongchang on 2017/7/11.
 */
@Service
public class StatisticDataService {
    private static final String XHPROF_SAVE_URL="http://10.9.193.121/save.php";
    private static final String XHPROF_CALL_GRAPH_URL="http://10.9.193.121/statistic/callgraph/%s";
    private static final String XHPROF_CALL_TEXT_URL="http://10.9.193.121/statistic/index/%s";


    private Jedis client;

    @PostConstruct
    private void init(){
        client = RedisFactory.getClient(RedisConfigEnum.TEST);
    }

    public List<Map<String, Object>> getList(){
        List<Map<String,Object>> res=new ArrayList<>();
        Map<String, String> map = client.hgetAll(RedisConst.XHPROF_KEY);
        for (Map.Entry<String, String> entry : map.entrySet()) {
            Map xhprofDataMap = JSON.parseObject(entry.getValue(), Map.class);
            Map server = (Map)xhprofDataMap.get("server");
            HashMap<String, Object> resItemHashMap = new HashMap<>();
            resItemHashMap.put("request_time",
                    new Date(Long.valueOf(server.get("REQUEST_TIME").toString())*1000));

            double totalTime=(Integer)(((Map)xhprofDataMap.get("main()")).get("wt"))/1000.0;
            resItemHashMap.put("total_time",totalTime);
            String className="";
            if(totalTime>100){
                className="danger";
            }else if(totalTime>10){
                className="warning";
            }
            resItemHashMap.put("class_name",className);
            resItemHashMap.put("hmap_key",entry.getKey());
            res.add(resItemHashMap);
        }
        Collections.reverse(res);

        Collections.sort(res, new Comparator<Map<String, Object>>() {
            @Override
            public int compare(Map<String, Object> x, Map<String, Object> y) {
                return ((Date)y.get("request_time")).compareTo((Date)x.get("request_time"));
            }
        });

        return res;
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

    public String getXhprofRunId(String key) {
        String runIdCache = client.get(key);
        if(null!=runIdCache){
            return runIdCache;
        }

        String xhprofData = client.hget(RedisConst.XHPROF_KEY, key);
        String runId = HttpRequest.sendPost(XHPROF_SAVE_URL, new HashMap() {{
            put("xhprof_data", xhprofData);
        }});

        client.set(key,runId);
        long expireAt= CalendarUtil.getTomorrowDawnUinxTimestamp();
        client.expireAt(key,expireAt);
        return runId;
    }


    public String getXhprofUrlCallGraph(String key){
        return String.format(XHPROF_CALL_GRAPH_URL,getXhprofRunId(key));
    }

    public String getXhprofUrlCallText(String key){
        return String.format(XHPROF_CALL_TEXT_URL,getXhprofRunId(key));
    }
}
