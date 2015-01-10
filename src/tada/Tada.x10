package tada;

import x10.util.Team;
import tada.dag.*;

public class Tada[T]{T haszero} {

	public val _app:TadaApp[T];
	public val _dag:Dag[T];

	public def this(app:TadaApp[T], dag:Dag[T]) {
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
					val worker = new TadaWorker[T](_app, _dag);
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
		Console.OUT.println("captured by Tada, enter resilient mode.");
		_dag.resilient();
		t += System.currentTimeMillis();
		Console.OUT.println("resilient finish, spend time:"+t+"ms");
		this._dag.printIndegreeMatrix();
		this._dag.printResultMatrix();
	}


	private def validateEnvironment():Boolean {
		if(Runtime.NTHREADS<=1) {
			Console.OUT.println("Threads must be more than one");
			return false;
		}

		Console.OUT.println("X10_NPLACES:"+Place.numPlaces()+", X10_NTHREADS:"+Runtime.NTHREADS);
		return true;
	}



	// 由实现类实现
	public interface TadaApp[T]{T haszero} {
		def compute(i:Int, j:Int, Tasks:Rail[Vertex[T]]):T;
		def taskFinished(dag:Dag[T]):void;
		def loopOver(dag:Dag[T]):Boolean;
	}


	public static abstract class TadaAppDP[T]{T haszero} implements TadaApp[T] {
		public def loopOver(dag:Dag[T]):Boolean {
			return true;		// task is over
		}
	}


}
