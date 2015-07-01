package dpx10.dag;

import dpx10.Configuration;
import x10.util.concurrent.AtomicInteger;
import x10.util.*;
import x10.regionarray.Region;
import x10.regionarray.Dist;
import x10.regionarray.DistArray;
//import x10.resilient.regionarray.DistArray;
import x10.compiler.NonEscaping;

/**
 * This class is the base class.
 * We also provide serveral common used DAG class,
 * But you can always implement your custom DAG class.
 *
 * This class handles data/task initialization(distribution),
 * and transparent fault-tolerance.
 */
public abstract class Dag[T]{T haszero} {

	public val width:Int;
	public val height:Int;
	public var taskSize:Long;

	public var _taskRegion : Region;
	public var _taskDist : Dist;


    public val _config : Configuration;

	public var _resilientFlag : GlobalRef[Cell[Boolean]];


	// 所有任务，DPX10Worker可以从任意Place访问
    public var _distAllTasks:DistArray[Node[T]];
  	// 所有的就绪任务(入度为零)，DPX10Worker可以从自己的Place访问自己的就绪任务列表
  	public var _localReadyTasks:PlaceLocalHandle[ArrayList[VertexId]];
  	// 获取依赖任务时，将异地的任务缓存下来，DPX10Worker可以从自己的Place访问
    public val _localCachedTasks:PlaceLocalHandle[CacheList[T]];

	public def this(height:Int, width:Int, config:Configuration) {
		this.taskSize = height * width;
		this.height = height;
		this.width = width;
        this._config = config;

		this._localReadyTasks = PlaceLocalHandle.makeFlat[ArrayList[VertexId]]
            (Place.places(), ()=>new ArrayList[VertexId](), (p:Place)=>true);
		this._localCachedTasks = PlaceLocalHandle.makeFlat[CacheList[T]]
            (Place.places(), ()=>new CacheList[T](config.cacheSize), (p:Place)=>true);
        this._resilientFlag = GlobalRef[Cell[Boolean]](new Cell[Boolean](false));

		initRegionAndDist();
		this._distAllTasks = DistArray.make[Node[T]](_taskDist);
	}


	/** 可被子类覆盖 **/
	@NonEscaping final def initRegionAndDist() {
		this._taskRegion = Region.make(0..(height-1n), 0..(width-1n));
		if(this.height==1n) {
			this._taskDist = Dist.makeBlock(_taskRegion, 1);
		} else {
            if(_config.distManner==Configuration.DIST_BLOCK_0)
                this._taskDist = Dist.makeBlock(_taskRegion, 0);
            if(_config.distManner==Configuration.DIST_BLOCK_1)
                this._taskDist = Dist.makeBlock(_taskRegion, 1);
            if(_config.distManner==Configuration.DIST_BLOCK_BLOCK)
                this._taskDist = Dist.makeBlockBlock(_taskRegion);
        }

        Console.OUT.println("init DAG, height:"+height+", width:"+width);
        this._config.printConfiguration();
	}

	public def initDistributedTasks() {
		Place.places().broadcastFlat(()=>{
			val it = _distAllTasks.getLocalPortion().iterator();
			while(it.hasNext()) {
				val point:Point = it.next();
				val i = point(0) as Int;
				val j = point(1) as Int;
				val indegree = getDependencies(i, j).size;
				this._distAllTasks(i, j) = new Node[T](indegree as Int);
				if(indegree==0)
					_localReadyTasks().add(new VertexId(i, j));
			}
		});
	}


    /**
     * Get the vertex(i, j) from local or remote place
     * use the cache
     */
	public def getVertex(i:Int, j:Int):Vertex[T] {
		val place = getNodePlace(i, j);
        val vertex:Vertex[T];
        if(place==here) {
            vertex = new Vertex[T](i, j, _distAllTasks(i, j));
        } else {
            if(this._localCachedTasks().containsKey(i, j)) {
                vertex = this._localCachedTasks().get(i, j);
            } else {
                val node = at(place) this._distAllTasks(i, j);
                vertex = new Vertex[T](i, j, node);
                this._localCachedTasks().add(vertex);  // cache it
            }
        }

        return vertex;
	}

    /**
     * used in printIndegreeMatrx()
     */
    public def getNode(i:Int, j:Int):Node[T] {
        val place = getNodePlace(i, j);
        if(place==here)
            return this._distAllTasks(i, j);
        else
            return at (place) this._distAllTasks(i, j);
    }

	public def getNodePlace(i:Int, j:Int) {
        return this._taskDist(i, j);
	}


	/*
	 *	设置节点的结果以及完成标识
	 */
	public def setResult(i:Int, j:Int, value:T) {
        val place = getNodePlace(i, j);
		if(place==here) {
			val node = _distAllTasks(i, j);
			node.setResult(value);
			node._isFinish = true;
		} else at (place) {
			val node = _distAllTasks(i, j);
			node.setResult(value);
			node._isFinish = true;
		}
    }

	public def decrementIndegree(i:Int, j:Int) {
        val loc = new VertexId(i, j);
        val place = getNodePlace(i, j);
        if(place==here) {
        	val node = _distAllTasks(i, j);
        	val indegree = node.decrementIndegree();
	        if(indegree==0n && !node._isFinish)
	           	addReadyNode(loc);
        } else at(place) {
        	val node = _distAllTasks(i, j);
            val indegree = node.decrementIndegree();
            if(indegree==0n && !node._isFinish)
            	addReadyNode(loc);
	    }
    }


    /*
     *	如果依赖的节点不在本地，则：
     *	先查找本地缓存，如果没有从全局列表中查找然后加入缓存列表
     */
    public def getDependentVertices(i:Int, j:Int):Rail[Vertex[T]] {
        val vids = getDependencies(i, j);
        val tasks = new Rail[Vertex[T]](vids.size);

        for(var k:Long=0;k<vids.size;k++) {
            tasks(k) = getVertex(vids(k).i, vids(k).j);
        }

        return tasks;
    }


    // Add a zero indegree vertex into the read list
    public atomic def addReadyNode(vid:VertexId) {
		this._localReadyTasks().add(vid);
    }

    // Return the vertices that can be executed
    public atomic def getAllReadyNodes() {
        val nodes = this._localReadyTasks().clone();
        this._localReadyTasks().clear();
        return nodes;
    }


    public def setResilientFlag(flag:Boolean) {
	   at(Place(0)) _resilientFlag()() = flag;
    }

	public def resilient() {
		setResilientFlag(true);
		remakeDistArray();
		setResilientFlag(false);
	}

    public def remakeDistArray() {
    	val livePlaces = Place.places();

        // make a false places group for evaluation
        // val livePlaces = PlaceGroup.make(Place.numPlaces()-2);

        var newDist:Dist = Dist.makeBlock(_taskRegion, 1, livePlaces);
        if(_config.distManner==Configuration.DIST_BLOCK_0)
            newDist = Dist.makeBlock(_taskRegion, 0, livePlaces);
        if(_config.distManner==Configuration.DIST_BLOCK_BLOCK)
            newDist = Dist.makeBlockBlock(_taskRegion, 0, 1, livePlaces);

    	val newArray = DistArray.make[Node[T]](newDist);

    	// 第一次遍历将原来的结果复制过来，初始化挂掉的Place中的节点入度
    	livePlaces.broadcastFlat(()=>{
			val it = newArray.getLocalPortion().iterator();
			while(it.hasNext()) {
				val point = it.next();
                val i:Int = point(0) as Int;
                val j:Int = point(1) as Int;
				val indegree = getDependencies(i, j).size;
				newArray(i, j) = new Node[T](indegree as Int);
				// 复制原来结果
				if(_distAllTasks.dist(i, j)==here) {
					newArray(i, j).setResult(_distAllTasks(i, j).getResult());
					newArray(i, j)._isFinish = _distAllTasks(i, j)._isFinish;
				}
			}
    	});

    	// 第二次遍历设置所有节点的入度，将入度为0且没完成的节点加入调度队列
    	val newReadyTasks = PlaceLocalHandle.makeFlat[ArrayList[VertexId]]
            (livePlaces, ()=>new ArrayList[VertexId](), (p:Place)=>true);

        livePlaces.broadcastFlat(()=>{
			val it = newArray.getLocalPortion().iterator();
			while(it.hasNext()) {
				val point = it.next();
                val i:Int = point(0) as Int;
                val j:Int = point(1) as Int;
				val node = newArray(i, j);
				if(node._isFinish) {
					val vids = getAntiDependencies(i, j);
			        for(vid in vids) {
                        val pl = newArray.dist(vid.i, vid.j);
                        if(pl==here) {
                            val antiNode = newArray(vid.i, vid.j);
                            val indegree = antiNode.decrementIndegree();
                            if(indegree==0n && !antiNode._isFinish)
                                newReadyTasks().add(new VertexId(vid.i, vid.j));
                        } else at(pl) {
                            val antiNode = newArray(vid.i, vid.j);
                            val indegree = antiNode.decrementIndegree();
                            if(indegree==0n && !antiNode._isFinish)
                                newReadyTasks().add(new VertexId(vid.i, vid.j));
                        }
			        }
				}
			}
		});

		this._taskDist = newDist;
    	this._distAllTasks = newArray;
    	this._localReadyTasks = newReadyTasks;
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



	/* 协议 ---- 由子类实现 */

	// 描述依赖关系
	public abstract def getDependencies(i:Int, j:Int):Rail[VertexId];
	public abstract def getAntiDependencies(i:Int, j:Int):Rail[VertexId];

}
