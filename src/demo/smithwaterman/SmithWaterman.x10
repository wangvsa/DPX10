package demo.smithwaterman;

import x10.io.File;
import x10.io.IOException;
import tada.*;
import tada.dag.*;
import tada.Tada.*;

public class SmithWaterman extends TadaAppDP[Int] {

	public var str1:String;
	public var str2:String;

	static val MATCH_SCORE = 2n;
	static val DISMATCH_SCORE = -1n;
	static val GAP_PENALTY = -1n;		// use linear gap penalty

	public def this() {
		str1 = new String();
		str2 = new String();
		try {
			val input1 = new File("demo/smithwaterman/SW_STR1.txt");
			for(line in input1.lines())
				str1 += line;
			val input2 = new File("demo/smithwaterman/SW_STR2.txt");
			for(line in input2.lines())
				str2 += line;
		} catch(IOException) {}
		Console.OUT.println("str1.length:"+str1.length()+", str2.length:"+str2.length());
	}

	public def compute(i:Int, j:Int, tasks:Rail[Task[Int]]):Int {

		if(i==0n && j==0n)
			return str1.charAt(0n)==str2.charAt(0n) ? MATCH_SCORE : DISMATCH_SCORE;
		var v1:Int=0n; var v2:Int=DISMATCH_SCORE, v3:Int=DISMATCH_SCORE;

		for(k in 0..(tasks.size-1)) {
			val loc = tasks(k)._loc;
			val score = tasks(k).getResult();
			if(loc.i==i-1n && loc.j==j-1n) {
				val c1 = str1.charAt(i as Int);
				val c2 = str2.charAt(j as Int);
				if(c1==c2)
					v1 = score + MATCH_SCORE;
				else
					v1 = score + DISMATCH_SCORE;
			}
			if(loc.j==j && loc.i==i-1n)
				v2 = score + GAP_PENALTY;
			if(loc.i==i && loc.j==j-1n)
				v3 = score + GAP_PENALTY;
		}

		//System.sleep(200);
		if(tasks.size==1)		// first row or first column
			return Math.max(v2, v3);
		return Math.max(v1, Math.max(v2, v3));
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

			val left = dag.getNode(i-1n, j).getResult();
			val up = dag.getNode(i, j-1n).getResult();
			val leftup = dag.getNode(i-1n, j-1n).getResult();
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
