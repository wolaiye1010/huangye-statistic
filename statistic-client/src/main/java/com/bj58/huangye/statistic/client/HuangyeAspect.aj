package com.bj58.huangye.statistic.client;

import com.alibaba.fastjson.JSON;
import org.aspectj.lang.annotation.*;

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

    private void around():bj58PointCut(){
        if(isStackStart()){
            mapList.clear();
//            mapList.add(new HashMap<String,Object>(){{
//                put("method","main()");
//                put("start_time",System.nanoTime());
//            }});
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
//            mapList.add(new HashMap<String,Object>(){{
//                put("method","main()");
//                put("end_time",System.nanoTime());
//            }});
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
                    CallTreeNode parent=callTreeNodesStack.peek();
                    parent.getChildRenCallTreeNodes().add(callTreeNode);
                    callTreeNode.setParent(parent);
                }else{
                    callTreeNode.setParent(null);
                }
            }
        }

        analysisExecTime(callTreeNode);
//        System.out.println(JSON.toJSONString(callTreeNode,true));

        buildXhprofDataMap(callTreeNode);
        System.out.println(JSON.toJSONString(xhprofDataNodeMap,true));
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

    private boolean isStackStart(){
        return 0==stackCount;
    }
    private boolean isStackEnd(){
        return 0==stackCount;
    }
}
