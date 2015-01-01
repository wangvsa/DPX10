package demo.nussinov;

import tada.*;
import tada.dag.*;
import tada.Tada.*;
import x10.util.ArrayList;

public class NussinovDag[T]{T haszero} extends Dag[T]{

    private val nussinov:Nussinov;

    public def this(nus:Nussinov) {
        super(nus.length, nus.length);
        this.nussinov = nus;
    }

    public def getDependencyTasksLocation(i:Int, j:Int):Rail[Location] {
        if(i>=j)
            return new Rail[Location]();

        val locs = new ArrayList[Location]();
        if(i!=this.nussinov.length-1n && j!=0n)
            locs.add(new Location(i+1n, j-1n));
        for(k in (i..(j-1n))) {
            locs.add(new Location(i, k));
            locs.add(new Location(k+1n, j));
        }
        return locs.toRail();
    }

    public def getAntiDependencyTasksLocation(i:Int, j:Int):Rail[Location] {
        if(i > j+1n)
            return new Rail[Location]();

        val locs = new ArrayList[Location]();
        if(i!=0n && j!=this.nussinov.length-1n)
            locs.add(new Location(i-1n, j+1n));
        for(k in (0n..(i-1n)))
            if(j!=k)
                locs.add(new Location(k, j));
        for(k in ((j+1n)..(this.nussinov.length-1n)))
            if(i!=k)
                locs.add(new Location(i, k));
        return locs.toRail();
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