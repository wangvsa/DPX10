package demo;

import x10.io.File;
import x10.io.IOException;
import dpx10.*;
import dpx10.DPX10.*;
import dpx10.dag.*;


public class LCS extends DPX10AppDP[Int] {

	public var str1:String;
	public var str2:String;

	public def this() {
		str1 = new String();
		str2 = new String();
		try {
			val input1 = new File("demo/lcs/LCS_STR1.txt");
			for(line in input1.lines())
				str1 += line;
			val input2 = new File("demo/lcs/LCS_STR2.txt");
			for(line in input2.lines())
				str2 += line;
		} catch(IOException) {}
		Console.OUT.println("str1.length:"+str1.length()+", str2.length:"+str2.length());
	}

	public def compute(i:Int, j:Int, vertices:Rail[Vertex[Int]]):Int {
		var v1:Int=0n, v2:Int=0n, v3:Int=0n;
		for(vertex in vertices) {
			if(vertex.i==i-1n && vertex.j==j-1n) {
				v1 = vertex.getResult();			// up-left
			}
			else if(vertex.i==i-1n && vertex.j==j) {
				v2 = vertex.getResult();			// up
			}
			else if(vertex.i==i && vertex.j==j-1n) {
				v3 = vertex.getResult();			// left
			}
		}

		val c1 = str1.charAt(i as Int);
		val c2 = str2.charAt(j as Int);
		var result:Int;
		if(c1==c2)
			result = v1 + 1n;
		else
			result = Math.max(v2, v3);

		return result;
	}

	public def taskFinished(dag:Dag[Int]) {
		Console.OUT.print("the longest common string:");
		var i:Int = str1.length() as Int - 1n;
		var j:Int = str2.length() as Int - 1n;
		while(true) {
			if(i==-1n||j==-1n) break;
			val c1 = str1.charAt(i);
			val c2 = str2.charAt(j);
			if(c1==c2) {
				Console.OUT.print(c1);
				i = i - 1n;
				j = j - 1n;
			} else {
				if(i==0n||j==0n) break;
				val left = dag.getVertex(i-1n, j).getResult();
				val up = dag.getVertex(i, j-1n).getResult();
				if(left >= up)
					i = i - 1n;
				else
					j = j - 1n;
			}
		}
		Console.OUT.println();
	}

}
