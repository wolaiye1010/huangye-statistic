
import org.junit.Test;

import java.util.Date;

/**
 * Created by zhudongchang on 2017/6/30.
 */
public class Hello {

    public void sayHello(int i){
        System.out.println("Hello AspectJ."+i);
    }

    public void sayHello(){
        System.out.println(System.nanoTime());
        System.out.println(System.nanoTime());
        sayHello(100);
        System.out.println("Hello AspectJ.");
        sayHello(101);
    }

    public void bar(){
//        foo();
        Hello1.foo();
        System.out.println("bar.........");
    }


    public void foo(){
        System.out.println("foo......");
    }


    @Test
    public void testMethod(){
        bar();
//        foo();
    }

    public static void main(String[] args) {
        Hello he = new Hello();
        he.sayHello();
    }
}
