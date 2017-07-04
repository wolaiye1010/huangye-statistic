package com.bj58.huangye.statistic.client;

import java.util.List;

/**
 * Created by zhudongchang on 2017/7/4.
 */
public class CallTreeNode {
    private String name;
    private List<CallTreeNode> childRenCallTreeNodes;
    private long startTime;
    private long endTime;

    private long selfTime;

    private long totalTime;

    public long getSelfTime() {
        return selfTime;
    }

    public void setSelfTime(long selfTime) {
        this.selfTime = selfTime;
    }

    public long getTotalTime() {
        return totalTime;
    }

    public void setTotalTime(long totalTime) {
        this.totalTime = totalTime;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<CallTreeNode> getChildRenCallTreeNodes() {
        return childRenCallTreeNodes;
    }

    public void setChildRenCallTreeNodes(List<CallTreeNode> childRenCallTreeNodes) {
        this.childRenCallTreeNodes = childRenCallTreeNodes;
    }

    public long getStartTime() {
        return startTime;
    }

    public void setStartTime(long startTime) {
        this.startTime = startTime;
    }

    public long getEndTime() {
        return endTime;
    }

    public void setEndTime(long endTime) {
        this.endTime = endTime;
    }
}
