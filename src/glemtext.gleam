import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/list

/// A `Document` is a list of Gemtext elements. As Gemtext "elements"
/// are not nested, there is no need for a nested structure here, either.
///
/// As such, `Document` is a type alias to `List(GemElement)`
pub type Document =
  List(GemElement)

/// `GemElement` is an element, or possible line type for Gemtext.
pub type GemElement {
  /// `Text` is any text that doesn't have specific syntax for creating
  /// an element. Note that empty lines are `Text("")`
  Text(String)

  /// A link to another document, both Gemini and non-Gemini,
  /// and optionally, a label.
  Link(to: String, label: Option(String))
  Heading(level: Int, text: String)
  ListItem(String)
  Blockquote(String)
  Preformatted(alt: Option(String), text: String)
}

pub fn parse(text: String) -> Document {
  text
  |> string.replace("\r\n", "\n")
  |> string.to_graphemes
  |> parse_document([])
  |> list.reverse
}

fn parse_document(in: Chars, ast: Document) -> Document {
  case in {
    ["=", ">", ..rest] -> {
      let #(link, in) = parse_link(rest)
      parse_document(in, [link, ..ast])
    }

    ["*", " ", ..rest] -> {
      let #(item, in) = parse_list(rest)
      parse_document(in, [item, ..ast])
    }

    [">", ..rest] -> {
      let #(quote, in) = parse_blockquote(rest)
      parse_document(in, [quote, ..ast])
    }

    ["#", " ", ..rest] -> {
      let #(heading, in) = parse_heading(1, rest)
      parse_document(in, [heading, ..ast])
    }
    ["#", "#", " ", ..rest] -> {
      let #(heading, in) = parse_heading(2, rest)
      parse_document(in, [heading, ..ast])
    }
    ["#", "#", "#", " ", ..rest] -> {
      let #(heading, in) = parse_heading(3, rest)
      parse_document(in, [heading, ..ast])
    }

    ["`", "`", "`", ..rest] -> {
      let #(preformatted, in) = parse_preformatted(rest)
      parse_document(in, [preformatted, ..ast])
    }
    [] -> ast
    _ -> {
      let #(text, in) = parse_text(in)
      parse_document(in, [text, ..ast])
    }
  }
}

fn parse_blockquote(in: Chars) -> #(GemElement, Chars) {
  let #(line, rest) = get_line(in)
  let line =
    line
    |> drop_ws
    |> string.join("")

  #(Blockquote(line), rest)
}

fn parse_text(in: Chars) -> #(GemElement, Chars) {
  let #(line, rest) = get_line(in)
  let line = string.join(line, "")

  #(Text(line), rest)
}

fn parse_preformatted(in: Chars) -> #(GemElement, Chars) {
  let #(line, rest) = get_line(in)

  let alt =
    line
    |> drop_ws
    |> string.join("")

  let alt = case alt {
    "" -> None
    _ -> Some(alt)
  }

  let #(pre_lines, in) = take_preformatted_lines(rest)
  let pre_lines =
    pre_lines
    |> string.join("\n")

  #(Preformatted(alt: alt, text: pre_lines), in)
}

fn take_preformatted_lines(in: Chars) -> #(List(String), Chars) {
  let #(line, rest) = get_line(in)

  case line {
    ["`", "`", "`", ..rest] -> {
      let #(_, rest) = get_line(rest)
      #([], rest)
    }
    [] -> #([], [])
    _ -> {
      let #(next, in) = take_preformatted_lines(rest)
      let line =
        line
        |> string.join("")
      #([line, ..next], in)
    }
  }
}

fn parse_heading(level: Int, in: Chars) -> #(GemElement, Chars) {
  let #(line, rest) = get_line(in)
  let line =
    line
    |> drop_ws
    |> string.join("")

  #(Heading(level, line), rest)
}

fn parse_link(in: Chars) -> #(GemElement, Chars) {
  let #(line, rest) = get_line(in)

  let #(url, linerest) =
    line
    |> drop_ws
    |> list.split_while(fn(c) { !{ c == " " || c == "\t" } })

  let url = string.join(url, "")

  let label =
    linerest
    |> drop_ws
    |> string.join("")

  let label = case label {
    "" -> None
    _ -> Some(label)
  }

  #(Link(to: url, label: label), rest)
}

fn parse_list(in: Chars) -> #(GemElement, Chars) {
  let #(line, rest) = get_line(in)

  let line =
    line
    |> drop_ws
    |> string.join("")

  #(ListItem(line), rest)
}

fn get_line(in: Chars) -> #(Chars, Chars) {
  let line =
    in
    |> list.take_while(until_nl)

  let rest =
    in
    |> list.drop_while(until_nl)
    |> list.drop(1)

  #(line, rest)
}

fn until_nl(c) {
  c != "\n"
}

fn drop_lines(in: Chars) {
  case in {
    ["\n", ..rest] -> drop_lines(rest)
    _ -> in
  }
}

fn drop_ws(in: Chars) {
  case in {
    [" ", ..rest] -> drop_ws(rest)
    ["\t", ..rest] -> drop_ws(rest)
    _ -> in
  }
}

type Chars =
  List(String)
