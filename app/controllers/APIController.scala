package controllers

import play.api._
import play.api.mvc._
import play.twirl.api.Html
import play.api.data.Form
import play.api.data.Forms._
import org.json4s._
import org.json4s.jackson.JsonMethods._
import com.github.tototoshi.play2.json4s.jackson._
import models._

object APIController extends Controller with Json4s {

  implicit val formats = DefaultFormats

  import org.pegdown._

  lazy val processor = new PegDownProcessor(Extensions.ALL)

  private def toHtml(md: String): String =
    processor.markdownToHtml(md)

  def index = Action {
    Ok(Extraction.decompose(Note.list))
  }

  def get(id: Long) = Action {
    Note.find(id).map { note =>
      Ok(Extraction.decompose(note))
    }.getOrElse(NotFound)
  }

  def markdown = Action { implicit request =>
    Form("raw" -> text).bindFromRequest.fold(
      formWithError => BadRequest,
      raw => Ok(Html(toHtml(raw)))
    )
  }

  def create = Action { implicit request =>
    val form = Form(tuple("raw" -> text, "title" -> nonEmptyText))
    form.bindFromRequest.fold(
      formWithError => BadRequest,
      formData => {
        val (raw, title) = formData
        val note = Note.create(raw, title)
        Ok(Extraction.decompose(note))
      }
    )
  }

  def update(id: Long) = Action(json) { implicit request =>
    val note = request.body.extract[Note]
    if (!note.title.isEmpty) {
      Note.update(note.id, note.title, note.raw)
    }
    Ok(Extraction.decompose(note))
  }

  def delete(id: Long) = Action { implicit request =>
    Note.delete(id)
    Ok(Extraction.decompose(Map("id" -> id)))
  }

}
