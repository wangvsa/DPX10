package dpx10.dag;

import x10.util.concurrent.AtomicInteger;

/**
 *
 * This class only used by DPX10 to implement DAG
 * It is invisible to users
 * Vertex class is visible to users
 */
public class Node[T]{T haszero} {
	public var _isFinish:Boolean;
	private var _result:T;
	private var _indegree:AtomicInteger;

	public def this(indegree:Int) {
		this._isFinish = false;
		this._indegree = new AtomicInteger(indegree);
		this._result = Zero.get[T]();
	}

	public def this(indegree:Int, result:T) {
		this._isFinish = false;
		this._indegree = new AtomicInteger(indegree);
		this._result = result;
	}

	public def getIndegree() {
		return this._indegree.get();
	}
	public def decrementIndegree() {
		return this._indegree.decrementAndGet();
	}

	public def setResult(value:T) {
		this._result = value;
	}
	public def getResult() {
		return this._result;
	}
}