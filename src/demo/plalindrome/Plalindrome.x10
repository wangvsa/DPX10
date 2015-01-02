package demo.plalindrome;

import tada.*;
import tada.Tada.*;
import tada.dag.*;
import x10.util.Random;

public class Plalindrome extends TadaAppDP[Int] {

    private val seq:String;

    public def this(length:Int) {
        val ALL_CHAR = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];
        val rand = new Random();
        val chars = new Rail[Char](length);
        for(var i:Int=0n;i<length;i++) {
            chars(i) = ALL_CHAR(rand.nextLong(ALL_CHAR.size));
        }

        this.seq = new String(chars);
    }

    public def compute(i:Int, j:Int, vertices:Rail[Vertex[Int]]):Int {
        if(i>=j)
            return 0n;

        var left:Int = 0n, leftbottom:Int = 0n, bottom:Int=0n;

        for(vertex in vertices) {
            if(vertex.i==i+1n && vertex.j==j-1n)
                leftbottom = vertex.getResult();
            if(vertex.i==i && vertex.j==j-1n)
                left = vertex.getResult() + 1n;
            if(vertex.i==i+1n && vertex.j==j)
                bottom = vertex.getResult() + 1n;
        }

        if(seq.charAt(i) == seq.charAt(j))
            return leftbottom;
        return Math.max(left, bottom);
    }

    public def taskFinished(dag:Dag[Int]):void {
    }

}