package com.bj58.statistic.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created by zhangbo23 on 2017/7/10.
 */
@Controller
public class StatisticsController {

    @RequestMapping(value = "/statistic/times")
    public String timeStatistic() {
        return "time_statistic";
    }


    @RequestMapping(value = "/statistic/help")
    public String help() {
        return "help";
    }
}
