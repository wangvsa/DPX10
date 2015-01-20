package tada.util;

import x10.util.Random;

public class Util {

    /**
     * Generate a string with given length
     */
    public static def generateRandomString(length:Int, range:String) {
        val all_chars = range.chars();

        val rand = new Random();
        val str_chars = new Rail[Char](length);
        for(var i:Int=0n;i<length;i++) {
            str_chars(i) = all_chars(rand.nextLong(all_chars.size));
        }

        return new String(str_chars);
    }

    public static def generateRandomString(length:Int) {
        val range = "abcdefghijklmnopqrstuvwxyz";
        return generateRandomString(length, range);
    }

}