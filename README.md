# glemtext
A small library for parsing Gemini's gemtext.

[![Package Version](https://img.shields.io/hexpm/v/glemtext)](https://hex.pm/packages/glemtext)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glemtext/)

```sh
gleam add glemtext
```
```gleam
import gleam/io
import glemtext

pub fn main() {
  let body = "# My site
this is my site! thank you for visiting

=> /about     About me
=> /projects  Projects
=> https://en.wikipedia.org/ Wikipedia"

  body
  |> glemtext.parse
  |> io.debug
}
```

Further documentation can be found at <https://hexdocs.pm/glemtext>.

## Development

```sh
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
