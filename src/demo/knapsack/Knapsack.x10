package demo.knapsack;

import tada.*;
import tada.dag.*;
import tada.Tada.*;
import x10.array.Array_2;
import x10.util.Random;

public class Knapsack extends TadaAppDP[Int] {

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

    public def compute(i:Int, j:Int, tasks:Rail[Task[Int]]):Int {
        if( i == 0n || j == 0n) {
            return 0n;
        } else {
            var v1:Int = 0n, v2:Int = 0n;
            for (k in 0..(tasks.size-1)) {
                val loc = tasks(k)._loc;
                if (loc.j==j)
                    v1 = tasks(k).getResult();
                else
                    v2 = tasks(k).getResult() + this._profit(i-1);
            }
            return Math.max(v1, v2);
        }
    }

    public def taskFinished(dag:Dag[Int]):void {
        Console.OUT.println("\nTask finished, sum:" + dag.getNode(this._item_num, this._capacity).getResult()+"\n");
    }

}