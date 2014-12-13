package demo;

import x10.util.*;
import tada.*;
import tada.dag.*;
import tada.Tada.*;

public class WordCount extends TadaAppDP[HashMap[String,Int]] {

  // 假设有8段话
  public static articles:Rail[String] = ["Hello world", "hi nihao", "beatiful", "it is an apple",
                                "good morning", "morning", "hello world", "it is an orange"];

  public def compute(i:Int, j:Int, tasks:Rail[Task[HashMap[String, Int]]]):HashMap[String,Int]{
    // 第一层
    if(i==0n) {
        return countForString(articles(j));
    }

    // 最后一层(Reduce)
    val words = new HashMap[String, Int]();
    if(i==1n) {
      for(task in tasks) {
        val it = task.getResult().entries().iterator();
        while(it.hasNext()) {
          val entry = it.next();
          if(words.containsKey(entry.getKey())) {
            val count = entry.getValue()+1n;
            words.put(entry.getKey(), count);
          } else {
            words.put(entry.getKey(), entry.getValue());
          }
        }
      }
    }

    return words;
  }

  public def taskFinished(dag:Dag[HashMap[String, Int]]):void {
    Console.OUT.println("\nThr results:");
    // get the final result
    val result:HashMap[String, Int] = dag.getNode(1n, 0n).getResult();
    val it = result.entries().iterator();
    while(it.hasNext()) {
      val entry = it.next();
      Console.OUT.println(entry.getKey()+":"+entry.getValue());
    }
    Console.OUT.println();
  }


  private def countForString(str:String):HashMap[String, Int] {
    val wordsCount = new HashMap[String, Int]();
    val wordsRail = str.split(" ");
    for(word in wordsRail) {
      if(wordsCount.containsKey(word)) {
        val count = wordsCount(word);
        wordsCount.put(word, count+1n);
      } else {
        wordsCount.put(word, 1n);
      }
    }
    return wordsCount;
  }

}
