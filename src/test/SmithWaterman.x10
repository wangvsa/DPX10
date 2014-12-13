import x10.io.File;
import x10.io.IOException;
import x10.array.Array_2;


/**
 * This is used for comparision
 * This is a SW implementation using only X10
 */
public class SmithWaterman {

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

        // score matrix, init with zero
        val matrix = new Array_2[Int](M+1, N+1, 0n);

        var v1:Int=0n, v2:Int=0n, v3:Int=0n;
        for (var i:Long=1; i<=M; i++) {
            for (var j:Long=1; j<=N; j++) {
                val c1 = str1.charAt((i-1) as Int);
                val c2 = str2.charAt((j-1) as Int);
                if(c1==c2)
                    v1 = matrix(i-1, j-1) + MATCH_SCORE;
                else
                    v1 = matrix(i-1, j-1) + DISMATCH_SCORE;
                v2 = matrix(i-1, j) + GAP_PENALTY;
                v3 = matrix(i, j-1) + GAP_PENALTY;
                matrix(i, j) = Math.max(v1, Math.max(v2, v3));
            }
        }

        printMatrix(matrix);
        walkback(matrix);
    }

    private def walkback(matrix:Array_2[Int]) {
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

            val left = matrix(i-1, j);
            val up = matrix(i, j-1);
            val leftup = matrix(i-1, j-1);

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

    private def printMatrix(matrix:Array_2[Int]) {
        Console.OUT.println("matrix:");
        for (var i:Long=1; i<matrix.numElems_1; i++) {
            for (var j:Long=1; j<matrix.numElems_2; j++) {
                Console.OUT.print(matrix(i, j)+" ");
            }
            Console.OUT.println();
        }
    }



    public static def main(args:Rail[String]) {
        new SmithWaterman().sw();
    }

}