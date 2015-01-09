package demo.manhattantourist;

import tada.*;
import tada.Tada.*;
import tada.dag.*;
import x10.util.Random;
import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;

/**
 * The Manhattan Tourist Problem
 * See http://bix.ucsd.edu/bioalgorithms/book/excerpt-ch6.pdf
 * Use Dag24
 *
 */
public class ManhattanTourist extends TadaAppDP[Int] {

    // use two 2d DistArray to represent the Manhattan distances
    // better to distribute them as the DAG vertices
    private row_dis : DistArray[Int];
    private col_dis : DistArray[Int];

    public def this(height:Int, width:Int) {

        val region = Region.make(0..(height-1n), 0..(width-1n));
        val dist = Dist.makeBlock(region, 1);
        val rand = new Random();
        this.row_dis = DistArray.make[Int](dist, (p:Point)=>{return rand.nextInt(10n);} );
        this.col_dis = DistArray.make[Int](dist, (p:Point)=>{return rand.nextInt(10n);} );
    }


    public def compute(i:Int, j:Int, vertices:Rail[Vertex[Int]]):Int {
        if(i==0n && j==0n)
            return 0n;

        var v1:Int = 0n, v2:Int = 0n;
        for(vertex in vertices) {
            if(vertex.i==i) {
                val tmpi = vertex.i, tmpj = vertex.j;
                val p = row_dis.dist(tmpi, tmpj);
                v1 = vertex.getResult();
                if(p==here)
                    v1 += row_dis(tmpi, tmpj);
                else {
                    v1 += at(p) row_dis(tmpi, tmpj);
                }
            }
            if(vertex.j==j) {
                val tmpi = vertex.i, tmpj = vertex.j;
                val p = col_dis.dist(tmpi, tmpj);
                v2 = vertex.getResult();
                if(p==here)
                    v2 += col_dis(tmpi, tmpj);
                else {
                    v2 += at(p) col_dis(tmpi, tmpj);
                }
            }
        }

        return Math.max(v1, v2);
    }

    public def taskFinished(dag:Dag[Int]):void {
    }

}