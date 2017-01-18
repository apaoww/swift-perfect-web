import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
        request, response in
        response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
        response.completed()
    }
)
public func useMysql(_ request: HTTPRequest, response: HTTPResponse) {

    // need to make sure something is available.
    guard dataMysql.connect(host: testHost, user: testUser, password: testPassword ) else {
        Log.info(message: "Failure connecting to data server \(testHost)")
        return
    }

    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }

    //set database to be used, this example assumes presence of a users table and run a raw query, return failure message on a error
    guard dataMysql.selectDatabase(named: testSchema) && dataMysql.query(statement: "select * from Fortune limit 10000") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")

        return
    }

    //store complete result set
    let results = dataMysql.storeResults()

    //setup an array to store results
    var resultArray = [[String?]]()

    while let row = results?.next() {
        resultArray.append(row)

    }

   //return array to http response
   response.appendBody(string: "<html><title>Mysql Test</title><body>\(resultArray)</body></html>")
    response.completed()

}

//This route will be used to fetch data from the mysql database
routes.add(method: .get, uri: "/use", handler: useMysql)

// Add the routes to the server.
server.addRoutes(routes)
// Set a listen port of 8181
server.serverPort = 8085

do {
    // Launch the HTTP server.
    try server.start()

} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

