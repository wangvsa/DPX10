package tada.dag;

public struct Location {

    public val i:Int;    // row
    public val j:Int;    // col

    public def this(i:Int, j:Int) {
        this.i = i;
        this.j = j;
    }

    public def hash() {
    	return (i*10000+j) as Int;
    }

    public def equalsWith(another:Location) {
    	if(this.i==another.i&&this.j==another.j)
    		return true;
    	return false;
    }

}
