import x10.io.File;
import x10.io.IOException;
import x10.array.Array_2;
import x10.util.Random;

/**
 * This is used for comparision with DPX10
 * This is the serial version of SmithWaterman algorithm written using X10 directly
 */
public class SmithWaterman {

    public var str1:String;
    public var str2:String;

    // same parameters with DPX10's demo
    static val MATCH_SCORE = 2n;
    static val DISMATCH_SCORE = -1n;
    static val GAP_PENALTY = -1n;       // use linear gap penalty

    // read the same string from DPX10's demo
    public def this(str1_length:Int, str2_length:Int) {
        str1 = generateRandomString(str1_length);
        str2 = generateRandomString(str2_length);
    }

    private def sw() {
        val M = str1.length();
        val N = str2.length();

        // score matrix, init with zero
        val matrix = new Array_2[Int](M, N, 0n);

        for (var i:Long=0; i<M; i++) {
            for (var j:Long=0; j<N; j++) {
                // compute the score
                if(i==0 && j==0) {
                    matrix(i, j) = str1.charAt(i as Int)==str2.charAt(j as Int) ? MATCH_SCORE : DISMATCH_SCORE;
                } else if(i==0) {
                    matrix(i, j) = matrix(i, j-1) + GAP_PENALTY;
                } else if(j==0) {
                    matrix(i, j) = matrix(i-1, j) + GAP_PENALTY;
                } else {
                    var v1:Int = matrix(i-1, j-1);
                    v1 += str1.charAt(i as Int)==str2.charAt(j as Int) ? MATCH_SCORE : DISMATCH_SCORE;
                    var v2:Int = matrix(i-1, j) + GAP_PENALTY;
                    var v3:Int = matrix(i, j-1) + GAP_PENALTY;
                    matrix(i, j) = Math.max(v1, Math.max(v2, v3));
                }
            }
        }

        //printMatrix(matrix);
        //walkback(matrix);
    }


    public static def main(args:Rail[String]) {
        var len1:Int = 20n;
        var len2:Int = 20n;
        if(args.size==2) {
            len1 = Int.parseInt(args(1));
            len2 = Int.parseInt(args(1));
        }
        var time:Long = -System.currentTimeMillis();
        new SmithWaterman(len1, len2).sw();
        time += System.currentTimeMillis();
        Console.OUT.println("spend time:"+time+"ms");
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
        for (var i:Long=0; i<matrix.numElems_1; i++) {
            for (var j:Long=0; j<matrix.numElems_2; j++) {
                Console.OUT.print(matrix(i, j)+" ");
            }
            Console.OUT.println();
        }
    }

    /**
     * Generate a string with given length
     */
    private def generateRandomString(length:Int) {
        val all_chars = ['A', 'C', 'T', 'G', 'U'];

        val rand = new Random();
        val str_chars = new Rail[Char](length);
        for(var i:Int=0n;i<length;i++) {
            str_chars(i) = all_chars(rand.nextLong(all_chars.size));
        }

        return new String(str_chars);
    }

}