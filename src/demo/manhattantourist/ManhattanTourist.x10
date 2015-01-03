package demo.manhattantourist;

import tada.*;
import tada.Tada.*;
import tada.dag.*;
import x10.util.Random;
import x10.array.Array_2;


/**
 * The Manhattan Tourist Problem
 * See http://bix.ucsd.edu/bioalgorithms/book/excerpt-ch6.pdf
 * Use Dag24
 *
 */
public class ManhattanTourist extends TadaAppDP[Int] {

    // use 2 2d array to represent the Manhattan
    private row_dis : Array_2[Int];
    private col_dis : Array_2[Int];

    public def this(height:Int, width:Int) {
        this.row_dis = new Array_2[Int](height, width-1);
        this.col_dis = new Array_2[Int](height-1, width);

        val rand = new Random();
        for(var i:Int=0n;i<height;i++) {
            for(var j:Int=0n;j<width-1n;j++) {
                this.row_dis(i,j) = rand.nextInt(20n);
            }
        }
        for(var i:Int=0n;i<height-1n;i++) {
            for(var j:Int=0n;j<width;j++) {
                this.col_dis(i,j) = rand.nextInt(20n);
            }
        }
    }

    public def compute(i:Int, j:Int, vertices:Rail[Vertex[Int]]):Int {
        if(i==0n && j==0n)
            return 0n;

        var v1:Int = 0n, v2:Int = 0n;
        for(vertex in vertices) {
            if(vertex.i==i)
                v1 = vertex.getResult() + row_dis(vertex.i, vertex.j);
            if(vertex.j==j)
                v2 = vertex.getResult() + col_dis(vertex.i, vertex.j);
        }
        return Math.max(v1, v2);
    }

    public def taskFinished(dag:Dag[Int]):void {
    }
}