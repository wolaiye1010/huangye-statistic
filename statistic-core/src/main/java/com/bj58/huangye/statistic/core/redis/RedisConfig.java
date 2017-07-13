package com.bj58.huangye.statistic.core.redis;

/**
 * Created by zhudongchang on 2017/7/5.
 */
public class RedisConfig {
    private String host;
    private int port;
    private String auth;

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public int getPort() {
        return port;
    }

    public void setPort(int port) {
        this.port = port;
    }

    public String getAuth() {
        return auth;
    }

    public void setAuth(String auth) {
        this.auth = auth;
    }
}
