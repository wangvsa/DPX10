import x10.util.*;
import dpx10.*;
import dpx10.dag.*;
import dpx10.util.Util;
import demo.*;
import demo.smithwaterman.*;
import demo.nussinov.*;
import demo.lcs.*;
import demo.knapsack.*;
import demo.viterbi.*;
import demo.palindrome.*;
import demo.manhattantourist.*;


public class Main {

	public static def main(args:Rail[String]) {

		val config = new Configuration(args);
		val appArgs = removeConfig(args);

		val choose = args(0);
		if(choose.equals("lcs"))
			lcs(config);
		if(choose.equals("sw"))
			sw(appArgs, config);
		if(choose.equals("viterbi"))
			viterbi(config);
		if(choose.equals("viterbi2"))
			viterbi2(appArgs, config);
		if(choose.equals("wc"))
			wordCount(config);
		if(choose.equals("knap"))
			knap(appArgs, config);
		if(choose.equals("nussinov"))
			nussinov(appArgs, config);
		if(choose.equals("lps"))
			lps(appArgs, config);
		if(choose.equals("manhattan"))
			manhattan(appArgs, config);
	}

	private static def removeConfig(all_args:Rail[String]) {
		val args = new ArrayList[String]();
		for(arg in all_args) {
			if(!arg.startsWith("-"))
				args.add(arg);
		}
		return args.toRail();
	}

	private static def lcs(config:Configuration) {
		val lcs = new LCS();
		val dag = new Dag124[Int](lcs.str1.length(), lcs.str2.length(), config);
		val tada = new DPX10[Int](lcs, dag);
		tada.start();
	}

	private static def sw(args:Rail[String], config:Configuration) {
		var str1:String = "abcdefghij";
		var str2:String = "abcdefghij";
		if(args.size==3) {
			str1 = ""; str2 = "";
			// given paths or given lengths
			if(args(1).indexOf("/")!=-1n && args(2).indexOf("/")!=-1n) {
				str1 = FastaReader.read(args(1));
				str2 = FastaReader.read(args(2));
			} else {
				str1 = Util.generateRandomString(Int.parseInt(args(1)));
				str2 = Util.generateRandomString(Int.parseInt(args(2)));
			}
		}
		val sw = new SmithWaterman(str1, str2);
		val dag = new Dag124[Int](str1.length(), str2.length(), config);
		val tada = new DPX10[Int](sw, dag);
		tada.start();
	}

	private static def viterbi(config:Configuration) {
		val dag = new DagUpper[Double](Viterbi.TIME_NUM, Viterbi.STATUS_NUM, config);
		val tada= new DPX10[Double](new Viterbi(), dag);
		tada.start();
	}
	private static def viterbi2(args:Rail[String], config:Configuration) {
		var status_num:Int = 10n;
		var observation_num:Int = 20n;
		var real_observertaion_num:Int = 30n;
		if(args.size==4) {
			status_num = Int.parseInt(args(1));
			observation_num = Int.parseInt(args(2));
			real_observertaion_num = Int.parseInt(args(3));
		}
		val viterbi = new Viterbi2(status_num, observation_num, real_observertaion_num);
		val dag = new DagUpper[Double](real_observertaion_num, status_num, config);
		val tada= new DPX10[Double](viterbi, dag);
		tada.start();
	}

	private static def wordCount(config:Configuration) {
		val dag = new DagJoin[HashMap[String, Int]](WordCount.articles.size as Int, config);
		val tada = new DPX10[HashMap[String, Int]](new WordCount(), dag);
		tada.start();
	}

	private static def knap(args:Rail[String], config:Configuration) {
		var item_num:Int = 20n;
		var capacity:Int = 1000n;
		if(args.size == 3) {
			item_num = Int.parseInt(args(1));
			capacity = Int.parseInt(args(2));
		}

		val knap = new Knapsack(item_num, capacity);
		val dag = new KnapsackDag[Int](knap, config);
		val tada = new DPX10[Int](knap, dag);
		tada.start();
	}

	private static def nussinov(args:Rail[String], config:Configuration) {
		var length:Int = 20n;
		if(args.size == 2)
			length = Int.parseInt(args(1));
		val nus = new Nussinov(length);
		val dag = new NussinovDag[Int](nus, config);
		val tada = new DPX10[Int](nus, dag);
		tada.start();
	}

	private static def lps(args:Rail[String], config:Configuration) {
		var length:Int = 20n;
		if(args.size == 2)
			length = Int.parseInt(args(1));
		val app = new Palindrome(length);
		val dag = new Dag478[Int](length, length, config);
		val tada = new DPX10[Int](app, dag);
		tada.start();
	}

	private static def manhattan(args:Rail[String], config:Configuration) {
		var height:Int = 20n;
		var width:Int = 20n;
		if(args.size == 3) {
			height = Int.parseInt(args(1));
			width = Int.parseInt(args(2));
		}
		val app = new ManhattanTourist(height, width);
		val dag = new Dag24[Int](height, width, config);
		val tada = new DPX10[Int](app, dag);
		tada.start();

	}

}
