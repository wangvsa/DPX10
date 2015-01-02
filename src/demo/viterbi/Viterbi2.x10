package demo.viterbi;

import x10.array.Array_2;
import tada.*;
import tada.Tada.*;
import tada.dag.*;
import x10.util.Random;

public class Viterbi2 extends TadaAppDP[Double] {

	// 观察空间
	public val observation_num:Int;
	public val observations:Rail[Int];

	// 状态空间
	public val status_num:Int;
	public val status:Rail[Int];

	// 状态转移矩阵
	public val TRANSITION_MATIRX:Array_2[Double];
	// 发射矩阵
	public val EMISSION_MATRIX:Array_2[Double];
	// 初始概率
	public val START_PROBABILITY:Rail[Double];

	// 实际观测到的矩阵(用于测试)
	public val real_observation_num:Int;
	public val realObservations:Rail[Int];

	public def this(status_num:Int, observation_num:Int, real_observation_num:Int) {
		this.observation_num = observation_num;
		this.observations = new Rail[Int](observation_num);
		for(var i:Int=0n;i<observation_num;i++)
			observations(i) = i;

		this.status_num = status_num;
		this.status = new Rail[Int](status_num);
		for(var i:Int=0n;i<status_num;i++)
			status(i) = i;

		// 初始化常量
		TRANSITION_MATIRX = new Array_2[Double](status_num, status_num);
		val rand = new Random();
		var rest:Double = 1;
		for(var i:Long=0;i<status_num;i++) {
			for(var j:Long=0;j<status_num;j++) {
				if(i==status_num-1 && j==status_num-1) {
					TRANSITION_MATIRX(i, j) = rest;
					continue;
				}
				TRANSITION_MATIRX(i, j) = rand.nextDouble()/status_num;
				rest = rest - TRANSITION_MATIRX(i, j);
			}
		}
		EMISSION_MATRIX = new Array_2[Double](status_num, observation_num);
		for(var i:Long=0;i<status_num;i++) {
			rest = 1;
			for(var j:Long=0;j<observation_num;j++) {
				if(j==status_num-1) {
					EMISSION_MATRIX(i, j) = rest;
					continue;
				}
				EMISSION_MATRIX(i, j) = rand.nextDouble()/observation_num;
				rest = rest - EMISSION_MATRIX(i, j);
			}
		}
		START_PROBABILITY = new Rail[Double](status_num);
		rest = 1;
		for(var i:Long=0;i<status_num-1;i++) {
			START_PROBABILITY(i) = rand.nextDouble()/status_num;
			rest = rest - START_PROBABILITY(i);
		}
		START_PROBABILITY(status_num-1) = rest;


		// Generate random observation sequence
		this.real_observation_num = real_observation_num;
		this.realObservations = new Rail[Int](real_observation_num);
		for(var i:Long=0;i<real_observation_num;i++)
			this.realObservations(i) = rand.nextInt(this.observation_num);
	}


	// 在维特比算法中，i代表时间；j代表状态
	public def compute(i:Int, j:Int, vertices:Rail[Vertex[Double]]):Double {

		// 获取当前观测状态(下标)
		var obsIndex:Long = 0;
		for(var k:Long=0; k<this.observation_num; k++) {
			if(this.observations(k)==this.realObservations(i))
				obsIndex = k;
		}

		var res:Double = 0.0;
		// 初始化(第一行)
		if(i == 0n) {
			res = START_PROBABILITY(i) * EMISSION_MATRIX(i, obsIndex);
		}

		// 递归计算
		if(i >= 1n) {
			// 计算最大概率
			for(vertex in vertices) {
				if(vertex.i==i-1n) {
					val tmp = TRANSITION_MATIRX(vertex.j, j) * vertex.getResult() * EMISSION_MATRIX(j, obsIndex);
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
