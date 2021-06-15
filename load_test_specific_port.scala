//  import org.apache.spark.SparkContext._
import org.elasticsearch.spark.sql._
import spark.implicits._

// structure for each row
case class AlbumIndex(artist:String, yearOfRelease:Int, albumName: String)

// create a data frame 
val indexDocuments = Seq(
    AlbumIndex("Led Zeppelin",1969,"Led Zeppelin"),
    AlbumIndex("Boston",1976,"Boston"),
    AlbumIndex("Fleetwood Mac", 1979,"Tusk")
).toDF

// save data frame to ES to the index "demoindex"
indexDocuments.saveToEs("demoindex")