package com.bj58.huangye.statistic.client;

import com.alibaba.fastjson.JSON;
import com.bj58.huangye.statistic.core.redis.RedisConfigEnum;
import com.bj58.huangye.statistic.core.redis.RedisFactory;
import com.bj58.huangye.statistic.core.util.CalendarUtil;
import org.aspectj.lang.annotation.*;
import redis.clients.jedis.Jedis;

import java.util.*;

/**
 * Created by zhudongchang on 2017/7/4.
 */
@Aspect
public aspect HuangyeAspect {

    private static List<Map<String,Object>> mapList =new ArrayList<Map<String,Object>>();
    private static int stackCount=0;

    private static Map<String,XhprofDataNode> xhprofDataNodeMap=new HashMap<String, XhprofDataNode>();

    @Pointcut("execution(* *..* (..))&&!within(com.bj58.huangye.statistic..*)")
    public void bj58PointCut(){}

    void around():bj58PointCut(){
        if(isStackStart()){
            mapList.clear();
        }

        synchronized (HuangyeAspect.class){
            stackCount++;
        }

        final String signature =thisJoinPoint.getSignature().toString();
        final long startTime = System.nanoTime();
        mapList.add(new HashMap<String,Object>(){{
            put("method",signature);
            put("start_time",startTime);
        }});

        proceed();

        final long endTime = System.nanoTime();
        mapList.add(new HashMap<String,Object>(){{
            put("method",signature);
            put("end_time",endTime);
        }});


        synchronized (HuangyeAspect.class){
            stackCount--;
        }

        if(isStackEnd()){
            analysis();
        }
    }

    private void analysis(){
        Stack<CallTreeNode> callTreeNodesStack=new Stack<CallTreeNode>();
        CallTreeNode callTreeNode = null;
        for (final Map<String, Object> map : mapList) {
            if(map.containsKey("start_time")){
                callTreeNodesStack.push(new CallTreeNode(){{
                    setStartTime((Long) map.get("start_time"));
                    setName(map.get("method").toString());
                    setChildRenCallTreeNodes(new ArrayList<CallTreeNode>());
                }});
            }

            if(map.containsKey("end_time")){
                callTreeNode = callTreeNodesStack.pop();
                callTreeNode.setEndTime((Long) map.get("end_time"));
                if(!callTreeNodesStack.isEmpty()){
                    CallTreeNode parent=callTreeNodesStack.peek();
                    parent.getChildRenCallTreeNodes().add(callTreeNode);
                    callTreeNode.setParent(parent);
                }else{
                    callTreeNode.setParent(null);
                }
            }
        }

        analysisExecTime(callTreeNode);
        buildXhprofDataMap(callTreeNode);
    }

    private void analysisExecTime(CallTreeNode callTreeNode){
        callTreeNode.setTotalTime(callTreeNode.getEndTime()-callTreeNode.getStartTime());
        long childRenExecTotal=0;
        for (CallTreeNode treeNode : callTreeNode.getChildRenCallTreeNodes()) {
            analysisExecTime(treeNode);
            childRenExecTotal+=treeNode.getTotalTime();
        }
        callTreeNode.setSelfTime(callTreeNode.getTotalTime()-childRenExecTotal);
    }

    private void buildXhprofDataMap(CallTreeNode callTreeNode){
        //构造main root
        CallTreeNode mainRoot= new CallTreeNode();
        mainRoot.setTotalTime(callTreeNode.getTotalTime());
        mainRoot.setName("main()");
        mainRoot.setChildRenCallTreeNodes(new ArrayList<CallTreeNode>());
        mainRoot.getChildRenCallTreeNodes().add(callTreeNode);
        callTreeNode.setParent(mainRoot);
        mainRoot.setParent(null);

        statisticXhprofDataMap(mainRoot);

        Map<String,Object> xhprofDataNodeMapExt=new HashMap<String, Object>();
        for (Map.Entry<String,XhprofDataNode> item : xhprofDataNodeMap.entrySet()) {
            xhprofDataNodeMapExt.put(item.getKey(),item.getValue());
        }
        xhprofDataNodeMapExt.put("url","58huangye");
        xhprofDataNodeMapExt.put("server",new HashMap<String,Object>(){{
            put("REQUEST_TIME",System.currentTimeMillis()/1000);
            put("HTTP_HOST","58.com");
            put("REQUEST_URI","/huangye");
        }});

        String data = JSON.toJSONString(xhprofDataNodeMapExt);
        saveDataToRedis(data);
    }

    private void statisticXhprofDataMap(final CallTreeNode callTreeNode){
        String mapKey=null;
        if(callTreeNode.isRoot()){
            mapKey=callTreeNode.getName();
        }else{
            mapKey=String.format("%s==>%s",callTreeNode.getParent().getName(),callTreeNode.getName());
        }

        if(!xhprofDataNodeMap.containsKey(mapKey)){
            xhprofDataNodeMap.put(mapKey,new XhprofDataNode(){{
                setWt((int)(callTreeNode.getTotalTime()/1000.0));
                setCt(1);
            }});
        }else{
            XhprofDataNode xhprofDataNode = xhprofDataNodeMap.get(mapKey);
            xhprofDataNode.setCt(xhprofDataNode.getCt()+1);
            xhprofDataNode.setWt(xhprofDataNode.getWt()+
                    (int)(callTreeNode.getTotalTime()/1000.0));
        }

        for (CallTreeNode treeNode : callTreeNode.getChildRenCallTreeNodes()) {
            statisticXhprofDataMap(treeNode);
        }
    }

    private static final String XHPROF_KEY="fuwu_xhprof_XhprofUtil";

    private void saveDataToRedis(String data){
        Jedis client = RedisFactory.getClient(RedisConfigEnum.GROUP_FUWU);
        client.lpush(XHPROF_KEY,data);
        long expireAt= CalendarUtil.getTomorrowDawnUinxTimestamp();
        client.expireAt(XHPROF_KEY,expireAt);
    }

    private boolean isStackStart(){
        return 0==stackCount;
    }

    private boolean isStackEnd(){
        return 0==stackCount;
    }
}
