package tada.dag;

import tada.Configuration;

public class Dag124[T]{T haszero} extends Dag[T] {

	public def this(height:Int, width:Int, config:Configuration) {
		super(height, width, config);
	}

	public def getDependencies(i:Int, j:Int):Rail[VertexId] {
		val vids:Rail[VertexId];
		if(i==0n&& j==0n) {
			vids = new Rail[VertexId](0);
		} else if(i==0n|| j==0n) {
			vids = new Rail[VertexId](1);
			if(i==0n)
				vids(0) = new VertexId(i, j-1n);
			if(j==0n)
				vids(0) = new VertexId(i-1n, j);
		} else {
			vids = new Rail[VertexId](3);
			vids(0) = new VertexId(i-1n, j-1n);
			vids(1) = new VertexId(i, j-1n);
			vids(2) = new VertexId(i-1n, j);
		}

		return vids;
	}


	public def getAntiDependencies(i:Int, j:Int):Rail[VertexId] {
		val vids:Rail[VertexId];

		if(i==height-1n && j==width-1n) {
			vids = new Rail[VertexId](0);
		} else if(i==height-1n || j==width-1n) {
			vids = new Rail[VertexId](1);
			if(i==height-1n)
				vids(0) = new VertexId(i, j+1n);
			if(j==width-1n)
				vids(0) = new VertexId(i+1n, j);
		} else {
			vids = new Rail[VertexId](3);
			vids(0) = new VertexId(i+1n, j+1n);
			vids(1) = new VertexId(i, j+1n);
			vids(2) = new VertexId(i+1n, j);
		}

		return vids;
	}


	// 覆盖父类输出入度矩阵函数
	public def printIndegreeMatrix() {
		Console.OUT.println("indegree matrix:");
		for(var i:Int=0n;i<height;i++) {
			for (var j:Int=0n; j<width; j++) {
				val node = getNode(i, j);
				if(!node._isFinish)
    				Console.OUT.print(node.getIndegree());
    			else
    				Console.OUT.print("f");
			}
			Console.OUT.println();
		}
		Console.OUT.println();
	}

	// 覆盖父类输出结果矩阵函数
	public def printResultMatrix() {
		Console.OUT.println("result matrix:");
		for(var i:Int=0n;i<height;i++) {
			for (var j:Int=0n; j<width; j++) {
    			Console.OUT.print(getVertex(i, j).getResult()+" ");
			}
			Console.OUT.println();
		}
		Console.OUT.println();
	}
}
