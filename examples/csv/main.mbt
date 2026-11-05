///|
fn main {
  try {
    let rows = @csv_reader.read(
      "name,note\nalpha,\"hello,world\"\nbeta,\"two\"\"quotes\"\n",
    )
    println(Json::Json(rows).stringify())
  } catch {
    error => println(@debug.to_string(error))
  }
}
