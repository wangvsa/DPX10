package demo.knapsack;

import tada.Configuration;
import tada.dag.*;

public class KnapsackDag[T]{T haszero} extends Dag[T] {

    private _knapsack:Knapsack;

    public def this(knap:Knapsack, config:Configuration) {
        super(knap._item_num+1n, knap._capacity+1n, config);
        this._knapsack = knap;
    }

    public def getDependencies(i:Int, j:Int):Rail[VertexId] {
        val vids:Rail[VertexId];
        if( i == 0n || j == 0n ) {
            vids = new Rail[VertexId](0);
        } else {
            if( _knapsack._weight(i-1) <= j ) {
                vids = new Rail[VertexId](2);
                vids(0) = new VertexId(i-1n, j);
                vids(1) = new VertexId(i-1n, j-_knapsack._weight(i-1));
            } else {
                vids = new Rail[VertexId](1);
                vids(0) = new VertexId(i-1n, j);
            }
        }
        return vids;
    }


    public def getAntiDependencies(i:Int, j:Int):Rail[VertexId] {
        val vids:Rail[VertexId];
        if ( i == 0n ) {
            vids = [new VertexId(i+1n, j)];
        } else if( i == _knapsack._item_num) {
            if( j+_knapsack._weight(i-1) > _knapsack._capacity) {
                vids = new Rail[VertexId](0);
            } else {
                vids = new Rail[VertexId](1);
                vids(0) = new VertexId(i, j+_knapsack._weight(i-1));
            }
        } else {
            if( j+_knapsack._weight(i-1) > _knapsack._capacity) {
                vids = new Rail[VertexId](1);
                vids(0) = new VertexId(i+1n, j);
            } else {
                vids = new Rail[VertexId](2);
                vids(0) = new VertexId(i+1n, j);
                vids(1) = new VertexId(i, j+_knapsack._weight(i-1));
            }
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
