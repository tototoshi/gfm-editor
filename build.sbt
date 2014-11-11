name := """gfm-editor"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.11.4"

libraryDependencies ++= Seq(
  jdbc,
  ws,
  filters,
  "org.twitter4j" % "twitter4j-core" % "4.0.2",
  "org.pegdown" % "pegdown" % "1.4.2",
  "com.github.nscala-time" %% "nscala-time" % "1.4.0",
  "com.github.tototoshi" %% "play-flyway" % "1.1.2",
  "org.postgresql" % "postgresql" % "9.3-1102-jdbc4",
  "org.scalikejdbc" %% "scalikejdbc" % "2.1.2",
  "org.scalikejdbc" %% "scalikejdbc-play-plugin" % "2.3.2",
  "com.github.tototoshi" %% "play-twitterauth" % "0.1.0-SNAPSHOT",
  "com.github.tototoshi" %% "play-json4s-jackson" % "0.3.0"
)
