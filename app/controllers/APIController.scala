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



  private def toHtml(md: String): String = {
    val processor = new PegDownProcessor(Extensions.ALL)
    processor.markdownToHtml(md)
  }

  def index = Action { implicit request =>
    Authorized {
      Ok(Extraction.decompose(Note.list))
    }
  }

  def get(id: Long) = Action { implicit request =>
    Authorized {
      Note.find(id).map { note =>
        Ok(Extraction.decompose(note))
      }.getOrElse(NotFound)
    }
  }

  def markdown = Action { implicit request =>
    Authorized {
      Form("raw" -> text).bindFromRequest.fold(
        formWithError => BadRequest,
        raw => Ok(Html(toHtml(raw)))
      )
    }
  }

  def create = Action { implicit request =>
    Authorized {
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
  }

  def update(id: Long) = Action(json) { implicit request =>
    Authorized {
      val note = request.body.extract[Note]
      if (!note.title.isEmpty) {
        Note.update(note.id, note.title, note.raw)
      }
      Ok(Extraction.decompose(note))
    }
  }

  def delete(id: Long) = Action { implicit request =>
    Authorized {
      Note.delete(id)
      Ok(Extraction.decompose(Map("id" -> id)))
    }
  }

}
