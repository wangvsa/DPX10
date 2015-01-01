import x10.util.*;
import tada.*;
import tada.dag.*;
import demo.*;
import demo.smithwaterman.*;
import demo.nussinov.*;
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
			knap(args);
		if(choose.equals("nussinov"))
			nussinov(args);
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

	private static def knap(args:Rail[String]) {
		var item_num:Int = 20n;
		var capacity:Int = 1000n;
		if(args.size == 3) {
			item_num = Int.parseInt(args(1));
			capacity = Int.parseInt(args(2));
		}

		val knap = new Knapsack(item_num, capacity);
		val dag = new KnapsackDag[Int](knap);
		val tada = new Tada[Int](knap, dag);
		tada.start();
	}

	private static def nussinov(args:Rail[String]) {
		var length:Int = 20n;
		if(args.size == 2)
			length = Int.parseInt(args(1));
		val nus = new Nussinov(length);
		val dag = new NussinovDag[Int](nus);
		val tada = new Tada[Int](nus, dag);
		tada.start();
	}

}
