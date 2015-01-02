package tada.dag;

/**
 * Used when write a custom DAG pattern and in ready task list
 */
public struct VertexId {

    public val i:Int;    // row
    public val j:Int;    // col

    public def this(i:Int, j:Int) {
        this.i = i;
        this.j = j;
    }

    public def equalsWith(another:VertexId) {
    	if(this.i==another.i&&this.j==another.j)
    		return true;
    	return false;
    }

}
