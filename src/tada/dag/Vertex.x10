package tada.dag;

/**
 *	用来将结果返回给用户(in compute function)
 *	Also used in Cache List
 */
public class Vertex[T]{T haszero} {
	public val i:Int, j:Int;
	private var _result:T;

	public def this(i:Int, j:Int, result:T) {
		this.i = i;
		this.j = j;
		this._result = result;
	}
	public def this(i:Int, j:Int, node:Node[T]) {
		this.i = i;
		this.j = j;
		this._result = node.getResult();
	}

	public def getResult() {
		return this._result;
	}
}
