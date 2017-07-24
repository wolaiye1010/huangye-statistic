package com.bj58.huangye.statistic.client;

import com.alibaba.fastjson.JSON;
import com.bj58.huangye.statistic.core.redis.RedisConfigEnum;
import com.bj58.huangye.statistic.core.redis.RedisConst;
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

        boolean isRecursion=false;

        String signature =thisJoinPoint.getSignature().toString();
        final long startTime = System.nanoTime();


        //处理递归调用
        do {
            if(mapList.get().size()<=1){
                break;
            }

            Map<String, Object> mapLastItem = mapList.get().get(mapList.get().size() - 1);
            String lastMethod=mapLastItem.get("method").toString();

            String lastMethodRes=lastMethod.replaceAll("@\\d+$","");
            if(!lastMethodRes.equals(signature)||!mapLastItem.containsKey("start_time")){
                break;
            }

            int recursionEndAppend=0;
            if(lastMethod.contains("@")){
                isRecursion=true;
                recursionEndAppend=Integer.valueOf(lastMethod.split("@")[1]);
            }

            recursionEndAppend++;
            signature+="@"+recursionEndAppend;
        }while (false);


        HashMap<String, Object> startHashMap = new HashMap<String, Object>();
        startHashMap.put("method", signature);
        startHashMap.put("start_time", startTime);
        mapList.get().add(startHashMap);

        Object res=proceed();

        final long endTime = System.nanoTime();

        if(isRecursion){

        }

        HashMap<String, Object> endHashMap = new HashMap<String, Object>();
        endHashMap.put("method", signature);
        endHashMap.put("end_time", endTime);
        mapList.get().add(endHashMap);


        stackCount.set(stackCount.get()-1);

        if(isStackEnd()){
//            System.out.println(String.format("threadId:%s,threadName:%s  ----end----",
//                    Thread.currentThread().getId(),Thread.currentThread().getName()));
            analysis();
            mapList.remove();
            stackCount.remove();
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
        mainRoot.setSelfTime(0);
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


    private void saveDataToRedis(String data){
        Jedis client = RedisFactory.getClient(RedisConfigEnum.TEST);
        client.hset(RedisConst.XHPROF_KEY,UUID.randomUUID().toString(),data);
        long expireAt= CalendarUtil.getTomorrowDawnUinxTimestamp();
        client.expireAt(RedisConst.XHPROF_KEY,expireAt);
    }

    private boolean isStackStart(){
        return 0==stackCount.get();
    }

    private boolean isStackEnd(){
        return 0==stackCount.get();
    }


    public static void main(String[] args) {
        String key="void saveDataToRedis(String data)@1a";
        System.out.println(key.replaceAll("@\\d+$",""));

    }
}
