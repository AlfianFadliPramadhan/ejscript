/*
    Redirect tests
 */

const HTTP = (global.session && session["http"]) || ":6700"
var http: Http = new Http

test.skip("redirect")

/* MOB
http.get(HTTP + "/dir")
http.followRedirects = false
assert(http.status == 301)
http.followRedirects = true
http.get(HTTP + "/dir")
assert(http.status == 200)
http.close()

*/
