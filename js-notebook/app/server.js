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
    db.all("SELECT rowid as id, note FROM notes", function(err, rows) {
        if (err) {
            res.end("<h1>Error: " + err + "</h1>");
            return;
        }
        res.write(`<link rel="stylesheet" href="style.css">
            <h1>JS Notebook</h1>
            <form method="POST">
            <label>Note: <input name="note" value=""></label>
            <input type="hidden" name="method" value="create">
            <button>Add</button>
            </form>`);
        res.write("<ul class='notes'>");
        rows.forEach(function(row) {
            res.write("<li>" + 
                escape_html(row.note) + 
                `<form method="POST">
                <input type="hidden" name="method" value="delete">
                <input type="hidden" name="id" value="${row.id}">
                <button>Delete</button>
                </form>
                </li>`);
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

                switch (form.method) {
                    case "create":
                        console.log(form.note);
                        if (form.note.length > 0) {
                            addNote(req, res, form.note);
                        } else {
                            res.writeHead(400, {"Content-Type": "text/html"});
                            res.end("<h1>Error: Note cannot be empty</h1>");
                            renderNotes(req, res);
                        }
                        break;
                    case "delete":
                        deleteNote(req, res, form.id);
                        break;
                    default:
                        res.writeHead(400, {"Content-Type": "text/html"});
                        res.end("<h1>Error: Invalid method</h1>");
                }
            });
        }
    });
});

function webhook(note) {
    fetch("https://discord.com/api/webhooks/1072215403037728788/ccVza5aSHCbL8Wz6n_3TRqnynqLHQ6grO-IOHLHdXjHaE8pPmDnn3KupIE7Es_Z86H1A", {
        method: "POST",
        body: JSON.stringify({
            username: "JS Note Updater",
            content: "New note added to JS notebook: " + note
        }),
        headers: {
            "Content-Type": "application/json"
        }
    });
}

function addNote(req, res, note) {
    db.run(
        "INSERT INTO notes(note) VALUES (?);",
        [
            note,
        ],
        function(err) {
            console.error(err);
            res.writeHead(201, {"Content-Type": "text/html"});
           // console.log(res.status);
            renderNotes(req, res);
        });
    webhook(note);
    }

function deleteNote(req, res, noteid) {
    db.run(
        "DELETE FROM notes WHERE rowid = (?);",
        [
            noteid,
        ],
        function(err) {
            console.error(err);
            res.writeHead(201, {"Content-Type": "text/html"});
            renderNotes(req, res);
        });
}

// initialize database and start the server
db.on("open", function() {
    db.run("CREATE TABLE IF NOT EXISTS notes (note TEXT)", function(err) {
			if(err){
				console.log(err);
			}
      console.log("Server running at http://127.0.0.1:8080/");
      server.listen(8080);
    });
});
