import x10.array.Array_2;
import x10.util.Random;

public class Knapsack {

    public static val CAPICITY = 40n;    // knapsack capility
    public static val ITEM_NUM = 6n;     // number of items

    public static val profit = [3n, 4n, 6n, 10n, 2n, 1n];
    public static val weight = [3n, 6n, 9n, 20n, 5n, 2n];

    private def knap() {
        val matrix = new Array_2[Int](ITEM_NUM+1, CAPICITY+1, 0n);

        // row 1..n-1
        for (var i:Long=1; i<=ITEM_NUM; i++) {
            for (var j:Long=1; j<=CAPICITY; j++) {
                if( this.weight(i-1) <= j )
                    matrix(i, j) = Math.max( matrix(i-1, j), matrix(i-1, j-weight(i-1))+this.profit(i-1) );
                else
                    matrix(i, j) = matrix(i-1, j);
            }
        }

        printMatrix(matrix);
        Console.OUT.println("sum: "+matrix(ITEM_NUM, CAPICITY));
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