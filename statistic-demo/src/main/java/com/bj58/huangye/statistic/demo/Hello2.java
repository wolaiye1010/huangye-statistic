package com.bj58.huangye.statistic.demo;

import org.junit.Test;

/**
 * Created by zhudongchang on 2017/6/30.
 */
public class Hello2 {

//    public void sayHello(int i){
//        System.out.println("test.Hello2 AspectJ."+i);
//    }

    public void sayHello(){
        System.out.println(System.nanoTime());
        System.out.println(System.nanoTime());
//        sayHello(100);
        System.out.println("test.Hello2 AspectJ.");
//        sayHello(101);
    }

    public static void bar(){
        System.out.println("bar.........");
        System.out.println(bar(2));
    }


    public static int bar(int i){
        System.out.println("bar int 1");
        return i;
    }

    public void foo(){
        System.out.println("foo......");
    }


    public static void main(String[] args) {
//        new Thread("1"){
//            @Override
//            public void run() {
//                try {
//                    Thread.sleep(100L);
//                } catch (InterruptedException e) {
//                    e.printStackTrace();
//                }
//                bar();
//            }
//        }.start();
//
//
//        new Thread("2"){
//            @Override
//            public void run() {
//                try {
//                    Thread.sleep(80L);
//                } catch (InterruptedException e) {
//                    e.printStackTrace();
//                }
//                bar();
//            }
//        }.start();
        bar();
    }
}