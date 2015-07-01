package demo.smithwaterman;

import dpx10.*;
import dpx10.dag.*;
import dpx10.DPX10.*;

public class SmithWaterman extends DPX10AppDP[Int] {

	public var str1:String;
	public var str2:String;

	static val MATCH_SCORE = 2n;
	static val DISMATCH_SCORE = -1n;
	static val GAP_PENALTY = -1n;		// use linear gap penalty

	public def this(str1:String, str2:String) {
		this.str1 = str1;
		this.str2 = str2;
	}

	public def compute(i:Int, j:Int, vertices:Rail[Vertex[Int]]):Int {

		// compute the score
        if(i==0n && j==0n) {
            return str1.charAt(i)==str2.charAt(j) ? MATCH_SCORE : DISMATCH_SCORE;
        } else if(i==0n || j==0n) {
            return vertices(0).getResult() + GAP_PENALTY;
        } else {
        	var lefttop:Int = 0n, left:Int = 0n, top:Int = 0n;
        	for(vertex in vertices) {
				if(vertex.i==i-1n && vertex.j==j-1n)
					lefttop = vertex.getResult();
				else if(vertex.i==i-1n && vertex.j==j)
					top = vertex.getResult();
				else if(vertex.i==i && vertex.j==j-1n)
					left = vertex.getResult();
			}
            val v1 = lefttop + (str1.charAt(i)==str2.charAt(j) ? MATCH_SCORE : DISMATCH_SCORE);
            val v2 = left + GAP_PENALTY;
            val v3 = top + GAP_PENALTY;

            return Math.max(v1, Math.max(v2, v3));
        }

		// using for kill, when test fault-tolerance
		// System.sleep(200);
	}

	public def taskFinished(dag:Dag[Int]):void {
		Console.OUT.println("\nTask finished, result:");
		walkback(dag);
		Console.OUT.println("\n");
	}

	private def walkback(dag:Dag[Int]) {
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

			val left = dag.getVertex(i-1n, j).getResult();
			val up = dag.getVertex(i, j-1n).getResult();
			val leftup = dag.getVertex(i-1n, j-1n).getResult();
			if(left >= up && left >= leftup) {
				i = i - 1n;
			} else if(up >= left && up >= leftup) {
				j = j - 1n;
			} else {
				i = i - 1n;
				j = j - 1n;
			}

		}
	}

}
