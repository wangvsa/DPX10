package demo.nussinov;

import tada.*;
import tada.Tada.*;
import tada.dag.*;
import x10.util.Random;


/**
 * Nussinov-Jacobson algorithm
 * See http://ultrastudio.org/en/Nussinov_algorithm
 *
 */

public class Nussinov extends TadaAppDP[Int] {

    public val length:Int;
    private val seq:String;

    public def this(length:Int) {
        this.length = length;

        val ALL_CHAR = ['A', 'T', 'C', 'G', 'U'];
        val chars = new Rail[Char](length);
        val rand = new Random();
        for(var i:Int=0n;i<length;i++) {
            chars(i) = ALL_CHAR(rand.nextInt(5n));
        }
        this.seq = new String(chars);
    }

    public def compute(i:Int, j:Int, tasks:Rail[Task[Int]]):Int {
        if(i>=j)
            return 0n;

        var v1:Int = 0n, v2:Int = 0n;
        val values = new Rail[Int](j-i, 0n);
        for (task in tasks) {
            val loc = task._loc;
            if(loc.i==i+1n && loc.j==j-1n)
                v1 = task.getResult() + (isComplementary(i,j)? 1n:0n);
            else {
                if(loc.i==i)
                    values(loc.j-i) += task.getResult();
                if(loc.j==j)
                    values(loc.i-i-1) += task.getResult();
            }
        }

        var max:Int = v1;
        for(v in values)
            if(v > max)
                max = v;

        return max;
    }

    public def taskFinished(dag:Dag[Int]):void {
    }

    private def isComplementary(i:Int, j:Int):Boolean {
        val a:Char = seq.charAt(i);
        val b:Char = seq.charAt(j);
        if((a=='A'&&b=='T') || (a=='T'&&b=='A') || (a=='C'&&b=='G') || (a=='G'||b=='C') )
            return true;
        return false;
    }

}