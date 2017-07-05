package test;

import org.junit.Test;

/**
 * Created by zhudongchang on 2017/6/30.
 */
public class Hello {

//    public void sayHello(int i){
//        System.out.println("test.Hello AspectJ."+i);
//    }

    public void sayHello(){
        System.out.println(System.nanoTime());
        System.out.println(System.nanoTime());
//        sayHello(100);
        System.out.println("test.Hello AspectJ.");
//        sayHello(101);
    }

    public void bar(){
//        foo();
        Hello1.foo();
        System.out.println("bar.........");
        bar(2);
    }


    public void bar(int i){
    }

    public void foo(){
        System.out.println("foo......");
    }


    @Test
    public void testMethod(){
        bar();
        bar();
//        foo();
    }

    public static void main(String[] args) {
        Hello he = new Hello();
        he.sayHello();
    }
}
