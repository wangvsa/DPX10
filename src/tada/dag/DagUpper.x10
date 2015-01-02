package tada.dag;

public class DagUpper[T]{T haszero} extends Dag[T] {

	public def this(height:Int, width:Int) {
		super(height, width);
	}

	public def getDependencies(i:Int, j:Int):Rail[VertexId] {

		var vids:Rail[VertexId];

		if(i==0n)
			return new Rail[VertexId](0);

		vids = new Rail[VertexId](this.width);
		for(var k:Long=0; k<vids.size; k++) {
			vids(k) = new VertexId(i-1n, k as Int);
		}
		return vids;
	}


	public def getAntiDependencies(i:Int, j:Int):Rail[VertexId] {
		var vids:Rail[VertexId];

		if(i==this.height-1n)
			return new Rail[VertexId](0);

		vids = new Rail[VertexId](this.width);
		for(var k:Long=0;k<vids.size;k++) {
			vids(k) = new VertexId(i+1n, k as Int);
		}
		return vids;
	}

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

}
