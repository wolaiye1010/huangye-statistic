package com.bj58.huangye.statistic.demo;

/**
 * Created by zhudongchang on 2017/7/18.
 */
public class ThreadTest {

    private static int race=0;

    private  synchronized static void inc(){
        race++;
    }
    public static void main(String[] args) {
        int a=0;
//        a++;
//        for (int i=0;i<20;i++){
//            new Thread(new Runnable() {
//                @Override
//                public void run() {
//                    for (int j = 0; j < 10000; j++) {
//                        inc();
//                        System.out.println(race);
//                    }
//                }
//            }).start();
//        }
//
//        while (Thread.activeCount()>2){
//            System.out.println(Thread.activeCount());
//            Thread.yield();
//        }
//        System.out.println(race);
    }
}
