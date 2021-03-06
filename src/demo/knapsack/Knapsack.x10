package demo.knapsack;

import dpx10.*;
import dpx10.dag.*;
import dpx10.DPX10.*;
import x10.array.Array_2;
import x10.util.Random;

public class Knapsack extends DPX10AppDP[Int] {

    public val _capacity:Int;    // knapsack capacity
    public val _item_num:Int;    // number of items

    public val _profit:Rail[Int];
    public val _weight:Rail[Int];

    public def this(capacity:Int, item_num:Int) {
        this._capacity = capacity;
        this._item_num = item_num;
        this._profit = new Rail[Int](item_num);
        this._weight = new Rail[Int](item_num);
        val rand = new Random();
        for(i in (1n..item_num) ) {
            this._profit(i-1n) = rand.nextInt(10n)+1n;
            this._weight(i-1n) = rand.nextInt(capacity*2n/item_num)+1n;
        }
    }

    public def compute(i:Int, j:Int, vertices:Rail[Vertex[Int]]):Int {
        if( i == 0n || j == 0n) {
            return 0n;
        } else {
            var v1:Int = 0n, v2:Int = 0n;
            for (vertex in vertices) {
                if (vertex.j==j)
                    v1 = vertex.getResult();
                else
                    v2 = vertex.getResult() + this._profit(i-1);
            }
            return Math.max(v1, v2);
        }
    }

    public def taskFinished(dag:Dag[Int]):void {
        Console.OUT.println("\nTask finished, sum:" + dag.getVertex(this._item_num, this._capacity).getResult()+"\n");
    }

}