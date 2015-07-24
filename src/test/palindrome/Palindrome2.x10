import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;
import x10.util.concurrent.AtomicInteger;
import x10.util.ArrayList;
import x10.util.Random  ;


/**
 * Distributed version of Longest Palindrome Subsequence only using X10
 */
public class Palindrome2 {
    public val str:String;

    private val dist:Dist;
    private val distMatrix:DistArray[PalindromeNode];
    private val readyTaskList:PlaceLocalHandle[ArrayList[PalindromeNodeId]];

    public def this(length:Int) {

        str = generateRandomString(length);

        val region = Region.make(0..(length-1), 0..(length-1));
        this.dist = Dist.makeBlock(region, 1);
        this.distMatrix = DistArray.make[PalindromeNode](this.dist);
        this.readyTaskList = PlaceLocalHandle.makeFlat[ArrayList[PalindromeNodeId]]
            (Place.places(), ()=>new ArrayList[PalindromeNodeId](), (p:Place)=>true);

        Console.OUT.println("X10_NPLACES:"+Place.numPlaces()+", X10_NTHREADS:"+Runtime.NTHREADS);
    }

    public def init() {
        Place.places().broadcastFlat(()=>{
            val it = distMatrix.getLocalPortion().iterator();
            while(it.hasNext()) {
                val point:Point = it.next();
                val i = point(0), j = point(1);
                var indegree:Int;
                if(i >= j) {
                    indegree = 0n;
                    this.readyTaskList().add(new PalindromeNodeId(i as Int, j as Int));
                } else {
                    indegree = 3n;
                }
                distMatrix(point) = new PalindromeNode(indegree);
            }
        });
    }

    private def lps() {
        finish
        for (p in Place.places()) async at(p) {
            val allNodeCount = distMatrix.getLocalPortion().size;
            var finishCount:Long = 0;
            while(true) {

                while(!this.readyTaskList().isEmpty()) {
                    val pnids = getAllReadyNodes();
                    finishCount += pnids.size();
                    async work(pnids);
                }

                Runtime.probe();

                if (finishCount == allNodeCount)
                    break;
            }
        }
    }


     private def work(knids:ArrayList[PalindromeNodeId]) {
        for(val knid in knids) {
            compute(knid);
        }
    }

    private def compute(knid:PalindromeNodeId) {
        val i = knid.i;
        val j = knid.j;
        val node:PalindromeNode = distMatrix(i, j);
        node.isFinish = true;

        // compute the score
        if( i >= j ) {
            node.score = 1n;
        } else {
            var left:Int = 0n, leftbottom:Int = 0n, bottom:Int=0n;
            leftbottom = getScore(i+1n, j-1n);
            left = getScore(i, j-1n);
            bottom = getScore(i+1n, j);

            if(str.charAt(i) == str.charAt(j)) {
                if(j==i+1n)
                    node.score = 2n;
                else
                    node.score = leftbottom + 2n;
            } else {
                node.score = Math.max(left, bottom);
            }
        }

        // decrement the indegree of dependent nodes
        val len = str.length();
        if(i>j+1n) {

        } else if(i==j+1n) {
            decrementIndegree(i-1n, j+1n);
        } else {
            if(i-1n>=0n && j+1n<len) {
                decrementIndegree(i-1n, j+1n);
                decrementIndegree(i, j+1n);
                decrementIndegree(i-1n, j);
            } else if(i-1n >= 0n) {
                decrementIndegree(i-1n, j);
            } else if(j+1n < len) {
                decrementIndegree(i, j+1n);
            }
        } 
        //Console.OUT.println(i+","+j+": "+node.score);
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
                addReadyNode(new PalindromeNodeId(i, j));
        } else {
            val indegree = distMatrix(i, j).indegree.decrementAndGet();
            if(indegree==0n)
                addReadyNode(new PalindromeNodeId(i, j));
        }
    }
    private atomic def addReadyNode(point:PalindromeNodeId) {
        this.readyTaskList().add(point);
    }
    public atomic def getAllReadyNodes() {
        val pnids = this.readyTaskList().clone();
        this.readyTaskList().clear();
        return pnids;
    }

    public static def main(args:Rail[String]) {

        var length:Int = 10n;
        if(args.size==1)
            length = Int.parse(args(0));

        Console.OUT.println("length: "+length);
        val app = new Palindrome2(length);
        app.init();
        var time:Long = -System.currentTimeMillis();
        app.lps();
        //app.printMatrix();
        time += System.currentTimeMillis();
        Console.OUT.println("result: "+app.getScore(0n, length-1n));
        Console.OUT.println("spend time:"+time+"ms");
    }

    public static class PalindromeNode {
        public var indegree:AtomicInteger;
        public var score:Int;
        public var isFinish:Boolean;

        public def this(indegree:Int) {
            this.score = 0n;
            this.indegree = new AtomicInteger(indegree);
            this.isFinish = false;
        }
    }

    public static struct PalindromeNodeId {
        public val i:Int;
        public val j:Int;
        public def this(i:Int, j:Int) {
            this.i = i;
            this.j = j;
        }
    }


    private def printMatrix() {
        for(var i:Int=0n;i<this.str.length();i++) {
            for (var j:Int=0n; j<this.str.length(); j++) {
                Console.OUT.print(getScore(i, j)+" ");
            }
            Console.OUT.println();
        }
    }
     private def printIndegree() {
        Console.OUT.println("indegree matrix:");
        for(var i:Int=0n;i<this.str.length();i++) {
            for (var j:Int=0n; j<this.str.length(); j++) {
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

    private def generateRandomString(length:Int) {
        val range = "abcdefghijklmnopqrstuvwxyz";
        val all_chars = range.chars();
        val rand = new Random();
        val str_chars = new Rail[Char](length);
        for(var i:Int=0n;i<length;i++) {
            str_chars(i) = all_chars(rand.nextLong(all_chars.size));
        }
        return new String(str_chars);
    }
    

}