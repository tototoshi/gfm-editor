package models

import scalikejdbc._

case class Note(id: Long, title: String, raw: String)

object Note {

  def *(rs: WrappedResultSet): Note = Note(
    rs.long("id"),
    rs.string("title"),
    rs.string("raw")
  )

  def find(id: Long): Option[Note] = DB.readOnly { implicit session =>
    sql"SELECT * FROM note WHERE id = $id".map(*).single.apply()
  }

  def list: List[Note] = DB.readOnly { implicit session =>
    sql"SELECT * FROM note ORDER BY id DESC".map(*).list.apply()
  }

  def create(title: String, raw: String): Note = DB.localTx { implicit session =>
    val id = sql"INSERT INTO note (title, raw) VALUES ($title, $raw)".updateAndReturnGeneratedKey.apply()
    Note(id, title, raw)
  }

  def update(id: Long, title: String, raw: String): Note = DB.localTx { implicit session =>
    sql"UPDATE note SET title = $title, raw = $raw WHERE id = $id".update.apply()
    Note(id, title, raw)
  }

  def delete(id: Long): Unit = DB.localTx { implicit session =>
    sql"DELETE FROM note WHERE id = $id".update.apply()
  }

}
