import org.elasticsearch.spark.sql._
case class Person(ID:Int, name:String, age:Int, numFriends:Int)

def mapper(line:String): Person = {
  val fields = line.split(',')
  val person:Person = Person(fields(0).toInt, fields(1), fields(2).toInt, fields(3).toInt)
  return person
}

import spark.implicits._

val lines = spark.sparkContext.textFile("fakefriends.csv")
val people = lines.map(mapper).toDF()

people.saveToEs("spark-friends")