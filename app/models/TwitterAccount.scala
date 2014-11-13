package models

import scalikejdbc._
import com.github.nscala_time.time.Imports._

case class TwitterAccount(
  id: Long,
  screenName: String,
  profileImageUrl: String)

object TwitterAccount {

  def *(rs: WrappedResultSet): TwitterAccount = TwitterAccount(
    rs.long("id"),
    rs.string("screen_name"),
    rs.string("profile_image_url")
  )

  def find(id: Long): Option[TwitterAccount] = DB.readOnly { implicit session =>
    sql"SELECT * FROM twitter_account WHERE id = $id".map(*).single.apply()
  }

  def list: List[TwitterAccount] = DB.readOnly { implicit session =>
    sql"SELECT * FROM twitter_account ORDER BY id DESC".map(*).list.apply()
  }

  def create(id: Long, screenName: String, profileImageUrl: String): TwitterAccount =
    DB.localTx { implicit session =>
      val sql =
        sql"""INSERT INTO twitter_account (id, screen_name, profile_image_url)
              VALUES ($id, $screenName, $profileImageUrl)
           """
      sql.update.apply()
      TwitterAccount(id, screenName, profileImageUrl)
    }

  def update(id: Long, screenName: String, profileImageUrl: String): TwitterAccount =
    DB.localTx { implicit session =>
      val sql =
        sql"""UPDATE twitter_account
              SET
                screenName = $screenName,
                profile_image_url = $profileImageUrl
              WHERE id = $id
           """
      sql.update.apply()
      TwitterAccount(id, screenName, profileImageUrl)
    }

}
