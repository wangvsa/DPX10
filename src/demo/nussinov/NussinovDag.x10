package demo.nussinov;

import dpx10.*;
import dpx10.dag.*;
import dpx10.DPX10.*;
import x10.util.ArrayList;

public class NussinovDag[T]{T haszero} extends Dag[T]{

    private val nussinov:Nussinov;

    public def this(nus:Nussinov, config:Configuration) {
        super(nus.length, nus.length, config);
        this.nussinov = nus;
    }

    public def getDependencies(i:Int, j:Int):Rail[VertexId] {
        if(i>=j)
            return new Rail[VertexId]();

        val vids = new ArrayList[VertexId]();
        if(i!=this.nussinov.length-1n && j!=0n)
            vids.add(new VertexId(i+1n, j-1n));
        for(k in (i..(j-1n))) {
            vids.add(new VertexId(i, k));
            vids.add(new VertexId(k+1n, j));
        }
        return vids.toRail();
    }

    public def getAntiDependencies(i:Int, j:Int):Rail[VertexId] {
        if(i > j+1n)
            return new Rail[VertexId]();

        val vids = new ArrayList[VertexId]();
        if(i!=0n && j!=this.nussinov.length-1n)
            vids.add(new VertexId(i-1n, j+1n));
        for(k in (0n..(i-1n)))
            if(j!=k)
                vids.add(new VertexId(k, j));
        for(k in ((j+1n)..(this.nussinov.length-1n)))
            if(i!=k)
                vids.add(new VertexId(i, k));
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