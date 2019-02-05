package net.gomesh.test.bookinfogatlingtest

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._

class BasicSimulation extends Simulation {
  val numberOfUsers = Integer.getInteger("users", 1)
	val rampUpTime = java.lang.Long.getLong("ramp", 0L)
	val repetitions = Integer.getInteger("repetitions", 1).intValue()
	val baseUrl = System.getProperty("baseURL", "http://35.225.103.114:9080")
	val httpProtocol = http
		.baseUrl(baseUrl)
		.inferHtmlResources(BlackList(""".*.css""", """.*.js""", """.*.ico"""), WhiteList())
		.acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8")
		.acceptEncodingHeader("gzip, deflate")
		.acceptLanguageHeader("en-US,en;q=0.9")
		.upgradeInsecureRequestsHeader("1")
		.userAgentHeader("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36")

	val headers_0 = Map("Proxy-Connection" -> "keep-alive")

    val uri1 = "https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"
    val uri2 = "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5"

	val scn = scenario("BasicSimulation")
  	.repeat(repetitions, "n") {
			exec(http("request_0")
				.get("/productpage")
				.headers(headers_0))
		}

	setUp(scn.inject(rampUsers(numberOfUsers) during(rampUpTime seconds))).protocols(httpProtocol)
}