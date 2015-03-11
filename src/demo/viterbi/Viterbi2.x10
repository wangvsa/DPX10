package demo.viterbi;

import dpx10.*;
import dpx10.DPX10.*;
import dpx10.dag.*;
import x10.util.Random;
import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;

public class Viterbi2 extends DPX10AppDP[Double] {

	// 观察空间
	public val observation_num:Int;
	public val observations:Rail[Int];

	// 状态空间
	public val status_num:Int;
	public val status:Rail[Int];

	// 状态转移矩阵
	// distribute them as vertices of DAG
	public val transition_matrix:DistArray[Double];
	// 发射矩阵
	public val emmission_matrix:DistArray[Double];
	// 初始概率
	public val start_probability:Rail[Double];

	// 实际观测到的矩阵(用于测试)
	public val real_observation_num:Int;
	public val realObservations:Rail[Int];

	public def this(status_num:Int, observation_num:Int, real_observation_num:Int) {
		this.observation_num = observation_num;
		this.observations = new Rail[Int](observation_num, (i:Long)=>{return i as Int;});

		this.status_num = status_num;
		this.status = new Rail[Int](status_num, (i:Long)=>{return i as Int;});

		// 初始化常量
        val rand = new Random();

		val region1 = Region.make(0..(status_num-1n), 0..(status_num-1n));
        val dist1 = Dist.makeBlock(region1, 1);
        this.transition_matrix = DistArray.make[Double](dist1, (p:Point)=>{return 2*rand.nextDouble()/status_num;} );

		val region2 = Region.make(0..(status_num-1n), 0..(observation_num-1n));
		val dist2 = Dist.makeBlock(region2, 1);
		this.emmission_matrix = DistArray.make[Double](dist2, (p:Point)=>{return 2*rand.nextDouble()/status_num;} );

		start_probability = new Rail[Double](status_num, (i:Long)=>{return 2*rand.nextDouble()/status_num;} );


		// Generate random observation sequence
		this.real_observation_num = real_observation_num;
		this.realObservations = new Rail[Int](real_observation_num, (i:Long)=>rand.nextInt(observation_num));
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
		if(i == 0n)
			res = start_probability(i) * getEmmissionProbability(i, obsIndex as Int);

		// 递归计算
		if(i >= 1n) {
			// 计算最大概率
			for(vertex in vertices) {
				if(vertex.i==i-1n) {
					val tmp = getTransitionProbability(vertex.j, j) * vertex.getResult() * getEmmissionProbability(j, obsIndex as Int);
					if(tmp > res)
						res = tmp;
				}
			}
		}

		return res;
	}

	private def getEmmissionProbability(i:Int, j:Int) {
		val place = this.emmission_matrix.dist(i, j);
		if(place==here)
			return emmission_matrix(i, j);
		else
			return at(place) emmission_matrix(i, j);
	}
	private def getTransitionProbability(i:Int, j:Int) {
		val place = this.transition_matrix.dist(i, j);
		if(place==here)
			return transition_matrix(i, j);
		else
			return at(place) transition_matrix(i, j);
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
