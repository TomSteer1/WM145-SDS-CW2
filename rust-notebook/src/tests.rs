use super::rocket;
use rocket::local::blocking::Client;
use rocket::http::{ContentType, Status};
use rocket::uri;

#[test]
fn index() {
    let client = Client::tracked(rocket()).expect("valid rocket instance");
    let response = client.get(uri!(super::index)).dispatch();
    assert_eq!(response.status(), Status::Ok);

}

#[test]
fn add() {
    let status = Status::new(303);
    let client = Client::tracked(rocket()).unwrap();
    let response = client.post(uri!(super::add))
        .header(ContentType::Form)
        .body("note=This is a test")
        .dispatch();
    assert_eq!(response.status(), status);
}

#[test]
fn delete() {
    let status = Status::new(303);
    let client = Client::tracked(rocket()).expect("valid rocket instance");
    let response = client.post(uri!(super::delete))
        .header(ContentType::Form)
        .body("noteid=1")
        .dispatch();
    assert_eq!(response.status(), status)
}

