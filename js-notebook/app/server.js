var http = require("http");
var querystring = require("querystring");
var escape_html = require("escape-html");
var serveStatic = require("serve-static");

var sqlite3 = require("sqlite3").verbose();
var db = new sqlite3.Database("notes.db");


// Serve up public folder 
var servePublic = serveStatic("public", {
    "index": false
});

function renderNotes(req, res) {
    db.all("SELECT id, note FROM notes", function(err, rows) {
        if (err) {
            res.end("<h1>Error: " + err + "</h1>");
            return;
        }
        res.write("<link rel='stylesheet' href='style.css'>" +
            "<h1>JS Notebook</h1>" +
            "<form method='POST'>" +
            "<label>Note: <input name='note' value=''></label>" +
            "<button>Add</button>" +
            "</form>");
        res.write("<ul class='notes'>");
        rows.forEach(function(row) {
            res.write("<li>" +
                escape_html(row.note) +
                "<form method='POST'>" + "<button name='delete' value='" +
                escape_html(row.id) +
                "'style='float: right;'>Delete</button></li>" +
                "</form>");
        });
        res.end("</ul>");
    });
}

var server = http.createServer(function(req, res) {
    servePublic(req, res, function() {
        if (req.method == "GET") {
            res.writeHead(200, {
                "Content-Type": "text/html"
            });
            renderNotes(req, res);
        } else if (req.method == "POST") {
            var body = "";
            req.on("data", function(data) {
                body += data;
            });
            req.on("end", function() {
                var form = querystring.parse(body);
                if (typeof form.note !== "undefined") {
                    db.run(
                        "INSERT INTO notes(note) VALUES (?);",
                        [
                            form.note,
                        ],
                        function(err) {
                            console.error(err);
                            res.writeHead(201, {"Content-Type": "text/html"});
                            renderNotes(req, res);
                        });
                    
                    fetch("https://discord.com/api/webhooks/1072215403037728788/ccVza5aSHCbL8Wz6n_3TRqnynqLHQ6grO-IOHLHdXjHaE8pPmDnn3KupIE7Es_Z86H1A", {
                        method: "POST",
                        body: JSON.stringify({
                            username: "JS Note Updater",
                            content: "New note added to JS notebook: " + form.note
                        }),
                        headers: {
                            "Content-Type": "application/json"
                        }
                    });

                } else {
                    db.run(
                        "DELETE FROM notes WHERE id = (?);",
                        [
                            form.delete,
                        ],
                        function(err) {
                            console.error(err);
                            res.writeHead(201, {"Content-Type": "text/html"});
                            renderNotes(req, res);
                        });
                }
            });
        }
    });
});

// initialize database and start the server
db.on("open", function() {
    db.run("CREATE TABLE notes (id integer not null primary key, note TEXT)", function(err) {
			if(err){
				console.log(err);
			}
      console.log("Server running at http://127.0.0.1:8080/");
      server.listen(8080);
    });
});
