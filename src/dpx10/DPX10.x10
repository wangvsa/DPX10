package dpx10;

import x10.util.Team;
import dpx10.dag.*;

public class DPX10[T]{T haszero} {

	public val _app:DPX10App[T];
	public val _dag:Dag[T];

	public def this(app:DPX10App[T], dag:Dag[T]) {
		this._app = app;
		this._dag = dag;
		this._dag.initDistributedTasks();
	}

	public def start() {
		if(!validateEnvironment())
			return;

		var time:Long = -System.currentTimeMillis();

		//this._dag.printIndegreeMatrix();

		while(true) {
			try {
				finish for(p in Place.places()) async at(p) {
					val worker = new DPX10Worker[T](_app, _dag);
					worker.execute();
				}
			} catch(es:MultipleExceptions) {
				es.printStackTrace();
				recover();
				continue;
			}
			break;
		}


		time += System.currentTimeMillis();
		Console.OUT.println("\nspend time:"+time+"ms\n");

		//this._dag.printIndegreeMatrix();
		//this._dag.printResultMatrix();
		//this._app.taskFinished(_dag);
	}

	private def recover() {
		var t:Long = -System.currentTimeMillis();
		Console.OUT.println("captured by DPX10, enter resilient mode.");
		_dag.resilient();
		t += System.currentTimeMillis();
		Console.OUT.println("resilient finish, spend time:"+t+"ms");
		//this._dag.printIndegreeMatrix();
		//this._dag.printResultMatrix();
	}


	private def validateEnvironment():Boolean {
		if(Runtime.NTHREADS<=0) {
			Console.OUT.println("Invalid threads number!");
			return false;
		}

		Console.OUT.println("X10_NPLACES:"+Place.numPlaces()+", X10_NTHREADS:"+Runtime.NTHREADS);
		return true;
	}



	// 由实现类实现
	public interface DPX10App[T]{T haszero} {
		def compute(i:Int, j:Int, Tasks:Rail[Vertex[T]]):T;
		def taskFinished(dag:Dag[T]):void;
		def loopOver(dag:Dag[T]):Boolean;
	}


	public static abstract class DPX10AppDP[T]{T haszero} implements DPX10App[T] {
		public def loopOver(dag:Dag[T]):Boolean {
			return true;		// task is over
		}
	}


}
