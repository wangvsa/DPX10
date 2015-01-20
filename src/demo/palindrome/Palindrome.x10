package demo.palindrome;

import tada.*;
import tada.Tada.*;
import tada.dag.*;
import x10.util.Random;


/**
 * Longest Palindrome Substring
 */
public class Palindrome extends TadaAppDP[Int] {

    private val seq:String;

    public def this(length:Int) {
        val ALL_CHAR = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];
        val rand = new Random();
        val chars = new Rail[Char](length);
        for(var i:Int=0n;i<length;i++) {
            chars(i) = ALL_CHAR(rand.nextLong(ALL_CHAR.size));
        }
        this.seq = new String(chars);

        Console.OUT.println("string:"+this.seq);
    }

    public def compute(i:Int, j:Int, vertices:Rail[Vertex[Int]]):Int {
        if(i>=j)
            return 1n;

        var left:Int = 0n, leftbottom:Int = 0n, bottom:Int=0n;

        for(vertex in vertices) {
            if(vertex.i==i+1n && vertex.j==j-1n)
                leftbottom = vertex.getResult();
            if(vertex.i==i && vertex.j==j-1n)
                left = vertex.getResult();
            if(vertex.i==i+1n && vertex.j==j)
                bottom = vertex.getResult();
        }

        if(seq.charAt(i) == seq.charAt(j)) {
            if(j==i+1n)
                return 2n;
            return leftbottom + 2n;
        }

        return Math.max(left, bottom);
    }

    public def taskFinished(dag:Dag[Int]):void {
        val length = this.seq.length() as Int;
        Console.OUT.println("Longset Palindrome Substring:"+dag.getVertex(0n, length-1n).getResult());
    }

}