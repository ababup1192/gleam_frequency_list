import lustre
import lustre/element/html
import lustre/attribute
import lustre/element.{type Element}
import lustre/event
import gleam/string
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/dict
import gleam/pair
import gleam/int

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(text: String, frequency_list: List(#(String, Int)))
}

fn init(_flags) -> Model {
  let text =
    "The Bank of Japan on March 19 decided to scrap the world’s last negative rate policy, introducing a rate hike for the first time in 17 years. The historic move follows robust pay increases that have heightened the BOJ’s confidence that a healthy wage-price cycle is taking root in Japan.
      The central bank said in a statement released after its two-day policy meeting that such a cycle is more evident now, and “it came in sight that the price stability target of 2% would be achieved in a sustainable and stable manner” in the coming years.

        Yet BOJ Gov. Kazuo Ueda hinted that it would be some time before the central bank rolls out further rate hikes.
      "
  Model(text, frequency_list: to_frequency_list(text))
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  UpdateText(value: String)
}

fn update(_model: Model, msg: Msg) -> Model {
  case msg {
    UpdateText(text) -> {
      Model(text, to_frequency_list(text))
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.textarea(
      [event.on_input(UpdateText), attribute.rows(15), attribute.cols(100)],
      model.text,
    ),
    html.ul(
      [],
      model.frequency_list
        |> list.map(fn(frequency) {
          let #(word, count) = frequency
          html.li([], [
            html.text(word),
            html.text(" "),
            html.text(
              count
              |> int.to_string,
            ),
          ])
        }),
    ),
  ])
}

fn to_frequency_list(text: String) -> List(#(String, Int)) {
  text
  |> string.replace("\n", "")
  |> string.replace(".", " ")
  |> string.split(" ")
  |> list.filter(fn(x) { x != "" })
  |> list.map(string.lowercase)
  |> list.fold(dict.new(), fn(acc, word) { dict.update(acc, word, increment) })
  |> dict.to_list()
  |> list.sort(fn(a, b) { int.compare(pair.second(b), pair.second(a)) })
}

fn increment(x: Option(Int)) -> Int {
  case x {
    Some(i) -> i + 1
    None -> 1
  }
}
