import x10.util.*;
import tada.*;
import tada.dag.*;
import demo.*;
import demo.smithwaterman.*;
import demo.lcs.*;
import demo.knapsack.*;


public class Main {

	public static def main(args:Rail[String]) {

		val choose = args(0);
		if(choose.equals("lcs"))
			lcs();
		if(choose.equals("sw"))
			sw();
		if(choose.equals("viterbi"))
			viterbi();
		if(choose.equals("wc"))
			wordCount();
		if(choose.equals("knap"))
			knap();
	}

	private static def lcs() {
		val lcs = new LCS();
		val dag = new Dag124[Int](lcs.str1.length(), lcs.str2.length());
		val tada = new Tada[Int](lcs, dag);
		tada.start();
	}

	private static def sw() {
		val sw = new SmithWaterman();
		val dag = new Dag124[Int](sw.str1.length(), sw.str2.length());
		val tada = new Tada[Int](sw, dag);
		tada.start();
	}

	private static def viterbi() {
		val dag = new DagUpper[Double](Viterbi.TIME_NUM, Viterbi.STATUS_NUM);
		val tada= new Tada[Double](new Viterbi(), dag);
		tada.start();
	}

	private static def wordCount() {
		val dag = new DagJoin[HashMap[String, Int]](WordCount.articles.size as Int);
		val tada = new Tada[HashMap[String, Int]](new WordCount(), dag);
		tada.start();
	}

	private static def knap() {
		val dag = new KnapsackDag[Int](Knapsack.ITEM_NUM+1n, Knapsack.CAPICITY+1n);
		val tada = new Tada[Int](new Knapsack(), dag);
		tada.start();
	}

}
