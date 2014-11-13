package controllers

import com.github.tototoshi.play2.twitterauth._
import play.api._
import play.api.mvc._
import play.api.mvc.Results._
import models._

object Authorized {

  def apply[A](f: TwitterUser => Result)(implicit request: Request[A]): Result = {
    TwitterAuth.getAuthorizedUser(request).map(f).getOrElse {
      Redirect(routes.TwitterAuthController.login)
        .withSession("twitter.auth.redirect.url" -> request.uri)
    }
  }

  def apply[A](f: => Result)(implicit request: Request[A]): Result =
    apply(_ => f)(request)

}
