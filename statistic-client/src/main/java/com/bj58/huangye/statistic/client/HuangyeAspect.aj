package com.bj58.huangye.statistic.client;

import com.alibaba.fastjson.JSON;
import org.aspectj.lang.annotation.*;

import java.util.*;

/**
 * Created by zhudongchang on 2017/7/4.
 */
@Aspect
public aspect HuangyeAspect {

    public static List<Map<String,Object>> mapList =new ArrayList<Map<String,Object>>();
    public static int stackCount=0;

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
//        for (Map<String, Object> map : mapList) {
//            System.out.println(map);
//        }

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
                    callTreeNodesStack.peek().getChildRenCallTreeNodes().add(callTreeNode);
                }
            }
        }

        analysisExecTime(callTreeNode);
        System.out.println(JSON.toJSONString(callTreeNode,true));
    }

    private void analysisExecTime(CallTreeNode callTreeNode){
        callTreeNode.setTotalTime(callTreeNode.getEndTime()-callTreeNode.getStartTime());
        long childRenExecTotal=0;
        for (CallTreeNode treeNode : callTreeNode.getChildRenCallTreeNodes()) {
            if(treeNode.getChildRenCallTreeNodes().size()>0){
                analysisExecTime(treeNode);
            }

            childRenExecTotal+=treeNode.getTotalTime();
        }
        callTreeNode.setSelfTime(callTreeNode.getTotalTime()-childRenExecTotal);
    }

    private boolean isStackStart(){
        return 0==stackCount;
    }
    private boolean isStackEnd(){
        return 0==stackCount;
    }
}
