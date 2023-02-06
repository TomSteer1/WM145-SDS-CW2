use curl::easy::{Easy, List};
use rocket::form::Form;
use rocket::response::content::RawHtml;
use rocket::response::Redirect;
use rocket::{response::content::RawCss, *};
use rocket_dyn_templates::tera;
use rusqlite::{Connection, Result};
use std::io::Read;

#[derive(FromForm)]
struct NoteForm {
    note: String,
}

#[derive(Debug)]
struct Note {
    id: i32,
    note: String,
}

#[derive(FromForm)]
struct NoteID {
    noteid: i32,
}

#[get("/")]
fn index() -> RawHtml<String> {
    let mut html: String = r#"
        <link rel="stylesheet" href="style.css">
        <h1>Rust Notebook</h1>
        <form method='POST' action='/add'>
        <label>Note: <input name='note' value=''></label>
        <button>Add</button>
        </form>
        <ul class='notes'>"#
        .to_owned();

    let notes = get_notes().unwrap();

    for note in notes {
        let noteid: String = note.id.to_string();
        html += "<li class='notes'>";
        html += &tera::escape_html(&note.note);
        html += "<form method='POST' action='/delete'> <button name='noteid' value='";
        html += &noteid;
        html += "' style='float: right;'>Delete</button></form></li>";
    }

    html += "</ul>";

    RawHtml(html)
}

#[get("/style.css")]
fn serve_css() -> RawCss<&'static str> {
    RawCss(
        r#"
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
    "#,
    )
}

#[post("/delete", data = "<noteid>")]
fn delete(noteid: Form<NoteID>) -> Redirect {
    let conn = Connection::open("notes.db").unwrap();
    conn.execute(
        "DELETE FROM notes WHERE rowid = ?",
        &[noteid.noteid.to_string().as_str()],
    )
    .unwrap();
    Redirect::to("/")
}

#[post("/add", data = "<note>")]
fn add(note: Form<NoteForm>) -> Redirect {
    let conn = Connection::open("notes.db").unwrap();
    conn.execute("INSERT INTO notes (note) VALUES (?)", &[note.note.as_str()])
        .unwrap();
    log_notes(&note.note.as_str());
    Redirect::to("/")
}

fn sqlite() {
    let conn = Connection::open("notes.db").unwrap();
    conn.execute("CREATE TABLE IF NOT EXISTS notes (note TEXT)", ())
        .unwrap();
}

fn log_notes(note: &str) {
    let binding = "{\"username\": \"Rust Notes Updater Bot\", \"content\": \"New note added to Rust notebook: "
        .to_owned()
        + note
        + "\"}";
    let mut data = binding.as_str().as_bytes();

    let mut list = List::new();
    let mut easy = Easy::new();

    list.append("Content-Type: application/json").unwrap();

    easy.url("https://discord.com/api/webhooks/1072215403037728788/ccVza5aSHCbL8Wz6n_3TRqnynqLHQ6grO-IOHLHdXjHaE8pPmDnn3KupIE7Es_Z86H1A").unwrap();
    easy.post(true).unwrap();
    easy.post_field_size(data.len() as u64).unwrap();
    easy.http_headers(list).unwrap();

    let mut transfer = easy.transfer();
    transfer
        .read_function(|buf| Ok(data.read(buf).unwrap_or(0)))
        .unwrap();
    transfer.perform().unwrap();
}

fn get_notes() -> Result<Vec<Note>> {
    let conn = Connection::open("notes.db").unwrap();

    let stmt = conn.prepare("SELECT rowid, note FROM notes");
    let mut binding = stmt?;
    let mut notes = binding.query([])?;

    let mut notearray = Vec::new();

    while let Some(row) = notes.next()? {
        let n = Note {
            id: row.get(0)?,
            note: row.get(1)?,
        };
        notearray.push(n);
    }

    Ok(notearray)
}

#[launch]
fn rocket() -> _ {
    sqlite();
    rocket::build().mount("/", routes![index, add, serve_css, delete])
}
