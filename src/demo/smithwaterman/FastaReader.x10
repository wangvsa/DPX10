package demo.smithwaterman;

import x10.io.File;
import x10.io.IOException;

/**
 * Read sequences from the fasta format file
 */
public class FastaReader {

	// Read from file
	// path: file path
	public static def read(path:String):String {
		var seq:String = "";
		var i:Long = 0;
		try {
			val input = new File(path);
			for(line in input.lines()) {
				if(line.startsWith(">"))
					continue;
				seq += line;
				i += 1;
			}
		} catch (IOException) {}

		return seq;
	}

	// Return when found the head information
	// path: file path
	public static def readInformation(path:String):String {
		try {
			val input = new File(path);
			for(line in input.lines()) {
				if(line.startsWith(">"))
					return line;	
			}
		} catch(IOException) {}
		return "";
	}

}
