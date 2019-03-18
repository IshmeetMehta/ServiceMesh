package net.gomesh.test.bookinfogatlingtest

import io.gatling.core.Predef._
import io.gatling.http.Predef._

class BasicSimulation extends Simulation {
  val numberOfUsers = Integer.getInteger("users", 10)
	val rampUpTime = java.lang.Long.getLong("ramp", 10L)
	val repetitions = Integer.getInteger("repetitions", 10).intValue()
	val baseUrl = System.getProperty("baseURL", "http://35.193.132.139:9080/productpage")
	val requestName = System.getProperty("requestName", "BookInfo")

	println(s"users: $numberOfUsers ramp: $rampUpTime reps; $repetitions baseUrl: $baseUrl")
	// -Dusers=10 -Dramp=10 -Drepetitions=10 -DbaseURL=http://35.188.22.194:9080/
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
			exec(http(requestName)
				.get("?u=normal")
				.headers(headers_0))
  			.exec(session => {
					println(s"users: $numberOfUsers ramp: $rampUpTime reps; $repetitions baseUrl: $baseUrl")
					session
				})
		}

	setUp(scn.inject(rampUsers(numberOfUsers) during(rampUpTime seconds))).protocols(httpProtocol)
}