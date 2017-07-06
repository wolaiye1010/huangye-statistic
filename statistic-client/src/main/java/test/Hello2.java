package test;

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

    public void bar(){
//        foo();
        System.out.println("bar.........");
        System.out.println(bar(2));
    }


    public int bar(int i){
        System.out.println("bar int 1");
        return i;
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
        Hello2 he = new Hello2();
        he.sayHello();
    }
}
