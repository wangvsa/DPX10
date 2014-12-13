package tada.dag;

/** 
 *	用来将结果返回给用户
 */
public class Task[T]{T haszero} {

	public val _loc:Location;
	private var _result:T;


	public def this(loc:Location, result:T) {
		this._loc = loc;
		this._result = result;
	}
	public def this(loc:Location, node:Node[T]) {
		this._loc = loc;
		this._result = node.getResult();
	}


	public def getResult() {
		return this._result;	
	}

}
