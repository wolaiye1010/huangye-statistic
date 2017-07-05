package com.bj58.huangye.statistic.core.util;

import java.util.Calendar;
import java.util.Date;

/**
 * Created by zhudongchang on 2017/7/5.
 */
public class CalendarUtil {

    /**
     * 获取明天凌晨的uinx 时间戳
     * @return
     */
    public static long getTomorrowDawnUinxTimestamp(){
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.DATE,calendar.get(Calendar.DATE)+1);
        calendar.set(Calendar.HOUR_OF_DAY,0);
        calendar.set(Calendar.MINUTE,0);
        calendar.set(Calendar.SECOND,0);
        calendar.set(Calendar.MILLISECOND,0);
        return calendar.getTimeInMillis()/1000;
    }
}
