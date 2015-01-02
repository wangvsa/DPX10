package tada.dag;

public class DagUpper[T]{T haszero} extends Dag[T] {

	public def this(height:Int, width:Int) {
		super(height, width);
	}

	public def getDependencyTasksLocation(i:Int, j:Int):Rail[Location] {

		var locs:Rail[Location];

		if(i==0n)
			return new Rail[Location](0);

		locs = new Rail[Location](this.width);
		for(var k:Long=0; k<locs.size; k++) {
			locs(k) = new Location(i-1n, k as Int);
		}
		return locs;
	}


	public def getAntiDependencyTasksLocation(i:Int, j:Int):Rail[Location] {
		var locs:Rail[Location];

		if(i==this.height-1n)
			return new Rail[Location](0);

		locs = new Rail[Location](this.width);
		for(var k:Long=0;k<locs.size;k++) {
			locs(k) = new Location(i+1n, k as Int);
		}
		return locs;
	}

	public def printIndegreeMatrix() {
        Console.OUT.println("indegree matrix:");
        for(var i:Int=0n;i<height;i++) {
            for (var j:Int=0n; j<width; j++) {
                val node = getNode(i, j);
                if(!node._isFinish)
                    Console.OUT.print(getNode(i, j).getIndegree());
                else
                    Console.OUT.print("f");
            }
            Console.OUT.println();
        }
        Console.OUT.println();
    }

}
