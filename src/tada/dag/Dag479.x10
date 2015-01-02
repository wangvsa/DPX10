package tada.dag;

import x10.util.ArrayList;

public class Dag479[T]{T haszero} extends Dag[T] {

    public def this(height:Int, width:Int) {
        super(height, width);
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

        val vids = new ArrayList[VertexId]();
        if(i-1n>=0 && j+1n<width)
            vids.add(new VertexId(i-1n, j+1n));
        if(j+1n<width)
            vids.add(new VertexId(i, j+1n));
        if(i-1n>=0n)
            vids.add(new VertexId(i-1n, j));
        return vids.toRail();
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