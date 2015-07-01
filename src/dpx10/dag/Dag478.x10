package dpx10.dag;

import dpx10.Configuration;

public class Dag478[T]{T haszero} extends Dag[T] {

    public def this(height:Int, width:Int, config:Configuration) {
        super(height, width, config);
    }

    // override
    public def initDistributedTasks() {
        Place.places().broadcastFlat(()=>{
            val it = _distAllTasks.getLocalPortion().iterator();
            while(it.hasNext()) {
                val point:Point = it.next();
                val i = point(0) as Int;
                val j = point(1) as Int;
                val loc = new VertexId(i, j);
                val indegree = getDependencies(i, j).size;
                this._distAllTasks(i, j) = new Node[T](indegree as Int);
                if(i>j+1n) {
                    this._distAllTasks(i, j)._isFinish = true;
                } else {
                    if(indegree==0)
                        _localReadyTasks().add(loc);
                }
            }
        });
    }

    public def getDependencies(i:Int, j:Int):Rail[VertexId] {
        if(i>=j)
            return new Rail[VertexId]();
        val vids = new Rail[VertexId](3);
        vids(0) = new VertexId(i, j-1n);
        vids(1) = new VertexId(i+1n, j);
        vids(2) = new VertexId(i+1n, j-1n);
        return vids;
    }

    public def getAntiDependencies(i:Int, j:Int):Rail[VertexId] {
        if(i>j+1n)
            return new Rail[VertexId]();
        if(i==j+1n)
            return [new VertexId(i-1n, j+1n)];

        if(i-1n>=0n && j+1n<width)
            return [new VertexId(i-1n, j+1n), new VertexId(i, j+1n), new VertexId(i-1n, j)];
        else if(i-1n >= 0n)
            return [new VertexId(i-1n, j)];
        else if(j+1n < width)
            return [new VertexId(i, j+1n)];

        return new Rail[VertexId]();
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