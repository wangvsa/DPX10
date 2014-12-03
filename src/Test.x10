import x10.util.*;
import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;
import tada.*;
import tada.dag.*;

public class Test {

	private val _distAllTasks:DistArray[Node[Int]];
	private var _taskRegion : Region;
	private var _taskDist : Dist;

	public def this(height:Long, width:Long) {
		this._taskRegion = Region.make(0..(height-1), 0..(width-1));
		this._taskDist = Dist.makeBlock(_taskRegion);
		this._distAllTasks = DistArray.make[Node[Int]](_taskDist);
	}

	public def initDistributedTasks() {
		Place.places().broadcastFlat(()=>{
			val it = _distAllTasks.getLocalPortion().iterator();
			while(it.hasNext()) {
				val point:Point = it.next();
				var i:Int = 0n;
				var j:Int = point(0) as Int;
				if(point.rank==2) {
					i = point(0) as Int;
					j = point(1) as Int;
				}
				val indegree = new Random().nextLong();
				this._distAllTasks(point) = new Node[Int](indegree);
			}
		});
	}

	public def iteratorTasks() {
		Place.places().broadcastFlat(()=>{
			Console.OUT.println("iterator at "+here);
			val it = _distAllTasks.getLocalPortion().iterator();
			while(it.hasNext()) {
				val node = this._distAllTasks(it.next());
				if(node._isFinish) {
					Console.OUT.println("finish!");
				}
			}
		});
	}

	/*
	public static def main(args:Rail[String]) {
		val height = Long.parse(args(0));
		val width = Long.parse(args(1));

		val test = new Test(height, width);
		var time:Long = -System.currentTimeMillis();
		test.initDistributedTasks();
		time += System.currentTimeMillis();
		Console.OUT.println("init spends time: "+time+"ms");

		time = -System.currentTimeMillis();
		test.iteratorTasks();
		time += System.currentTimeMillis();
		Console.OUT.println("iterator spends time: "+time+"ms");


	}
	*/

}