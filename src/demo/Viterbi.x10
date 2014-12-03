package demo;

import x10.array.Array_2;
import tada.*;
import tada.Tada.*;
import tada.dag.*;

public class Viterbi extends TadaAppDP[Double] {


	// 观察空间
	public static val OBSERVATION_NUM = 3n;
	public static val OBSERVATIONS = ["normal", "cold", "dizzy"];
	// 状态空间
	public static val STATUS_NUM = 2n;
	public static val STATUS = ["Healthy", "Fever"];
	// 状态转移矩阵
	public val TRANSITION_MATIRX:Array_2[Double];
	// 发射矩阵
	public val EMISSION_MATRIX:Array_2[Double];
	// 初始概率
	public static val START_PROBABILITY = [0.6, 0.4];

	// 实际观测到的矩阵(用于测试)
	public static val TIME_NUM = 4n;
	public static val realObservations = ["normal", "cold", "dizzy", "dizzy"];


	public def this() {
		// 初始化常量
		TRANSITION_MATIRX = new Array_2[Double](STATUS_NUM, STATUS_NUM);
		EMISSION_MATRIX = new Array_2[Double](STATUS_NUM, OBSERVATION_NUM);

		TRANSITION_MATIRX(0, 0) = 0.7;	// healty->healty
		TRANSITION_MATIRX(0, 1) = 0.3;	// healty->fever
		TRANSITION_MATIRX(1, 0) = 0.4;	// fever->fever
		TRANSITION_MATIRX(0, 1) = 0.6;	// fever->healty

		EMISSION_MATRIX(0, 0) = 0.5;		// healty->normal
		EMISSION_MATRIX(0, 1) = 0.4;		// healty->cold
		EMISSION_MATRIX(0, 2) = 0.1;		// healty->dizzy
		EMISSION_MATRIX(1, 0) = 0.1;		// fever->normal
		EMISSION_MATRIX(1, 1) = 0.3;		// fever->cold
		EMISSION_MATRIX(1, 2) = 0.6;		// fever->dizzy
	}

	// 在维特比算法中，i代表时间；j代表状态
	public def compute(i:Int, j:Int, tasks:Rail[Task[Double]]):Double {

		// 获取当前观测状态(下标)
		var obsIndex:Long = 0;
		for(var k:Long=0; k<OBSERVATIONS.size; k++) {
			if(OBSERVATIONS(k)==this.realObservations(i))
				obsIndex = i;
		}

		var res:Double = 0.0;
		// 初始化(第一行)
		if(i == 0n) {
			res = START_PROBABILITY(i) * EMISSION_MATRIX(i, obsIndex);
		}

		// 递归计算
		if(i >= 1n) {
			// 计算最大概率
			for(var k:Int=0n; k<tasks.size; k++) {
				val loc = tasks(k)._loc;
				if(loc.i==i-1n) {
					val tmp = TRANSITION_MATIRX(loc.j, j) * tasks(k).getResult() * EMISSION_MATRIX(j, obsIndex);
					if(tmp > res)
						res = tmp;
				}
			}
		}

		return res;
	}


	public def taskFinished(dag:Dag[Double]) {
		/*
		// 回溯
		String str;
		val stuff = new ViterbiStuff();

		// 先找到最后一步的状态
		var tmp:Double = 0.0;
		var index:Int = 0n;
		for(var j:Int=0n;j<STATUS_NUM;j++) {
			if(dag.result(TIME_NUM-1n, j)>tmp) {
				tmp = dag.result(TIME_NUM-1n, j);
				index = j;
			}
		}
		str = stuff.status(j);

		if(TIME_NUM<2) {
			Console.OUT.println("status:"+str);
			return;
		}
		*/

	}

}
