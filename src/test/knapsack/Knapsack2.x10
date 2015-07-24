import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;
import x10.util.concurrent.AtomicInteger;
import x10.util.ArrayList;
import x10.util.Random  ;


/**
 * Distributed version of 01 Knapsack problem only using X10
 */
public class Knapsack2 {

    public val _capacity:Int;    // knapsack capacity
    public val _item_num:Int;    // number of items
    public val _profit:Rail[Int];
    public val _weight:Rail[Int];

    private val dist:Dist;
    private val distMatrix:DistArray[KnapNode];
    private val readyTaskList:PlaceLocalHandle[ArrayList[KnapNodeId]];

    public def this(capacity:Int, item_num:Int) {
        this._capacity = capacity;
        this._item_num = item_num;
        this._profit = new Rail[Int](item_num);
        this._weight = new Rail[Int](item_num);
        val rand = new Random();
        for(i in (1n..item_num) ) {
            this._profit(i-1n) = rand.nextInt(10n)+1n;
            this._weight(i-1n) = rand.nextInt(capacity*2n/item_num)+1n;
        }

        val region = Region.make(0..this._item_num, 0..this._capacity);
        this.dist = Dist.makeBlock(region, 1);
        this.distMatrix = DistArray.make[KnapNode](this.dist);
        this.readyTaskList = PlaceLocalHandle.makeFlat[ArrayList[KnapNodeId]]
            (Place.places(), ()=>new ArrayList[KnapNodeId](), (p:Place)=>true);

        Console.OUT.println("item_num:"+item_num+", capacity:"+capacity);
        Console.OUT.println("X10_NPLACES:"+Place.numPlaces()+", X10_NTHREADS:"+Runtime.NTHREADS);
    }

    public def init() {
        Place.places().broadcastFlat(()=>{
            val it = distMatrix.getLocalPortion().iterator();
            while(it.hasNext()) {
                val point:Point = it.next();
                val i = point(0), j = point(1);
                var indegree:Int;
                if( i == 0 || j == 0 ) {
                    indegree = 0n;
                    this.readyTaskList().add(new KnapNodeId(i as Int, j as Int));
                } else {
                    if( this._weight(i-1) <= j )
                        indegree = 2n;
                    else
                        indegree = 1n;
                }
                distMatrix(point) = new KnapNode(indegree);
            }
        });
    }


    private def knap() {
        finish
        for (p in Place.places()) async at(p) {
            val allNodeCount = distMatrix.getLocalPortion().size;
            var finishCount:Long = 0;
            while(true) {

                if(!this.readyTaskList().isEmpty()) {
                    val knids = getAllReadyNodes();
                    finishCount += knids.size();
                    async work(knids);
                }

                Runtime.probe();

                if (finishCount == allNodeCount)
                    break;
            }
        }
    }


     private def work(knids:ArrayList[KnapNodeId]) {
        for(val knid in knids) {
            compute(knid);
        }
    }

    private def compute(knid:KnapNodeId) {
        val i = knid.i;
        val j = knid.j;
        val node:KnapNode = distMatrix(i, j);
        node.isFinish = true;

        // compute the score
        if( i == 0n || j == 0n ) {
            node.score = 0n;
        } else {
            if( this._weight(i-1) <= j ) {
                val v1 = getScore(i-1n, j);
                val v2 = getScore(i-1n, j-this._weight(i-1)) + this._profit(i-1);
                node.score = Math.max(v1, v2);
            } else {
                node.score = getScore(i-1n, j);
            }
        }

        // decrement the indegree of dependent nodes
        if ( i == 0n ) {
            decrementIndegree(i+1n, j);
        } else if( i  == this._item_num ) {
            if( j+this._weight(i-1) <= this._capacity)
                decrementIndegree(i, j+this._weight(i-1));
        } else {
            if( j+this._weight(i-1) > this._capacity ) {
                decrementIndegree(i+1n, j);
            } else {
                decrementIndegree(i+1n, j);
                decrementIndegree(i, j+this._weight(i-1));
            }
        }
    }

    private def getScore(i:Int, j:Int) {
        val p = dist(i, j);
        if(p!=here)
            return at(p) distMatrix(i,j).score;
        return distMatrix(i, j).score;
    }
    private def decrementIndegree(i:Int, j:Int) {
        //Console.OUT.println("decrement "+i+","+j);
        val p = dist(i, j);
        if(p!=here) at(p) {
            val indegree = distMatrix(i, j).indegree.decrementAndGet();
            if(indegree==0n)
                addReadyNode(new KnapNodeId(i, j));
        } else {
            val indegree = distMatrix(i, j).indegree.decrementAndGet();
            if(indegree==0n)
                addReadyNode(new KnapNodeId(i, j));
        }
    }
    private atomic def addReadyNode(point:KnapNodeId) {
        this.readyTaskList().add(point);
    }
    public atomic def getAllReadyNodes() {
        val knids = this.readyTaskList().clone();
        this.readyTaskList().clear();
        return knids;
    }


    public static def main(args:Rail[String]) {
        var item_num:Int = 6n;
        var capacity:Int = 40n;
        if( args.size == 2 ) {
            item_num = Int.parseInt(args(0));
            capacity = Int.parseInt(args(1));
        }
        val app = new Knapsack2(capacity, item_num);
        app.init();
        var time:Long = -System.currentTimeMillis();
        app.knap();
        time += System.currentTimeMillis();
        Console.OUT.println("spend time:"+time+"ms");
    }

    public static class KnapNode {
        public var indegree:AtomicInteger;
        public var score:Int;
        public var isFinish:Boolean;

        public def this(indegree:Int) {
            this.score = 0n;
            this.indegree = new AtomicInteger(indegree);
            this.isFinish = false;
        }
    }

    public static struct KnapNodeId {
        public val i:Int;
        public val j:Int;
        public def this(i:Int, j:Int) {
            this.i = i;
            this.j = j;
        }
    }



    private def printMatrix(dist:Dist, distMatrix:DistArray[Int]) {
        for(var i:Int=0n;i<this._item_num;i++) {
            for (var j:Int=0n; j<this._capacity; j++) {
                Console.OUT.print(getScore(i, j)+" ");
            }
            Console.OUT.println();
        }
    }
}