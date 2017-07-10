package com.bj58.huangye.statistic.client;

import com.alibaba.fastjson.JSON;
import com.bj58.huangye.statistic.core.redis.RedisConfigEnum;
import com.bj58.huangye.statistic.core.redis.RedisFactory;
import com.bj58.huangye.statistic.core.util.CalendarUtil;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import redis.clients.jedis.Jedis;

import java.io.File;
import java.util.*;

/**
 * Created by zhudongchang on 2017/7/4.
 */
@Aspect
public aspect HuangyeAspect {

    private static ThreadLocal<List<Map<String,Object>>> mapList =new ThreadLocal<List<Map<String, Object>>>(){
        @Override
        protected List<Map<String, Object>> initialValue() {
            return new ArrayList<Map<String, Object>>();
        }
    };

    private static Map<String,XhprofDataNode> xhprofDataNodeMap=new HashMap<String, XhprofDataNode>();

    private static ThreadLocal<Integer> stackCount=new ThreadLocal<Integer>(){
        @Override
        protected Integer initialValue() {
            return 0;
        }
    };

    @Pointcut("execution(* *..* (..))&&!within(com.bj58.huangye.statistic.client..*)")
    public void bj58PointCut(){}

//    @Pointcut("execution(* com.bj58.wf.mvc.MvcFilter.doFilter(..))")
//    public void bj58CfowPointCut(){}
    @Pointcut("execution(* com.bj58.qdyw.infolist.web.controllers.commonAction(..))")
    public void bj58CfowPointCut(){}


    pointcut bj58Cfow():cflow(bj58CfowPointCut())&&!within(com.bj58.huangye.statistic.client..*);


    Object around():bj58PointCut(){
//    Object around():bj58Cfow(){
        boolean isCallMethod="method-call"==thisJoinPoint.getKind();
        if(isCallMethod){
            proceed();
            return null;
        }

        if(isStackStart()){
//            System.out.println(String.format("threadId:%s,threadName:%s  ----start----",
//                    Thread.currentThread().getId(),Thread.currentThread().getName()));
            mapList.get().clear();
        }

        stackCount.set(stackCount.get()+1);

        final String signature =thisJoinPoint.getSignature().toString();
        final long startTime = System.nanoTime();
        mapList.get().add(new HashMap<String,Object>(){{
            put("method",signature);
            put("start_time",startTime);
        }});

        Object res=proceed();

        final long endTime = System.nanoTime();
        mapList.get().add(new HashMap<String,Object>(){{
            put("method",signature);
            put("end_time",endTime);
        }});


        stackCount.set(stackCount.get()-1);

        if(isStackEnd()){
//            System.out.println(String.format("threadId:%s,threadName:%s  ----end----",
//                    Thread.currentThread().getId(),Thread.currentThread().getName()));
            analysis();
        }

        return res;
    }

    private void analysis(){
        Stack<CallTreeNode> callTreeNodesStack=new Stack<CallTreeNode>();
        CallTreeNode callTreeNode = null;
        for (final Map<String, Object> map : mapList.get()) {
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

    private synchronized void buildXhprofDataMap(CallTreeNode callTreeNode){
        //构造main root
        CallTreeNode mainRoot= new CallTreeNode();
        mainRoot.setTotalTime(callTreeNode.getTotalTime());
        mainRoot.setName("main()");
        mainRoot.setChildRenCallTreeNodes(new ArrayList<CallTreeNode>());
        mainRoot.getChildRenCallTreeNodes().add(callTreeNode);
        callTreeNode.setParent(mainRoot);
        mainRoot.setParent(null);

        xhprofDataNodeMap.clear();
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
        return 0==stackCount.get();
    }

    private boolean isStackEnd(){
        return 0==stackCount.get();
    }
}
