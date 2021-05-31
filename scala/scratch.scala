/* SimpleApp.scala */
import org.apache.spark.sql.SparkSession
import org.elasticsearch.spark.sql._


object scala_spark {

  case class Person(ID:Int, name:String, age:Int, numFriends:Int)

  def main(args: Array[String]) {
    
    val logFile = "/Users/markthekoala/Library/Mobile Documents/com~apple~CloudDocs/scala/scala_spark/fakefriends.csv"
    val spark = SparkSession.builder.appName("Something or other").getOrCreate()
    
    // needed for toDF()
    import spark.implicits._
    
    

    def mapper(line:String): Person = {
    val fields = line.split(',')
    val person : Person = Person(fields(0).toInt, fields(1), fields(2).toInt, fields(3).toInt)
    return person
    }

    val empDataFrame = Seq(("Alice", 24), ("Bob", 26)).toDF("name","age")

    // val logData = spark.read.textFile(logFile).cache()
    val lines = spark.sparkContext.textFile(logFile)
    val people = lines.map(mapper).toDF()
 
    people.collect.foreach(println)
    empDataFrame.collect.foreach(println)


  //  people.saveToEs("spark-friends")
    empDataFrame.saveToEs("testdf")

    
    spark.stop()
  } // main
} // object

libraryDependencies ++= Seq("org.apache.spark" %% "spark-sql" % "3.1.2", 
  "org.elasticsearch" %% "elasticsearch-spark-20" % "7.12.0" excludeAll ExclusionRule(organization = "org.apache.spark"))






# scala exists scala --version
# delete scala brew uninstall packageName
# install scala version specific brew install scala@2.11

# delete spark brew uninstall apache-spark



















