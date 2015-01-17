import x10.io.File;
import x10.io.IOException;
import x10.util.ArrayList;
import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;
import x10.util.concurrent.AtomicInteger;


/**
 * This is used for comparision with Tada
 * This is the distributed version of SmithWaterman algorithm wirtten by X10 only
 */
public class SmithWaterman2 {

    public var str1:String;
    public var str2:String;
    public var M:Int;
    public var N:Int;

    // same parameters with Tada's demo
    static val MATCH_SCORE = 2n;
    static val DISMATCH_SCORE = -1n;
    static val GAP_PENALTY = -1n;       // use linear gap penalty


    private val dist:Dist;
    private val distMatrix:DistArray[SWNode];
    private var readyTaskList:PlaceLocalHandle[ArrayList[SWNodeId]];


    // read the same string from Tada's demo
    public def this() {
        str1 = new String();
        str2 = new String();
        try {
            val input1 = new File("../../demo/smithwaterman/SW_STR1.txt");
            for(line in input1.lines())
                str1 += line;
            val input2 = new File("../../demo/smithwaterman/SW_STR2.txt");
            for(line in input2.lines())
                str2 += line;
        } catch(IOException) {}

        this.M = str1.length();
        this.N = str2.length();
        Console.OUT.println("str1.length:"+this.M+", str2.length:"+this.N);
        Console.OUT.println("X10_NPLACES:"+Place.numPlaces()+", X10_NTHREADS:"+Runtime.NTHREADS);

        val region = Region.make(0..(this.M-1n), 0..(this.N-1n));
        this.dist = Dist.makeBlock(region, 1);
        this.distMatrix = DistArray.make[SWNode](this.dist);
    }

    // Init distributed score matrix with zero
    private def init() {
        this.readyTaskList = PlaceLocalHandle.makeFlat[ArrayList[SWNodeId]]
            (Place.places(), ()=>new ArrayList[SWNodeId](), (p:Place)=>true);

        Place.places().broadcastFlat(()=>{
            val it = distMatrix.getLocalPortion().iterator();
            while(it.hasNext()) {
                val point:Point = it.next();
                var indegree:Int = 3n;
                if(point(0)==0 && point(1)==0) {
                    indegree = 0n;
                    this.readyTaskList().add(new SWNodeId(point(0) as Int, point(1) as Int));
                } else if(point(0)==0 || point(1)==0)
                    indegree = 1n;
                distMatrix(point) = new SWNode(indegree);
            }
        });

    }


    private def sw() {
        finish
        for (p in Place.places()) async at(p) {
            val allNodeCount = distMatrix.getLocalPortion().size;
            var finishCount:Long = 0;
            while(true) {

                while(!this.readyTaskList().isEmpty()) {
                    val nids = new ArrayList[SWNodeId]();
                    nids.add(getReadyNode());
                    finishCount++;
                    async work(nids);
                }

                Runtime.probe();

                if (finishCount == allNodeCount)
                    break;
            }
        }
    }

    private def work(nids:ArrayList[SWNodeId]) {
        for(val nid in nids) {
            compute(nid);
        }
    }

    private def compute(nid:SWNodeId) {
        val node:SWNode = distMatrix(nid.i, nid.j);
        node.isFinish = true;
        val i = nid.i;
        val j = nid.j;
        //Console.OUT.println("work "+i+","+j+" "+here);

        // compute the score
        if(i==0n && j==0n) {
            node.score = str1.charAt(i)==str2.charAt(j) ? MATCH_SCORE : DISMATCH_SCORE;
        } else if(i==0n) {
            node.score = getScore(i, j-1n) + GAP_PENALTY;
        } else if(j==0n) {
            node.score = getScore(i-1n, j) + GAP_PENALTY;
        } else {
            var v1:Int = getScore(i-1n, j-1n) + ( str1.charAt(i)==str2.charAt(j) ? MATCH_SCORE : DISMATCH_SCORE );
            val v2:Int = getScore(i-1n, j) + GAP_PENALTY;
            val v3:Int = getScore(i, j-1n) + GAP_PENALTY;
            node.score = Math.max(v1, Math.max(v2, v3));
        }

        // decrement the indegree of dependent nodes
        if (i==M-1n && j==N-1n) {
            // do noting
        } else if (i==M-1n) {
            decrementIndegree(i, j+1n);
        } else if (j==N-1n) {
            decrementIndegree(i+1n, j);
        } else  {
            decrementIndegree(i, j+1n);
            decrementIndegree(i+1n, j);
            decrementIndegree(i+1n, j+1n);
        }
    }

    private def getScore(i:Int, j:Int) {
        val p = dist(i, j);
        if(p!=here)
            return at(p) distMatrix(i,j).score;
        return distMatrix(i, j).score;
    }
    private def decrementIndegree(i:Int, j:Int) {
        val p = dist(i, j);
        if(p!=here) at(p) {
            val indegree = distMatrix(i, j).indegree.decrementAndGet();
            if(indegree==0n)
                addReadyNode(new SWNodeId(i, j));
        } else {
            val indegree = distMatrix(i, j).indegree.decrementAndGet();
            if(indegree==0n)
                addReadyNode(new SWNodeId(i, j));
        }
    }
    private atomic def addReadyNode(nid:SWNodeId) {
        this.readyTaskList().add(nid);
    }
    public atomic def getReadyNode():SWNodeId {
        return this.readyTaskList().removeFirst();
    }



    private def walkback() {
        var i:Int = str1.length() as Int - 1n;
        var j:Int = str2.length() as Int - 1n;
        while(true) {
            if(i==0n|| j==0n)
                break;

            val c1 = str1.charAt(i);
            val c2 = str2.charAt(j);
            if(c1==c2)
                Console.OUT.print(c1);
            else
                Console.OUT.print("-");

            val tmpi = i, tmpj = j;
            val left = at(this.dist(tmpi-1, tmpj)) this.distMatrix(tmpi-1, tmpj).score;
            val up = at(this.dist(tmpi, tmpj-1)) this.distMatrix(tmpi, tmpj-1).score;
            val leftup = at(this.dist(tmpi-1, tmpj-1)) this.distMatrix(tmpi-1, tmpj-1).score;

            if(left >= up && left >= leftup) {
                i = i - 1n;
            } else if(up >= left && up >= leftup) {
                j = j - 1n;
            } else {
                i = i - 1n;
                j = j - 1n;
            }
        }

        Console.OUT.println();
    }

    private def printMatrix() {
        val M = str1.length();
        val N = str2.length();

        for(var i:Long=0;i<M;i++) {
            for (var j:Long=0; j<N; j++) {
                val tmpi = i, tmpj = j;
            	val score = at(this.dist(tmpi, tmpj)) this.distMatrix(tmpi, tmpj).score;
                Console.OUT.print(score+" ");
            }
            Console.OUT.println();
        }
    }


    public static def main(args:Rail[String]) {
        val smithwaterman = new SmithWaterman2();
        smithwaterman.init();
        var time:Long = -System.currentTimeMillis();
        smithwaterman.sw();
        time += System.currentTimeMillis();
        Console.OUT.println("spend time:"+time+"ms");

        //smithwaterman.printMatrix();
        //smithwaterman.walkback();
    }

    public static class SWNode {
        public var indegree:AtomicInteger;
        public var score:Int;
        public var isFinish:Boolean;

        public def this(indegree:Int) {
            this.score = 0n;
            this.indegree = new AtomicInteger(indegree);
            this.isFinish = false;
        }
    }

    public static struct SWNodeId {
        public val i:Int;    // row
        public val j:Int;    // col
        public def this(i:Int, j:Int) {
            this.i = i;
            this.j = j;
        }
    }

}