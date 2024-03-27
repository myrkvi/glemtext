import gleeunit
import gleeunit/should
import gleam/option.{None, Some}
import glemtext.{Blockquote, Heading, Link, ListItem, Preformatted, Text, parse}

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn single_listitem_test() {
  "* Hello"
  |> parse
  |> should.equal([ListItem("Hello")])
}

pub fn double_listitem_test() {
  "* Hello\n* World"
  |> parse
  |> should.equal([ListItem("Hello"), ListItem("World")])
}

pub fn single_listitem_then_empty_text_test() {
  "* Hello\n\n"
  |> parse
  |> should.equal([ListItem("Hello"), Text("")])
}

pub fn link_without_label_test() {
  "=> https://www.nrk.no/"
  |> parse
  |> should.equal([Link(to: "https://www.nrk.no/", label: None)])
}

pub fn link_with_label_test() {
  "=> https://en.wikipedia.org/ English Wikipedia"
  |> parse
  |> should.equal([
    Link(to: "https://en.wikipedia.org/", label: Some("English Wikipedia")),
  ])
}

pub fn link_with_label_spaces_between_test() {
  "=> https://en.wikipedia.org/        English Wikipedia"
  |> parse
  |> should.equal([
    Link(to: "https://en.wikipedia.org/", label: Some("English Wikipedia")),
  ])
}

pub fn link_with_label_tabs_between_test() {
  "=> https://en.wikipedia.org/\t\tEnglish Wikipedia"
  |> parse
  |> should.equal([
    Link(to: "https://en.wikipedia.org/", label: Some("English Wikipedia")),
  ])
}

pub fn preformatted_test() {
  "```\nHello!\n```"
  |> parse
  |> should.equal([Preformatted(alt: None, text: "Hello!")])
}

pub fn preformatted_alt_test() {
  "```md\nThis *is* just **some** Markdown\n```"
  |> parse
  |> should.equal([
    Preformatted(alt: Some("md"), text: "This *is* just **some** Markdown"),
  ])
}

pub fn preformatted_leading_space_test() {
  "```\n    Text with leading space.\n```"
  |> parse
  |> should.equal([
    Preformatted(alt: None, text: "    Text with leading space."),
  ])
}

pub fn preformatted_text_after_closing_test() {
  "```\nHello\nworld\n```shouldn't be here"
  |> parse
  |> should.equal([Preformatted(alt: None, text: "Hello\nworld")])
}

pub fn preformatted_unclosed_test() {
  "# Hello\n```\nunclosed block\n# World"
  |> parse
  |> should.equal([
    Heading(1, "Hello"),
    Preformatted(alt: None, text: "unclosed block\n# World"),
  ])
}

pub fn blockquote_test() {
  "> Hello, there!"
  |> parse
  |> should.equal([Blockquote("Hello, there!")])
}

pub fn heading1_test() {
  "# Heading"
  |> parse
  |> should.equal([Heading(1, "Heading")])
}

pub fn heading2_test() {
  "## Heading"
  |> parse
  |> should.equal([Heading(2, "Heading")])
}

pub fn heading3_test() {
  "### Heading"
  |> parse
  |> should.equal([Heading(3, "Heading")])
}

pub fn document_test() {
  "# My home page
Welcome to my home page! This is exciting!

I love many things:
* Gleam
* Gemini
* Data
* Functions

and many web sites:
=> /about             About me
=> /projects          Projects
=> https://gleam.run  Gleam's Home Page
=> https://hex.pm
=> https://hexdocs.pm

> Dunno
- lpil, \"The Gleam Programming Language\" Discord 2024-03-26"
  |> parse
  |> should.equal([
    Heading(1, "My home page"),
    Text("Welcome to my home page! This is exciting!"),
    Text(""),
    Text("I love many things:"),
    ListItem("Gleam"),
    ListItem("Gemini"),
    ListItem("Data"),
    ListItem("Functions"),
    Text(""),
    Text("and many web sites:"),
    Link(to: "/about", label: Some("About me")),
    Link(to: "/projects", label: Some("Projects")),
    Link(to: "https://gleam.run", label: Some("Gleam's Home Page")),
    Link(to: "https://hex.pm", label: None),
    Link(to: "https://hexdocs.pm", label: None),
    Text(""),
    Blockquote("Dunno"),
    Text("- lpil, \"The Gleam Programming Language\" Discord 2024-03-26"),
  ])
}
