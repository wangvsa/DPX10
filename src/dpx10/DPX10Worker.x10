package dpx10;

import x10.util.*;
import x10.regionarray.*;
import dpx10.dag.*;
import dpx10.Configuration;
import dpx10.DPX10.DPX10App;

public class DPX10Worker[T]{T haszero} {

    public val _app:DPX10App[T];
    public val _dag:Dag[T];
    private transient val _scheduler:Scheduler[T];

    private transient var copyTasksTime:Long = 0;

    public var finishCount:Long = 0;

    public def this(app:DPX10App[T], dag:Dag[T]) {
        this._app = app;
        this._dag = dag;
        this._scheduler = new Scheduler[T](_dag);
    }


    // 开始调度本地的任务，由DPX10在各个Place调用
    public def execute() {

        checkFinishCount();
        val totalSize = _dag._distAllTasks.getLocalPortion().size;
        Console.OUT.println(here+" running on "+Runtime.getName()+", finishCount:"+finishCount+", totalCount:"+totalSize);

        var loop_count:Int = _dag._config.loopForSchedule;
        while(true) {

            // loop for one schedule
            loop_count = loop_count - 1n;
            if(loop_count == 0n) {
                scheduleReadyTasks();
                loop_count = _dag._config.loopForSchedule;
            }

            Runtime.probe();
            if(finishCount==totalSize)
                break;
            if(_dag._resilientFlag.getLocalOrCopy()())
                break;
        }

        Console.OUT.println(here+" copy tasks time:"+this.copyTasksTime+"ms");

    }

    /**
     * Chech the finishCount in case of the recover is complelted.
     */
    private def checkFinishCount() {
        val it = _dag._distAllTasks.getLocalPortion().iterator();
        while(it.hasNext()) {
            val node = _dag._distAllTasks(it.next());
            if(node._isFinish)
                finishCount++;
        }
    }


    private def scheduleReadyTasks() {
        if(_dag._localReadyTasks().isEmpty())
            return;

        // 批量执行任务

        val startTime = -System.currentTimeMillis();

        // more fast, dont use granularity any more
        val vidList = _dag.getAllReadyNodes();
        this.finishCount += vidList.size();

        /*
         * slow
        var count:Int = 0n;
        val vidList = new ArrayList[VertexId]();
        while(!_dag._localReadyTasks().isEmpty()) {
            val vid = _dag.getReadyNode();
            vidList.add(vid);
            this.finishCount++;
            count++;

            if(count==_dag._config.granularity)
                break;
        }
        */

        this.copyTasksTime += (System.currentTimeMillis() + startTime);



        if(!vidList.isEmpty()) {
            if(_dag._config.scheduleStrategy.equals(Configuration.SCHEDULE_LOCAL)) {
                // 本地调度
                async doTasks(vidList);
            } else if(_dag._config.scheduleStrategy.equals(Configuration.SCHEDULE_MINIMUM_COMM)) {
                // 最少依赖调度
                val place = _scheduler.leastDepdencySchedule(vidList);
                if(place==here)
                    async doTasks(vidList);
                else
                    async at(place) doTasks(vidList);
            } else if(_dag._config.scheduleStrategy.equals(Configuration.SCHEDULE_RANDOM)) {
                // 随机调度
                async at(Scheduler.randomSchedule()) doTasks(vidList);
            } else {
                Console.OUT.println("schedule:"+_dag._config.scheduleStrategy);
            }
        }
    }


    private def doTasks(vidList:ArrayList[VertexId]) {
        try {
            for(vid in vidList)
                work(vid.i, vid.j);
        } catch(e:DeadPlaceException) {
            _dag.setResilientFlag(true);
            Console.OUT.println("captured by Worker "+here);
        }
    }


    private def work(i:Int, j:Int) {
        //Console.OUT.println("work "+i+","+j+", "+here);
        var time:Long = -System.currentTimeMillis();

        val vertices = _dag.getDependentVertices(i, j);

        // do the real computing.
        val result = _app.compute(i, j, vertices);

        // set result and finish flag
        _dag.setResult(i, j, result);

        // 将依赖(i,j)的节点入度减一
        val vids = _dag.getAntiDependencies(i, j);

        for(vid in vids) {
            _dag.decrementIndegree(vid.i, vid.j);
        }

        time += System.currentTimeMillis();
        //Console.OUT.println("working...("+i+","+j+"), at "+here+", workerId:"+Runtime.workerId()+", result:"+result+", cost time:"+time+"ms");
    }

}
