package tada.dag;

public class Dag124[T]{T haszero} extends Dag[T] {

	public def this(height:Int, width:Int) {
		super(height, width);	
	}

	public def getDependencyTasksLocation(i:Int, j:Int):Rail[Location] {
		val locs:Rail[Location];
		if(i==0n&& j==0n) {
			locs = new Rail[Location](0);
		} else if(i==0n|| j==0n) {
			locs = new Rail[Location](1);
			if(i==0n)
				locs(0) = new Location(i, j-1n);
			if(j==0n)
				locs(0) = new Location(i-1n, j);
		} else {
			locs = new Rail[Location](3);
			locs(0) = new Location(i-1n, j-1n);
			locs(1) = new Location(i, j-1n);
			locs(2) = new Location(i-1n, j);
		}

		return locs;
	}


	public def getAntiDependencyTasksLocation(i:Int, j:Int):Rail[Location] {
		val locs:Rail[Location];

		if(i==height-1n && j==width-1n) {
			locs = new Rail[Location](0);
		} else if(i==height-1n || j==width-1n) {
			locs = new Rail[Location](1);
			if(i==height-1n)
				locs(0) = new Location(i, j+1n);
			if(j==width-1n)
				locs(0) = new Location(i+1n, j);
		} else {
			locs = new Rail[Location](3);
			locs(0) = new Location(i+1n, j+1n);
			locs(1) = new Location(i, j+1n);
			locs(2) = new Location(i+1n, j);
		}

		return locs;
	}


	// 覆盖父类输出入度矩阵函数
	public def printIndegreeMatrix() {
		Console.OUT.println("indegree matrix:");
		for(var i:Int=0n;i<height;i++) {
			for (var j:Int=0n; j<width; j++) {
    			Console.OUT.print(getNode(i, j).getIndegree()+" ");
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
    			Console.OUT.print(getNode(i, j).getResult()+" ");
			}
			Console.OUT.println();
		}
		Console.OUT.println();
	}
}
