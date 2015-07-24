import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;
import x10.util.concurrent.AtomicInteger;
import x10.util.ArrayList;
import x10.util.Random  ;


/**
 * Distributed version of Longest Palindrome Subsequence only using X10
 */
public class ManhattanTourist2 {

    private val height:Int;
    private val width:Int;

    private val dist:Dist;
    private val distMatrix:DistArray[ManhattanTouristNode];
    private val readyTaskList:PlaceLocalHandle[ArrayList[ManhattanTouristNodeId]];

    // use two 2d DistArray to represent the Manhattan distances
    // better to distribute them as the DAG vertices
    private row_dis : DistArray[Int];
    private col_dis : DistArray[Int];

    public def this(height:Int, width:Int) {
        this.height = height;
        this.width = width;
        val region = Region.make(0..(height-1n), 0..(width-1n));
        this.dist = Dist.makeBlock(region, 1);
        this.distMatrix = DistArray.make[ManhattanTouristNode](this.dist);
        this.readyTaskList = PlaceLocalHandle.makeFlat[ArrayList[ManhattanTouristNodeId]]
            (Place.places(), ()=>new ArrayList[ManhattanTouristNodeId](), (p:Place)=>true);

        val rand = new Random();
        this.row_dis = DistArray.make[Int](dist, (p:Point)=>{return rand.nextInt(10n);} );
        this.col_dis = DistArray.make[Int](dist, (p:Point)=>{return rand.nextInt(10n);} );

        Console.OUT.println("X10_NPLACES:"+Place.numPlaces()+", X10_NTHREADS:"+Runtime.NTHREADS);
    }


    public def init() {
        Place.places().broadcastFlat(()=>{
            val it = distMatrix.getLocalPortion().iterator();
            while(it.hasNext()) {
                val point:Point = it.next();
                val i = point(0), j = point(1);
                var indegree:Int;
                if(i==0 && j==0) {
                    indegree = 0n;
                    this.readyTaskList().add(new ManhattanTouristNodeId(i as Int, j as Int));
                } else if(i==0) {
                    indegree = 1n;
                } else if(j==0) {
                    indegree = 1n; 
                } else {
                    indegree = 2n;
                }
                distMatrix(point) = new ManhattanTouristNode(indegree);
            }
        });
    }

    private def manhatan() {
        finish
        for (p in Place.places()) async at(p) {
            val allNodeCount = distMatrix.getLocalPortion().size;
            var finishCount:Long = 0;
            while(true) {

                while(!this.readyTaskList().isEmpty()) {
                    val mtnids = getAllReadyNodes();
                    finishCount += mtnids.size();
                    async work(mtnids);
                }

                Runtime.probe();

                if (finishCount == allNodeCount)
                    break;
            }
        }
    }


     private def work(knids:ArrayList[ManhattanTouristNodeId]) {
        for(val knid in knids) {
            compute(knid);
        }
    }

    private def compute(knid:ManhattanTouristNodeId) {
        val i = knid.i;
        val j = knid.j;
        val node:ManhattanTouristNode = distMatrix(i, j);
        node.isFinish = true;

        // compute the score
        if( i == 0n && j == 0n ) {
            node.score = 0n;
        } else if(i==0n) {
            node.score = getScore(i, j-1n) + getRowDistance(i, j-1n);
        } else if(j==0n) {
            node.score = getScore(i-1n, j) + getColDistance(i-1n, j);
        } else {
            val left = getScore(i, j-1n) + getRowDistance(i, j-1n);
            val up = getScore(i-1n, j) + getColDistance(i-1n, j);
            node.score = Math.max(left, up);
        }

        // decrement the indegree of dependent nodes
        if(i==height-1n && j==width-1n) {
            // no anti dependent
        } else if(i==height-1n) {
            decrementIndegree(i, j+1n);
        } else if(j==width-1n) {
            decrementIndegree(i+1n, j);
        } else {
            decrementIndegree(i, j+1n);
            decrementIndegree(i+1n, j);
        }

        //Console.OUT.println(i+","+j+": "+node.score);
        //printIndegree();
    }

    private def getRowDistance(i:Int, j:Int) {
        val p = row_dis.dist(i, j);
        val dis:Int;
        if(p==here)
            dis = row_dis(i, j);
        else
            dis = at(p) row_dis(i, j);
        return dis;
    }
    private def getColDistance(i:Int, j:Int) {
        val p = col_dis.dist(i, j);
        val dis:Int;
        if(p==here)
            dis = col_dis(i, j);
        else
            dis = at(p) col_dis(i, j);
        return dis;
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
                addReadyNode(new ManhattanTouristNodeId(i, j));
        } else {
            val indegree = distMatrix(i, j).indegree.decrementAndGet();
            if(indegree==0n)
                addReadyNode(new ManhattanTouristNodeId(i, j));
        }
    }
    private atomic def addReadyNode(point:ManhattanTouristNodeId) {
        this.readyTaskList().add(point);
    }
    public atomic def getAllReadyNodes() {
        val mtnids = this.readyTaskList().clone();
        this.readyTaskList().clear();
        return mtnids;
    }

    public static def main(args:Rail[String]) {
        var height:Int = 10n;
        var width:Int = 10n;
        if(args.size == 2) {
            height = Int.parse(args(0));
            width = Int.parse(args(1));
        }

        Console.OUT.println("height: "+height+", width: "+width);
        val app = new ManhattanTourist2(height, width);
        app.init();
        var time:Long = -System.currentTimeMillis();
        app.manhatan();
        //app.printMatrix();
        time += System.currentTimeMillis();
        app.getScore(height-1n, width-1n);
        Console.OUT.println("spend time:"+time+"ms");
    }

    public static class ManhattanTouristNode {
        public var indegree:AtomicInteger;
        public var score:Int;
        public var isFinish:Boolean;

        public def this(indegree:Int) {
            this.score = 0n;
            this.indegree = new AtomicInteger(indegree);
            this.isFinish = false;
        }
    }

    public static struct ManhattanTouristNodeId {
        public val i:Int;
        public val j:Int;
        public def this(i:Int, j:Int) {
            this.i = i;
            this.j = j;
        }
    }


    private def printMatrix() {
        for(var i:Int=0n;i<this.height;i++) {
            for (var j:Int=0n; j<this.width; j++) {
                Console.OUT.print(getScore(i, j)+" ");
            }
            Console.OUT.println();
        }
    }
     private def printIndegree() {
        Console.OUT.println("indegree matrix:");
        for(var i:Int=0n;i<this.height;i++) {
            for (var j:Int=0n; j<this.width; j++) {
                val ii = i, jj = j;
                var indegree:Int;
                val p = dist(ii, jj);
                if(p!=here)
                    indegree = at(p) distMatrix(ii,jj).indegree.get();
                else
                    indegree = distMatrix(i, j).indegree.get();
                Console.OUT.print(indegree+" ");
            }
            Console.OUT.println();
        }
    }
    

}