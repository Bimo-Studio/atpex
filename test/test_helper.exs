# Path: test/test_helper.exs
File.mkdir_p!("test-results")

ExUnit.configure(
  formatters: [ExUnit.CLIFormatter, ExUnitJUnitFormatter],
  junit_report_dir: "test-results"
)

ExUnit.start()

