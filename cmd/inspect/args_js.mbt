///|
fn cli_args() -> Array[String] {
  // Node includes its own executable before the program name.
  let args = @env.args()
  args[args.length().min(1):].to_owned()
}
