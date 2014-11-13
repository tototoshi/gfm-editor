package controllers

import play.api._
import play.api.mvc._
import play.api.libs.oauth._
import models._
import com.github.tototoshi.play2.twitterauth._

object TwitterAuthController extends TwitterAuthController {

  val loginSuccessURL = routes.ApplicationController.index

  val loginDeniedURL = routes.ApplicationController.index

  val logoutURL = routes.ApplicationController.index

  def onAuthorizationSuccess(request: Request[AnyContent], token: RequestToken, user: TwitterUser): Result = {
    TwitterAccount.find(user.id) match {
      case Some(_) => redirectToLoginSuccessURL(request, token, user)
      case None =>
        if (TwitterAccount.list.isEmpty) {
          TwitterAccount.create(user.id, user.screenName, user.profileImageURL)
          redirectToLoginSuccessURL(request, token, user)
        } else {
          Forbidden("forbidden")
        }
    }
  }
}
