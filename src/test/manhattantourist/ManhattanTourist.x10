import x10.array.Array_2;
import x10.util.Random;

/**
 * This is used for comparision with DPX10
 * This is the serial version of Mahattan Tourist Problem written using X10 directly
 */
public class ManhattanTourist {

    private val height:Int, width:Int;
    private row_dis : Array_2[Int];
    private col_dis : Array_2[Int];

    public def this(height:Int, width:Int) {
        this.height = width;
        this.width = width;
        val rand = new Random();
        this.row_dis = new Array_2[Int](height, width, (i:Long,j:Long)=>{return rand.nextInt(10n);} );
        this.col_dis = new Array_2[Int](height, width, (i:Long,j:Long)=>{return rand.nextInt(10n);} );
    }


    private def manhattan() {
        val matrix = new Array_2[Int](height, width, 0n);

        for (var i:Long=1; i<height; i++) {
            for(var j:Long=1;j<width;j++) {
                val v1 = matrix(i, j-1) + row_dis(i, j-1);
                val v2 = matrix(i-1, j) + col_dis(i-1, j);
                matrix(i, j) = Math.max(v1, v2);
            }
        }

        Console.OUT.println("Manhattan Tourist: "+matrix(height-1, width-1));
    }


    public static def main(args:Rail[String]) {
        var time:Long = -System.currentTimeMillis();
        new ManhattanTourist(10n, 10n).manhattan();
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