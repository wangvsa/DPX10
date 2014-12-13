package tada.dag;

import x10.util.concurrent.AtomicLong;

public class Node[T]{T haszero} {
	public var _isFinish:Boolean;
	private var _result:T;
	private var _indegree:AtomicLong;


	public def this(indegree:Long) {
		this._isFinish = false;
		this._indegree = new AtomicLong(indegree);
		this._result = Zero.get[T]();
	}

	public def this(indegree:Long, result:T) {
		this._isFinish = false;
		this._indegree = new AtomicLong(indegree);
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