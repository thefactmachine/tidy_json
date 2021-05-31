name := "Simple Project"

version := "1.0"

scalaVersion := "2.12.10"

libraryDependencies += "org.apache.spark" %% "spark-sql" % "3.1.2"


libraryDependencies ++= Seq(
    "org.apache.spark" %% "spark-core" % "3.1.2" % "compile",
    "org.apache.spark" %% "spark-sql" % "3.1.2" % "compile",
    "org.elasticsearch" %% "elasticsearch-spark-20" % "7.12.0" excludeAll ExclusionRule(organization = "org.apache.spark")
)
