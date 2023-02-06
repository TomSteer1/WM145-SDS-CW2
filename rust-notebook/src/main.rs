use rocket::form::Form;
use rocket::response::content::RawHtml;
use rocket::response::Redirect;
use rocket::{response::content::RawCss, *};
use rocket_dyn_templates::tera;
use rusqlite::{Connection, Result};

#[get("/")]
fn index() -> RawHtml<String> {
    let html: String = r#"
        <link rel="stylesheet" href="style.css">
        <h1>Rust Notebook</h1>
        <form method='POST' action='/add'>
        <label>Note: <input name='note' value=''></label>
        <button>Add</button>
        </form>
        <ul class='notes'>"#
        .to_owned();

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


#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index, serve_css])
}
