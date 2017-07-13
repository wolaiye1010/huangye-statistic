package com.bj58.statistic.web.controller;

import com.bj58.statistic.web.service.StatisticDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

/**
 * Created by zhangbo23 on 2017/7/10.
 */
@Controller
public class StatisticsController {

    @Autowired
    private StatisticDataService statisticDataService;

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

    @RequestMapping("/native_data")
    @ResponseBody
    public String nativeData(HttpServletRequest request){

        return request.getParameter("xhprof_data");
    }

    @RequestMapping(value = "/statistic/help")
    public String help() {
        return "help";
    }


    @RequestMapping("/api/clear_list")
    @ResponseBody
    public Object clearList(){
        return statisticDataService.clearList();
    }


    @RequestMapping("/xhprof_call_graph/{key}")
    public String xhprofUrlCallGraph(@PathVariable String key){
        return "redirect:"+statisticDataService.getXhprofUrlCallGraph(key);
    }

    @RequestMapping("/xhprof_call_text/{key}")
    public String xhprofUrlCallText(@PathVariable String key){
        return "redirect:"+statisticDataService.getXhprofUrlCallText(key);
    }
}
