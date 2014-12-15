package demo.knapsack;

import tada.*;
import tada.dag.*;
import tada.Tada.*;
import x10.array.Array_2;
import x10.util.Random;

public class Knapsack extends TadaAppDP[Int] {

    public static val CAPICITY = 40n;    // knapsack capility
    public static val ITEM_NUM = 6n;     // number of items

    public static val profit = [3n, 4n, 6n, 10n, 2n, 1n];
    public static val weight = [3n, 6n, 9n, 20n, 5n, 2n];

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
                    v2 = tasks(k).getResult() + this.profit(i-1);
            }
            return Math.max(v1, v2);
        }
    }

    public def taskFinished(dag:Dag[Int]):void {
        Console.OUT.println("\nTask finished, sum:" + dag.getNode(ITEM_NUM, CAPICITY).getResult()+"\n");
    }

}