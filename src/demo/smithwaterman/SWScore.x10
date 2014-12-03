package demo.smithwaterman;

public struct SWScore {

	public val score : Int;
	public val isGapOpen : Boolean;

	public def this(score:Int, open:Boolean) {
		this.score = score;
		this.isGapOpen = open;
	}

}