package controllers

import play.api._
import play.api.mvc._

object ApplicationController extends Controller {

  def index = Action { implicit request =>
    Authorized {
      Ok(views.html.index("Your new application is ready."))
    }
  }

}
