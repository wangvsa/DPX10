package tada;

import x10.util.ArrayList;

public class Configuration {

    public static val DIST_BLOCK_0 = "DIST_BLOCK_0";
    public static val DIST_BLOCK_1 = "DIST_BLOCK_1";
    public static val DIST_BLOCK_BLOCK = "DIST_BLOCK_BLOCK";

    public static val SCHEDULE_LOCAL = "SCHEDULE_LOCAL";
    public static val SCHEDULE_RANDOM = "SCHEDULE_RANDOM";
    public static val SCHEDULE_MINIMUM_COMM = "SCHEDULE_MINIMUM_COMM";



    // Now we have five options can be tuned
    public var loopForSchedule:Int=1n;
    public var cacheSize:Int = 100n;
    public var distManner:String = "DIST_BLOCK_1";
    public var scheduleStrategy:String = "SCHEDULE_LOCAL";
    public var isLoadBalance:Boolean = false;  // not used for now


    private val args:ArrayList[String];

    public def this(arg_array:Rail[String]) {
        this.args = new ArrayList[String]();
        for(arg in arg_array) {
            if(arg.startsWith("-"))
                args.add(arg);
        }

        parseLoopForSchedule();
        parseDistributionManner();
        parseScheduleStrategy();
        parseCacheSize();
        parseIsLoadBalance();

    }

    /**
     * For dist in Dag
     * -bb: BlockBlock manner(default)
     * -b0: Block along 0 index
     * -b1: Block along 1 index
     */
    private def parseDistributionManner() {
        for(arg in args) {
            if(arg.equals("-b0"))
                this.distManner = DIST_BLOCK_0;
            if(arg.equals("-b1"))
                this.distManner = DIST_BLOCK_1;
            if(arg.equals("-bb"))
                this.distManner = DIST_BLOCK_BLOCK;
        }
    }

    /**
     * For scheduler in Worker
     * -sl : local schedule(default)
     * -sm : minimum communication schedule
     * -sr : random schedule
     */
    private def parseScheduleStrategy() {
        for(arg in args) {
            if(arg.equals("-sr"))
                this.scheduleStrategy =  SCHEDULE_RANDOM;
            if(arg.equals("-sm"))
                this.scheduleStrategy = SCHEDULE_MINIMUM_COMM;
            if(arg.equals("-sl"))
                this.scheduleStrategy = SCHEDULE_LOCAL;
        }
    }

    /**
     * Loop time for on scheduling in TadaWork
     * TODO not usefull, can not promote efficiency ?
     * --loop=N
     */
    private def parseLoopForSchedule() {
        for (arg in args) {
            if(arg.startsWith("--loop") && arg.indexOf("=")!=-1n)
                this.loopForSchedule = Int.parse(arg.split("=")(1));
        }
    }

    /**
     * Set cache size
     * --cache=N
     */
    private def parseCacheSize() {
        var cacheSize:Int = 100n;
        for (arg in args) {
            if(arg.startsWith("--cache") && arg.indexOf("=")!=-1n)
                this.cacheSize = Int.parse(arg.split("=")(1));
        }
    }

    // -lb: use load balance
	private def parseIsLoadBalance() {
        for(arg in args) {
            if(arg.equals("-lb"))
                this.isLoadBalance = true;
        }
	}


    public def printConfiguration() {
        Console.OUT.println("dist:"+this.distManner+", schedule:"+this.scheduleStrategy+", cache:"+this.cacheSize+", loop:"+this.loopForSchedule);
    }

}