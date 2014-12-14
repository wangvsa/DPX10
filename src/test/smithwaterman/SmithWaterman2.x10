import x10.io.File;
import x10.io.IOException;
import x10.array.Array_2;
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

    // same parameters with Tada's demo
    static val MATCH_SCORE = 2n;
    static val DISMATCH_SCORE = -1n;
    static val GAP_PENALTY = -1n;       // use linear gap penalty

    // read the same string from Tada's demo
    public def this() {
        str1 = new String();
        str2 = new String();
        try {
            val input1 = new File("../demo/smithwaterman/SW_STR1.txt");
            for(line in input1.lines())
                str1 += line;
            val input2 = new File("../demo/smithwaterman/SW_STR2.txt");
            for(line in input2.lines())
                str2 += line;
        } catch(IOException) {}
        Console.OUT.println("str1.length:"+str1.length()+", str2.length:"+str2.length());
    }


    private def sw() {
        val M = str1.length();
        val N = str2.length();

        // distributed score matrix, init with zero
        val region = Region.make(0..(M-1n), 0..(N-1n));
        val dist = Dist.makeBlock(region, 1);
        val distMatrix = DistArray.make[SWNode](dist);
        Place.places().broadcastFlat(()=>{
            val it = distMatrix.getLocalPortion().iterator();
            while(it.hasNext()) {
                val point:Point = it.next();
                var indegree:Int = 3n;
                if(point(0)==0 && point(1)==0)
                    indegree = 0n;
                else if(point(0)==0 || point(1)==0)
                    indegree = 1n;
                distMatrix(point) = new SWNode(indegree);
            }
        });

        // start
        for (p in Place.places()) at(p) {
            val allNodeCount = distMatrix.getLocalPortion().size;
            var finishCount:Long = 0;
            Console.OUT.println("all nodes count:"+allNodeCount);
            while(true) {
                val it = distMatrix.getLocalPortion().iterator();
                while(it.hasNext()) {
                    val point:Point = it.next();
                    val node:SWNode = distMatrix(point);

                    // real work here
                    if(node.indegree.get()==0n && !node.isFinish) {
                        val i = point(0);
                        val j = point(1);

                        // compute the score
                        if(i==0 && j==0) {
                            node.score = str1.charAt(i as Int)==str2.charAt(j as Int) ? MATCH_SCORE : DISMATCH_SCORE;
                        } else if(i==0) {
                            node.score = at(dist(i, j-1)) distMatrix(i, j-1).score + GAP_PENALTY;
                        } else if(j==0) {
                            node.score = at(dist(i-1, j)) distMatrix(i-1, j).score + GAP_PENALTY;
                        } else {
                            var v1:Int = at(dist(i-1, j-1)) distMatrix(i-1, j-1).score;
                            v1 += str1.charAt(i as Int)==str2.charAt(j as Int) ? MATCH_SCORE : DISMATCH_SCORE;
                            var v2:Int = at(dist(i-1, j)) distMatrix(i-1, j).score + GAP_PENALTY;
                            var v3:Int = at(dist(i, j-1)) distMatrix(i, j-1).score + GAP_PENALTY;
                            node.score = Math.max(v1, Math.max(v2, v3));
                        }


                        // set the finish flag and increment the count
                        node.isFinish = true;
                        finishCount++;

                        // decrement the indegree of dependent nodes
                        if (i==M-1 && j==N-1) {
                            break;
                        } else if (i==M-1) {
                            at(dist(i, j+1)) distMatrix(i, j+1).indegree.decrementAndGet();
                        } else if (j==N-1) {
                            at(dist(i+1, j)) distMatrix(i+1, j).indegree.decrementAndGet();
                        } else  {
                            at(dist(i, j+1)) distMatrix(i, j+1).indegree.decrementAndGet();
                            at(dist(i+1, j)) distMatrix(i+1, j).indegree.decrementAndGet();
                            at(dist(i+1, j+1)) distMatrix(i+1, j+1).indegree.decrementAndGet();
                        }

                        //Console.OUT.println("work "+i+","+j+", finishCount:"+finishCount+" "+here);
                    }
                }

                // local task finished
                if (finishCount == allNodeCount)
                    break;
            }
        }

        printMatrix(dist, distMatrix);
        walkback(dist, distMatrix);
    }

    private def walkback(dist:Dist, distMatrix:DistArray[SWNode]) {
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
            val left = at(dist(tmpi-1, tmpj)) distMatrix(tmpi-1, tmpj).score;
            val up = at(dist(tmpi, tmpj-1)) distMatrix(tmpi, tmpj-1).score;
            val leftup = at(dist(tmpi-1, tmpj-1)) distMatrix(tmpi-1, tmpj-1).score;

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

    private def printMatrix(dist:Dist, distMatrix:DistArray[SWNode]) {
        val M = str1.length();
        val N = str2.length();

        for(var i:Long=0;i<M;i++) {
            for (var j:Long=0; j<N; j++) {
                val tmpi = i, tmpj = j;
            	val score = at(dist(tmpi, tmpj)) distMatrix(tmpi, tmpj).score;
                Console.OUT.print(score+" ");
            }
            Console.OUT.println();
        }
    }


    public static def main(args:Rail[String]) {
        new SmithWaterman2().sw();
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

}