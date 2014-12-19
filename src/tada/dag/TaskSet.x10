package tada.dag;

import x10.compiler.NonEscaping;
import x10.io.CustomSerialization;
import x10.io.Deserializer;
import x10.io.Serializer;

/**
 * 修改自X10中HashMap的实现
 */
public class TaskSet[T] {T haszero} implements CustomSerialization {
	static class TaskEntry[T] {T haszero} {
        var removed:Boolean;
        val hash:Int;
        var task:Task[T];
        def this(task:Task[T], h:Int) {
        	this.task = task;
            this.hash = h;
            this.removed = false;
        }
    }

	/** The actual table, must be of size 2**n */
    var table:Rail[TaskEntry[T]];

    /** Number of non-null, non-removed entries in the table. */
    var size:Long;

    /** Number of non-null entries in the table. */
    var occupation:Long;

    /** table.length - 1 */
    var mask:Long;

    var modCount:Long = 0; // to discover concurrent modifications

    static val MAX_PROBES = 3;
    static val MIN_SIZE = 4;

    public def this() {
        init(MIN_SIZE);
    }

    public def this(var sz:Long) {
        var pow2:Long = MIN_SIZE;
        while (pow2 < sz)
            pow2 <<= 1n;
        init(pow2);
    }

    @NonEscaping final def init(sz:Long):void {
        // check that sz is a power of 2
        assert (sz & -sz) == sz;
        assert sz >= MIN_SIZE;

        table = new Rail[TaskEntry[T]](sz);
        mask = sz - 1;
        size = 0;
        occupation = 0;
    }

    public def clear():void {
        modCount++;
        init(MIN_SIZE);
    }

    protected def hash(loc:Location):Int = hashInternal(loc);
    @NonEscaping protected final def hashInternal(loc:Location):Int {
        return loc.hash() * 17n;
    }

    public operator this(loc:Location):Task[T] = get(loc);

    public def get(loc:Location):Task[T] {
        val e = getEntry(loc);
        if (e == null || e.removed) return Zero.get[Task[T]]();
        return e.task;
    }

    protected def getEntry(loc:Location):TaskEntry[T] {
        if (size == 0)
            return null;

        val h = hash(loc);
        var i:Int = h;

        while (true) {
            val j = i & mask;
            i++;

            val e = table(j);
            if (e == null) {
                return null;
            }
            if (e != null) {
                if (e.hash == h && loc.equalsWith(e.task._loc)) {
                    return e;
                }
                if (i - h > table.size) {
                    return null;
                }
            }
        }
    }

    // public operator this(loc:Location)=(task:Task[T]):Task[T] = putInternal(Task[T], true);

    public def put(task:Task[T]) { putInternal(task, true); }
    @NonEscaping protected final def putInternal(task:Task[T], mayRehash:Boolean) {

        val h = hashInternal(task._loc);
        var i:Int = h;

        //Console.OUT.println("put task "+task._loc.i+","+task._loc.j);

        while (true) {
            val j = i & mask;
            i++;

            //Console.OUT.println("put task "+task._loc.i+","+task._loc.j+", hash:"+i);
            val e = table(j);
            if (e == null) {
                modCount++;
                table(j) = new TaskEntry(task, h);
                size++;
                occupation++;
                if (mayRehash && (((i - h > MAX_PROBES) && (occupation >= table.size / 2)) || (occupation == table.size))) {
                    Console.OUT.println("call rehash "+task._loc.i+","+task._loc.j);
                    rehashInternal();
                    Console.OUT.println("call rehash "+task._loc.i+","+task._loc.j+", finish");
                }
                //Console.OUT.println("put task "+task._loc.i+","+task._loc.j+" finish");
                return;
            } else if (e.hash == h && task._loc.equalsWith(e.task._loc)) {
                e.task = task;
                if(e.removed) {
                    e.removed = false;
                    size++;
                }
                //Console.OUT.println("put task "+task._loc.i+","+task._loc.j+" finish");
                return;
            }
        }
    }

    public def rehash():void { rehashInternal(); }
    @NonEscaping protected final def rehashInternal():void {
        modCount++;
        val t = table;
        val oldSize = size;
        table = new Rail[TaskEntry[T]](t.size*2);
        mask = table.size - 1;
        size = 0;
        occupation = 0;

        for (var i:Int = 0n; i < t.size; i++) {
            if (t(i) != null && ! t(i).removed) {
                putInternal(t(i).task, false);
            }
        }
        assert size == oldSize;
    }

    public def containsKey(loc:Location):Boolean {
        val e = getEntry(loc);
        return e != null && ! e.removed;
    }

    public def remove(loc:Location):Task[T] {
        modCount++;
        val e = getEntry(loc);
        if (e != null && ! e.removed) {
            size--;
            val res = e.task;
            e.removed = true;
            e.task = Zero.get[Task[T]]();
            return res;
        }
        return Zero.get[Task[T]]();
    }


    public def size():Long = size;


    /*
     * Custom deserialization
     */
    public def this(ds:Deserializer) {
        this();
        val numEntries = ds.readAny() as Long;
        for (1..numEntries) {
           putInternal(ds.readAny() as Task[T], true);
        }
    }

    /*
     * Custom serialization
     */
    public def serialize(s:Serializer) {
        s.writeAny(size());
        for(entry in table) {
            if(entry!=null && !entry.removed)
                s.writeAny(entry.task);
        }
    }
}