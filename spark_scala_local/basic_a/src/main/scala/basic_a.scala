import org.apache.spark.SparkConf

import org.apache.spark.SparkContext    
import org.apache.spark.SparkContext._

import org.elasticsearch.spark._ 


object basic_a {
  def main(args: Array[String]) {

    println("Hello, world see if this has changed")

    val conf = new SparkConf().setAppName("basic_a").setMaster("local")

    conf.set("es.index.auto.create", "true")
    conf.set("es.port","9200")

    val sc = new SparkContext(conf)

    val numbers = Map("one" -> 1, "two" -> 2, "three" -> 3)
    val airports = Map("arrival" -> "Otopeni", "SFO" -> "San Fran")

    sc.makeRDD(Seq(numbers, airports)).saveToEs("spark/docs") 
    
    // this works
    // sc.makeRDD(Seq(numbers, airports))

    sc.stop()

  }
}
