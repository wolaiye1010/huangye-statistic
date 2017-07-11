package com.bj58.statistic.web.controller;

import com.bj58.statistic.web.service.StatisticDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;

/**
 * Created by zhangbo23 on 2017/7/10.
 */
@Controller
public class StatisticsController {

    @Autowired
    StatisticDataService statisticDataService;

    @RequestMapping(value = "/")
    public ModelAndView index() {
        return new ModelAndView("forward:/statistic/times?id=times");
    }

    @RequestMapping(value = "/statistic/times")
    public String timeStatistic(Model model) {
        List<Map<String, Object>> list = statisticDataService.getList();
        model.addAttribute("list",list);
        return "time_statistic";
    }


    @RequestMapping(value = "/statistic/help")
    public String help() {
        return "help";
    }
}
