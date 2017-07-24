package com.bj58.huangye.statistic.demo;

import org.junit.Test;

import java.util.UUID;

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
//        bar();
//
//        System.out.println(UUID.randomUUID());

        testf(10);
    }


    public static void testf(int i){
        i--;
        try {
            System.out.println(i);
            Thread.sleep(100);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        if(i<1){
            return;
        }
        testf(i);
    }

    private static ThreadLocal<Integer> threadLocal=new ThreadLocal<Integer>(){
        @Override
        protected Integer initialValue() {
            System.out.println("init");
            return new Integer(0);
        }
    };
}
