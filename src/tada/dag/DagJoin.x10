package tada.dag;

/**
 *  一个两层的Join模型，共有N个任务
 *  第一层N-1个任务且无依赖，第二层有1个任务，依赖第一层所有任务
 */
public class DagJoin[T]{T haszero} extends Dag[T]{

    public def this(width:Int) {
        super(1n, width);
    }

    public def getDependencyTasksLocation(i:Int, j:Int):Rail[Location] {

        val locs:Rail[Location];

        if(i==0n)    // 第一层无依赖
            locs = new Rail[Location](0);
        else {      // 第二层依赖第一层
            locs = new Rail[Location](this.taskSize-1);
            for(k in 0..(this.taskSize-1)) {
                locs(k) = new Location(0n, k as Int);
            }
        }

        return locs;
    }

    public def getAntiDependencyTasksLocation(i:Int, j:Int):Rail[Location] {
        val locs:Rail[Location];

        if(i==1n)  // 第二层
            locs = new Rail[Location](0);
        else {    // 第一层
            locs = new Rail[Location](1);
            locs(0) = new Location(1n, 0n); // 只被最后一个节点依赖
        }

        return locs;
    }


}
