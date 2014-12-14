import x10.array.Array_2;
import x10.util.Random;

public class Knapsack {

    static val CAPICITY = 40;       // knapsack capility
    static val ITEM_NUM = 6;       // number of items

    private val profit:Rail[Int];
    private val weight:Rail[Int];

    public def this() {
        this.profit = [3n, 4n, 6n, 10n, 2n, 1n];
        this.weight = [3n, 6n, 9n, 20n, 5n, 2n];
    }


    private def knap() {
        val matrix = new Array_2[Int](ITEM_NUM, CAPICITY, 0n);

        // first row
        for (var j:Long=0; j<CAPICITY; j++) {
            matrix(0, j) = this.profit(0);
        }

        // row 1..n-1
        for (var i:Long=1; i<ITEM_NUM; i++) {
            for (var j:Long=0; j<CAPICITY; j++) {
                if( j - this.weight(i) < 0 )
                    matrix(i, j) = matrix(i-1, j);
                else
                    matrix(i, j) = Math.max( matrix(i-1, j), matrix(i-1, j-weight(i))+this.profit(i) );
            }
        }

        printMatrix(matrix);
        Console.OUT.println("sum: "+matrix(ITEM_NUM-1, CAPICITY-1));
    }

    private def printMatrix(matrix:Array_2[Int]) {
        Console.OUT.println("matrix:");
        for (var i:Long=0; i<matrix.numElems_1; i++) {
            for (var j:Long=0; j<matrix.numElems_2; j++) {
                Console.OUT.print(matrix(i, j)+" ");
            }
            Console.OUT.println();
        }
    }

    public static def main(args:Rail[String]) {
        new Knapsack().knap();
    }

}