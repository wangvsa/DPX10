package tada.dag;

import x10.util.concurrent.AtomicInteger;
import x10.util.*;
import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;
import x10.compiler.NonEscaping;

public abstract class Dag[T]{T haszero} {

	public val width:Int;
	public val height:Int;
	public var taskSize:Long;

	public var _taskRegion : Region;
	public var _taskDist : Dist;

	public var _resilientFalg : Boolean = false;


	// 所有任务，TadaWorker可以从任意Place访问
    public var _distAllTasks:DistArray[Node[T]];
  	// 所有的就绪任务(入度为零)，TadaWorker可以从自己的Place访问自己的就绪任务列表
  	public var _localReadyTasks:PlaceLocalHandle[ArrayList[Location]];
  	// 获取依赖任务时，将异地的任务缓存下来，TadaWorker可以从自己的Place访问
    public val _localCachedTasks:PlaceLocalHandle[TaskSet[T]];
    // 每个Place的活动数
    public val _localActivityCount:PlaceLocalHandle[AtomicInteger];



    // 通过一段时间内执行的任务数来记录所有Place的工作状态
    public val _globalPlaceStatus:PlaceLocalHandle[Rail[Int]];

	public def this(height:Int, width:Int) {
		this.taskSize = height * width;
		this.height = height;
		this.width = width;

		this._localReadyTasks = PlaceLocalHandle.makeFlat[ArrayList[Location]]
            (Place.places(), ()=>new ArrayList[Location](), (p:Place)=>true);
		this._localCachedTasks = PlaceLocalHandle.makeFlat[TaskSet[T]]
            (Place.places(), ()=>new TaskSet[T](), (p:Place)=>true);
		this._localActivityCount = PlaceLocalHandle.makeFlat[AtomicInteger]
            (Place.places(), ()=>new AtomicInteger(0n), (p:Place)=>true);
		this._globalPlaceStatus = PlaceLocalHandle.makeFlat[Rail[Int]]
            (Place.places(), ()=>new Rail[Int](Place.numPlaces()), (p:Place)=>true);

		initRegionAndDist();
		this._distAllTasks = DistArray.make[Node[T]](_taskDist);
	}


	/** 可被子类覆盖 **/
	@NonEscaping final def initRegionAndDist() {
		this._taskRegion = Region.make(0..(height-1n), 0..(width-1n));
		if(this.height==1n)
			this._taskDist = Dist.makeBlock(_taskRegion, 1);
		else
			this._taskDist = Dist.makeBlock(_taskRegion, 0);
	}

	public def initDistributedTasks() {
		Place.places().broadcastFlat(()=>{
			val it = _distAllTasks.getLocalPortion().iterator();
			while(it.hasNext()) {
				val point:Point = it.next();
				val i = point(0) as Int;
				val j = point(1) as Int;
				val loc = new Location(i, j);
				val indegree = getDependencyTasksLocation(i, j).size;
				this._distAllTasks(point) = new Node[T](indegree);
				if(indegree==0) {
					_localReadyTasks().add(loc);	
				}
			}
		});
	}



	/**
	 *	方便用户TadaApp类中调用
	 */
	public def getNode(i:Int, j:Int):Node[T] {
		val place = getNodePlace(i, j);
		if(place==here)
			return this._distAllTasks(Point.make(i, j));
		else
			return at (place) _distAllTasks(Point.make(i, j));
	}
	
	public def getNodePlace(i:Int, j:Int) {
		return this._taskDist(Point.make(i, j));
	}


	/*
	 *	设置节点的结果以及完成标识
	 */
	public def setResult(i:Int, j:Int, value:T) {
        val place = getNodePlace(i, j);
		if(place==here) {
			val node = _distAllTasks(Point.make(i, j));
			node.setResult(value);
			node._isFinish = true; 
		} else at (place) {
			val node = _distAllTasks(Point.make(i, j));
			node.setResult(value);
			node._isFinish = true;
		}
    }

	public def decrementIndegree(i:Int, j:Int) {
        val loc = new Location(i, j);
        val place = getNodePlace(i, j);
        if(place==here) {
        	val node = _distAllTasks(Point.make(i, j));
        	val indegree = node.decrementIndegree();
	        if(indegree==0 && !node._isFinish)
	           	addReadyNode(loc);
        } else at(place) {
        	val node = _distAllTasks(Point.make(i, j));
            val indegree = node.decrementIndegree();
            if(indegree==0 && !node._isFinish)
            	addReadyNode(loc);
	    }
    }


    /*
     *	如果依赖的节点不在本地，则：
     *	先查找本地缓存，如果没有从全局列表中查找然后加入缓存列表
     */
    public def getDependencyTasks(i:Int, j:Int):Rail[Task[T]] {
        val locs = getDependencyTasksLocation(i, j);
        val tasks = new Rail[Task[T]](locs.size);
        for(var k:Long=0;k<locs.size;k++) {
            val loc = locs(k);
            val place = getNodePlace(loc.i, loc.j);
            // TODO simplify this
            if(place==here) {
                val node = this._distAllTasks(Point.make(loc.i, loc.j));
                tasks(k) = new Task[T](loc, node);
            } else {
                if(this._localCachedTasks().containsKey(loc)) {
                    tasks(k) = this._localCachedTasks()(loc);
                } else {
                    val node = at(place) this._distAllTasks(Point.make(loc.i, loc.j));
                    tasks(k) = new Task[T](loc, node);
                    //this._localCachedTasks().put(tasks(k));    // cache it
                }
            }
        }
        return tasks;
    }


    // not used
    public atomic def addAndGet(loc:Location):Location {
        if(loc.i==-9n) {
            val firstLoc = this._localReadyTasks().removeFirst();
            return firstLoc;
        } else {
            this._localReadyTasks().add(loc); 
        }
        return loc;
    }


    public atomic def addReadyNode(loc:Location) {
		this._localReadyTasks().add(loc); 
    }
    public atomic def getReadyNode():Location {
		return this._localReadyTasks().removeFirst();
    }



    // 检查是否还有正在执行任务的Activity
    public def hasLiveActivity():Boolean {
    	var count:Int = 0n;
    	finish for (place in Place.places()) {
    		count += at(place) this._localActivityCount().get();
    	}
    	if(count==0n)
    		return true;
    	return false;
    }


	public def resilient() {
		if(hasLiveActivity()) {
			Console.OUT.println("still has live activity!");
			return;
		}

		this._resilientFalg = true;
		remakeDistArray();
		this._resilientFalg = false;
	}


    public def remakeDistArray() {

    	var time:Long = -System.currentTimeMillis();
    	Console.OUT.println("remake...");

    	val livePlaces = Place.places();
    	var dist:Dist;
    	if(this.height==1n)
    		dist = Dist.makeBlock(_distAllTasks.dist.region, 1n, livePlaces);
		else
    		dist = Dist.makeBlock(_distAllTasks.dist.region, 0n, livePlaces);

    	val newArray = DistArray.make[Node[T]](dist);

    	// 第一次遍历将原来的结果复制过来，初始化挂掉的Place中的节点
    	livePlaces.broadcastFlat(()=>{
			val it = newArray.getLocalPortion().iterator();
			while(it.hasNext()) {
				val point = it.next();
				if(_distAllTasks.dist(point)==here) {
					newArray(point) = _distAllTasks(point);
				} else {
					// init
					val i = point(0) as Int;
					val j = point(1) as Int;
					val indegree = getDependencyTasksLocation(i, j).size;
					newArray(point) = new Node[T](indegree);
				}
			}
    	});

    	// 第二次遍历设置所有节点的入度，将入度为0且没完成的节点加入调度队列
    	val newReadyTasks = PlaceLocalHandle.makeFlat[ArrayList[Location]]
            (livePlaces, ()=>new ArrayList[Location](), (p:Place)=>true);

    	finish for(place in livePlaces) async at(place) {
			val it = newArray.getLocalPortion().iterator();
			while(it.hasNext()) {
				val point = it.next();
				val node = newArray(point);
				if(node._isFinish) {
					val locs = getAntiDependencyTasksLocation(point(0) as Int, point(1) as Int);
			        for(loc in locs) {
			        	val p = Point.make(loc.i, loc.j);
			        	at(newArray.dist(p)) {
			        		val indegree = newArray(p).decrementIndegree();
			        		if(indegree==0) {
			        			newReadyTasks().add(new Location(point(0) as Int, point(1) as Int));
			        		}
			        	}
			        }
				}
			}
		}

    	this._distAllTasks = newArray;
    	this._localReadyTasks = newReadyTasks;

    	time += System.currentTimeMillis();
    	Console.OUT.println("remake finish, spend time:"+time);
    }


	/**
	 * 输出入度矩阵，可由子类覆盖
	 */
	public def printIndegreeMatrix() {
		Console.OUT.println("indegree matrix:");
	}

	/**
	 * 输出结果矩阵，可由子类覆盖
	 */
	public def printResultMatrix() {
		Console.OUT.println("result matrix:");
  	}



	/* 协议 ---- 由子类是实现 */

	// 描述依赖关系
	public abstract def getDependencyTasksLocation(i:Int, j:Int):Rail[Location];
	public abstract def getAntiDependencyTasksLocation(i:Int, j:Int):Rail[Location];

}
