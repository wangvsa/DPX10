import x10.array.Array_2;
import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;
import x10.util.concurrent.AtomicInteger;


/**
 * Distributed version of 01 Knapsack problem only using X10
 */
public class Knapsack2 {

    public static val CAPICITY = 40n;    // knapsack capacity
    public static val ITEM_NUM = 6n;     // number of items

    public static val profit = [3n, 4n, 6n, 10n, 2n, 1n];
    public static val weight = [3n, 6n, 9n, 20n, 5n, 2n];

    private def knap() {
        // TODO distributed version
        // ...
        val region = Region.make(0..ITEM_NUM, 0..CAPICITY);
        val dist = Dist.makeBlock(region, 1);
        val distMatrix = DistArray.make[Int](dist, 0n);
        Place.places().broadcastFlat(()=>{
            val it = distMatrix.getLocalPortion().iterator();
            while(it.hasNext()) {
                val point:Point = it.next();
                val i = point(0), j = point(1);
                if(i==0 || j==0) {
                    distMatrix(point) = 0n;
                } else {
                    val v1 = at(dist(i-1,j)) distMatrix(i-1, j);
                    if( this.weight(i-1) <= j ) {
                        val v2 = at(dist(i-1, j-this.weight(i-1))) distMatrix(i-1, j-this.weight(i-1));
                        distMatrix(point) = Math.max(v1, v2);
                    } else {
                        distMatrix(point) = v1;
                    }
                }
            }
        });

        printMatrix(dist, distMatrix);
        val sum = at (dist(ITEM_NUM, CAPICITY)) distMatrix(ITEM_NUM, CAPICITY);
        Console.OUT.println("sum: "+sum);
    }


    private def printMatrix(dist:Dist, distMatrix:DistArray[Int]) {

        for(var i:Long=0;i<ITEM_NUM;i++) {
            for (var j:Long=0; j<CAPICITY; j++) {
                val tmpi = i, tmpj = j;
                val score = at(dist(tmpi, tmpj)) distMatrix(tmpi, tmpj);
                Console.OUT.print(score+" ");
            }
            Console.OUT.println();
        }
    }


    public static def main(args:Rail[String]) {
        new Knapsack2().knap();
    }

}