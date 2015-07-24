import x10.array.Array_2;

/**
 * This is used for comparision with DPX10
 * This is the serial version of Longest Palindrome Subsequence algorithm written using X10 directly
 */
public class Palindrome {

    public var str : String;

    public def this() {
        str = "abcfgbda";
    }

    private def max(v1:Int , v2:Int) {
        return v1 >= v2 ? v1 : v2;
    }

    private def lps() {

        val len = str.length();
        val matrix = new Array_2[Int](len, len, 0n);


        for (var i:Long=len-1; i>=0; i--) {
            matrix(i, i) = 1n;
            for(var j:Long=i+1;j<len;j++) {
                if(str.charAt(i as Int) == str.charAt(j as Int))
                    matrix(i, j) = matrix(i+1, j-1) + 2n;
                else
                    matrix(i, j) = max(matrix(i, j-1), matrix(i+1, j));
            }
        }

        Console.OUT.println("Longest Palindrome Subsequence: "+matrix(0, len-1));

        // Here code be the backtrack code...
    }


    public static def main(args:Rail[String]) {
        var time:Long = -System.currentTimeMillis();
        new Palindrome().lps();
        time += System.currentTimeMillis();
        Console.OUT.println("spend time:"+time+"ms");
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

}