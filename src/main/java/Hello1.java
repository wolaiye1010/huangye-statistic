
import org.junit.Test;

/**
 * Created by zhudongchang on 2017/6/30.
 */
public class Hello1 {
    public static void foo(){
        System.out.println("foo......");
        foo1();
    }


    public static void foo1(){
        System.out.println("foo1......");
    }
}
