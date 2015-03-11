package dpx10;

import x10.util.Random;
import x10.util.*;
import dpx10.dag.*;

public class Scheduler[T]{T haszero} {

	private val placeIdleCount:Rail[Int];

	public val _dag:Dag[T];

	public def this(dag : Dag[T]) {
		this._dag = dag;
		this.placeIdleCount = new Rail[Int](Place.numPlaces());
	}

	public static def randomSchedule() : Place {
		val max = Place.numPlaces();
		val index = new Random().nextInt(max as Int);
		return Place(index);
	}

	public def leastDepdencySchedule(loclist:ArrayList[VertexId]):Place {
		// place score matrix，
		val psm = new Rail[Int](Place.numPlaces(), 0n);

		for(theloc in loclist) {
			// 每一个依赖加2分
			val depLocs = _dag.getDependencies(theloc.i, theloc.j);
			for(loc in depLocs) {
				psm(_dag.getNodePlace(loc.i, loc.j).id) += 2n;
			}

			// 每被依赖一个加1分
			val antiDepLocs = _dag.getAntiDependencies(theloc.i, theloc.j);
			for(loc in antiDepLocs) {
				psm(_dag.getNodePlace(loc.i, loc.j).id) += 1n;
			}
		}

		// 每个任务自身加1分
		psm(here.id) += loclist.size() as Int;

		// 寻找最大值
		var max:Int = 0n;
		var pid:Long = here.id;
		for(var i:Long=0;i<psm.size;i++) {
			if(max < psm(i)) {
				pid = i;
				max = psm(i);
			}
		}

		return Place(pid);
	}


	public def increaseIdleCount() {
		placeIdleCount(here.id) = placeIdleCount(here.id) + 1n;
	}

	public def resetIdleCount() {
		placeIdleCount(here.id) = 0n;
	}

	public static def scheduleMaxIdle(countList:Rail[Int]) {
		if(countList(here.id) < 100)
			return here;

		var index:Long = here.id;
		for(var i:Long=0;i<countList.size;i++) {
			if(countList(i)<10) {
				index = countList(i);
				break;
			}
		}

		if(new Random().nextInt(2n)==0n)
			return Place(index);
		return here;
	}

}
