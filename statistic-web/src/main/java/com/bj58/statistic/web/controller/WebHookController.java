package com.bj58.statistic.web.controller;


import com.alibaba.fastjson.JSON;
import com.bj58.statistic.web.util.CommonUtils;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.util.Map;

/**
 * Created by zhudongchang on 2017/6/21.
 */
@Controller
public class WebHookController {

    private static final String TOKEN="1aa740dbb228e25bf8f02dc563f1ee30";

    String shellPath="/opt/web/huangye-statistic/develop.sh";

    @RequestMapping("/api/web_hook")
    @ResponseBody
    public void webHook(String token,HttpServletRequest request,HttpServletResponse response) throws IOException, InterruptedException {
        if(null==token||!token.equals(TOKEN)){
            return;
        }

        File file=new File(shellPath);
        if(!file.exists()){
            System.out.println("not exist");
            return;
        }
        System.out.println("web hook1");


        String requestBody = CommonUtils.getRequestBody(request);

        Map map = JSON.parseObject(requestBody, Map.class);

        if(null==map||!"refs/heads/snapshot".equals(map.get("ref"))){

            System.out.println("web hook2");
            return;
        }

        System.out.println("web hook3");

        response.getWriter().write("---start--");
        Process exec = Runtime.getRuntime().exec(shellPath);
        response.getWriter().write("---end--");


        System.out.println("web hook4333");
        return;
    }
}
