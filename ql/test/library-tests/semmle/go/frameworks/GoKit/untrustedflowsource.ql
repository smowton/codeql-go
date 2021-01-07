import go
import TestUtilities.InlineExpectationsTest

class UntrustedFlowSourceTest extends InlineExpectationsTest {
  UntrustedFlowSourceTest() { this = "untrustedflowsourcetest" }

  override string getARelevantTag() { result = "source" }

  override predicate hasActualResult(string file, int line, string element, string tag, string value) {
    exists(UntrustedFlowSource source |
      source.hasLocationInfo(file, line, _, _, _) and
      element = source.toString() and
      value = "" and
      tag = "source"
    )
  }
}
