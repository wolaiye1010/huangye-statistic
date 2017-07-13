package com.bj58.statistic.web.util;

import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletRequest;

/**
 * Created by zhudongchang on 2017/5/9.
 */
public class CommonUtils {

    public static String getRequestBody(HttpServletRequest request){
        try{
            ServletInputStream servletInputStream = request.getInputStream();

            StringBuilder stringBuilder=new StringBuilder();
            byte[]readBuffer=new byte[1000];

            int readLength;
            while (-1!=(readLength=servletInputStream.read(readBuffer))){
                stringBuilder.append(new String(readBuffer,0,readLength));
            }
            return stringBuilder.toString();
        }catch (Exception e){
            throw new RuntimeException(e);
        }
    }

}
