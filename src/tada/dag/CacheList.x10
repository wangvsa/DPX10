package tada.dag;

/**
 * Cache list for nodes
 *
 * May have problem of atomic?
 */
public class CacheList[T]{T haszero} {

    // total size of the cache list
    private val size:Int;
    // current index;
    private var index:Int;

    // real storage backend
    private val list:Rail[Task[T]];

    public def this(val sz:Int) {
        this.index = 0n;
        this.size = sz;
        this.list = new Rail[Task[T]](sz);
    }

    public def add(task:Task[T]) {
        list(index) = task;
        index++;
        if(index == size)
            index = 0n;
    }

    public def get(i:Int, j:Int):Task[T] {
        for(var k:Int=0n;k<size;k++) {
            if(list(k)==null)
                break;
            if(list(k)._loc.i==i && list(k)._loc.j==j)
                return list(k);
        }
        return Zero.get[Task[T]]();
    }

    public def containsKey(i:Int, j:Int):Boolean {
        for(var k:Int=0n;k<size;k++) {
            if(list(k)==null)
                break;
            if(list(k)._loc.i==i && list(k)._loc.j==j)
                return true;
        }
        return false;
    }


}

