package tada;

import x10.util.ArrayList;

public class Configuration {

    public static val DIST_BLOCK_0 = "DIST_BLOCK_0";
    public static val DIST_BLOCK_1 = "DIST_BLOCK_1";
    public static val DIST_BLOCK_BLOCK = "DIST_BLOCK_BLOCK";

    public static val SCHEDULE_LOCAL = "SCHEDULE_LOCAL";
    public static val SCHEDULE_RANDOM = "SCHEDULE_RANDOM";
    public static val SCHEDULE_MINIMUM_COMM = "SCHEDULE_MINIMUM_COMM";


    private val args:ArrayList[String];

    public def this(arg_array:Rail[String]) {

        this.args = new ArrayList[String]();
        for(arg in arg_array) {
            if(arg.startsWith("-"))
                args.add(arg);
        }
    }

    /**
     * For dist in Dag
     * -bb: BlockBlock manner(default)
     * -b0: Block along 0 index
     * -b1: Block along 1 index
     */
    public def distributionManner() {
        for(arg in args) {
            if(arg.equals("-b0"))
                return DIST_BLOCK_0;
            if(arg.equals("-b1"))
                return DIST_BLOCK_1;
        }
        return DIST_BLOCK_BLOCK;
    }

    /**
     * For scheduler in Worker
     * -sl : local schedule(default)
     * -sm : minimum communication schedule
     * -sr : random schedule
     */
    public def scheduleStrategy() {
        for(arg in args) {
            if(arg.equals("-sr"))
                return SCHEDULE_RANDOM;
            if(arg.equals("-sm"))
                return SCHEDULE_MINIMUM_COMM;
        }
        return SCHEDULE_LOCAL;
    }

    // -lb: use load balance
	public def isLoadBalance() {
        for(arg in args) {
            if(arg.equals("-lb"))
                return true;
        }
		return false;
	}

}