package tada.dag;

import tada.Configuration;

/**
 *  一个两层的Join模型，共有N个任务
 *  第一层N-1个任务且无依赖，第二层有1个任务，依赖第一层所有任务
 */
public class DagJoin[T]{T haszero} extends Dag[T]{

    public def this(width:Int, config:Configuration) {
        super(1n, width, config);
    }

    public def getDependencies(i:Int, j:Int):Rail[VertexId] {

        val vids:Rail[VertexId];

        if(i==0n)    // 第一层无依赖
            vids = new Rail[VertexId](0);
        else {      // 第二层依赖第一层
            vids = new Rail[VertexId](this.taskSize-1);
            for(k in 0..(this.taskSize-1)) {
                vids(k) = new VertexId(0n, k as Int);
            }
        }

        return vids;
    }

    public def getAntiDependencies(i:Int, j:Int):Rail[VertexId] {
        val vids:Rail[VertexId];

        if(i==1n)  // 第二层
            vids = new Rail[VertexId](0);
        else {    // 第一层
            vids = new Rail[VertexId](1);
            vids(0) = new VertexId(1n, 0n); // 只被最后一个节点依赖
        }

        return vids;
    }


}
