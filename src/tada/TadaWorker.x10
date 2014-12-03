package tada;

import x10.util.*;
import x10.regionarray.*;
import tada.dag.*;
import tada.Tada.TadaApp;

public class TadaWorker[T]{T haszero} {
 
    public val _app:TadaApp[T];
    public val _dag:Dag[T];
    private transient val _scheduler:Scheduler[T];

    public var totalCount:Long = 0;

    public def this(app:TadaApp[T], dag:Dag[T]) {
        this._app = app;
        this._dag = dag;
        this._scheduler = new Scheduler[T](_dag);
    }


    // 开始调度本地的任务，由Tada在各个Place调用
    public def execute() {

        val totalSize = _dag._distAllTasks.getLocalPortion().size;

        Console.OUT.println(here+" running on "+Runtime.getName()+", task size:"+totalSize);

        while(true) {

            scheduleReadyTasks();

            Runtime.probe();
            if(totalCount==totalSize)
                break;
        }

        Console.OUT.println(here+" cache size:"+_dag._localCachedTasks().size());
    }


    private def scheduleReadyTasks() {
        val nullLoc = new Location(-9n, -9n);
        if(_dag._localReadyTasks().isEmpty())
            return;

        // 批量执行任务
        val locList = new ArrayList[Location]();
        while(!_dag._localReadyTasks().isEmpty()) {
            //val loc = _dag.addAndGet(nullLoc);
            val loc = _dag.getReadyNode();
            locList.add(loc);
            totalCount++;
        }

        if(!locList.isEmpty()) {
            // 随机调度
            // async at(Scheduler.randomSchedule()) doTasks(locList);
            // 本地调度
            // async doTasks(locList);
            // 最少依赖调度
            val place = _scheduler.leastDepdencySchedule(locList);
            if(place==here)
                async doTasks(locList);
            else {
                Console.OUT.println(here+" change to "+place+", task size:"+locList.size());
                async at(place) doTasks(locList);
            }
        }
    }

    
    private def doTasks(locList:ArrayList[Location]) {
        for(loc in locList)
            work(loc.i, loc.j);
    }


    private def work(i:Int, j:Int) {
        _dag._localActivityCount().incrementAndGet();

        var time:Long = -System.currentTimeMillis();
        
        val tasks = _dag.getDependencyTasks(i, j);

        // do the real computing.
        val result = _app.compute(i, j, tasks);

        // set result and finish flag
        _dag.setResult(i, j, result);

        // 将依赖(i,j)的节点入度减一
        val locs = _dag.getAntiDependencyTasksLocation(i, j);
        for(loc in locs) {
            _dag.decrementIndegree(loc.i, loc.j);
        }

        time += System.currentTimeMillis();
        Console.OUT.println("working...("+i+","+j+"), at "+here+", workerId:"+Runtime.workerId()+", result:"+result+", cost time:"+time+"ms");

        _dag._localActivityCount().incrementAndGet();
    }


}
