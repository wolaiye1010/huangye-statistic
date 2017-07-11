package com.bj58.statistic.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by zhangbo23 on 2017/7/10.
 */
@Controller
public class StatisticsController {

    @RequestMapping(value = "/")
    public ModelAndView index() {
        return new ModelAndView("forward:/statistic/times?id=times");
    }

    @RequestMapping(value = "/statistic/times")
    public String timeStatistic() {
        return "time_statistic";
    }


    @RequestMapping(value = "/statistic/help")
    public String help() {
        return "help";
    }
}
