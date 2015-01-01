package demo.knapsack;

import tada.dag.*;

public class KnapsackDag[T]{T haszero} extends Dag[T] {

    private _knapsack:Knapsack;

    //public def this(height:Int, width:Int) {
    //    super(height, width);
    //}
    public def this(knap:Knapsack) {
        super(knap._item_num+1n, knap._capacity+1n);
        this._knapsack = knap;
    }

    public def getDependencyTasksLocation(i:Int, j:Int):Rail[Location] {
        val locs:Rail[Location];
        if( i == 0n || j == 0n ) {
            locs = new Rail[Location](0);
        } else {
            if( _knapsack._weight(i-1) <= j ) {
                locs = new Rail[Location](2);
                locs(0) = new Location(i-1n, j);
                locs(1) = new Location(i-1n, j-_knapsack._weight(i-1));
            } else {
                locs = new Rail[Location](1);
                locs(0) = new Location(i-1n, j);
            }
        }
        return locs;
    }


    public def getAntiDependencyTasksLocation(i:Int, j:Int):Rail[Location] {
        val locs:Rail[Location];
        if ( i == 0n ) {
            locs = [new Location(i+1n, j)];
        } else if( i == _knapsack._item_num) {
            if( j+_knapsack._weight(i-1) > _knapsack._capacity) {
                locs = new Rail[Location](0);
            } else {
                locs = new Rail[Location](1);
                locs(0) = new Location(i, j+_knapsack._weight(i-1));
            }
        } else {
            if( j+_knapsack._weight(i-1) > _knapsack._capacity) {
                locs = new Rail[Location](1);
                locs(0) = new Location(i+1n, j);
            } else {
                locs = new Rail[Location](2);
                locs(0) = new Location(i+1n, j);
                locs(1) = new Location(i, j+_knapsack._weight(i-1));
            }
        }

        return locs;
    }

    // 覆盖父类输出入度矩阵函数
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
