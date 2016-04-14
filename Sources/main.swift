import BSON
import MongoKitten
import Vapor
import VaporZewoMustache

// Set up MongoKitten
let dbServer = try! MongoKitten.Server(at: "localhost")
try! dbServer.connect()

extension MongoKitten.Database : Vapor.StringInitializable {
    public convenience init?(from string: String) throws {
        self.init(database: string, at: dbServer)
    }
}

// Set up Vapor
let app = Application()
app.providers.append(VaporZewoMustache.Provider())

app.get("/") { request in
    let dbs = try dbServer.getDatabases()
    
    let dbListItems = dbs.map {
        return "<li><a href=\"/\($0.name)\">\($0.name)</a></li>"
    }
    
    return Response(status: .ok, html: "<!doctype html><html><body><ul>\(dbListItems.reduce("", combine: +))</ul></body></html>")
}

app.get(Database.self) { request, database in
    let colListItems = try database.getCollections().map { "<li>" + $0.name + "</li>" }
    return Response(status: .ok, html: "<!doctype html><html><body><ul>\(colListItems.reduce("", combine: +))</ul></body></html>")
}


app.start(port: 9090)