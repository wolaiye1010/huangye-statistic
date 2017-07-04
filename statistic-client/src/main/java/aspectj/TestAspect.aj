package aspectj;

/**
 * Created by zhudongchang on 2017/6/30.
 */
public aspect TestAspect {

//    void around():call(void Hello.sayHello()){
//        System.out.println("begin transaction....");
//        proceed();//代表调用原来的sayHello()方法
//        System.out.println("end transaction....");
//    }

    pointcut barPoint() :  execution(* *(..));

    //    before():barPoint(){
//        System.out.println("barPoint");
//    }

    pointcut barCfow() : cflow(barPoint())&&!within(TestAspect);//cflow的参数是一个pointcut

    before() : barCfow(){
        System.out.println("Enter before:" + thisJoinPoint);
    }

    after():barCfow(){
        System.out.println("Enter after:" + thisJoinPoint);
    }

//    pointcut HelloWorldPointCut(int i) : execution(* sayHello(int))&&args(i);
//
//    before(int x) : HelloWorldPointCut(x){
//        System.out.println("Entering : " + thisJoinPoint.getSourceLocation());
//        System.out.println("begin intercept"+x);
//    }
//
//    after(int x) : HelloWorldPointCut(x){
//        System.out.println("end intercept");
//    }
}


