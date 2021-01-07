/**
 * Provides classes for working with concepts relating to the [github.com/go-kit/kit](https://pkg.go.dev/github.com/go-kit/kit) package.
 */

import go

/**
 * Provides classes for working with concepts relating to the [github.com/go-kit/kit](https://pkg.go.dev/github.com/go-kit/kit) package.
 */
module GoKit {
  bindingset[result]
  string packagePath() { result = package("github.com/go-kit/kit", "") }

  module Endpoint {
    bindingset[result]
    string endpointPackagePath() { result = package("github.com/go-kit/kit", "endpoint") }

    private class EndpointRequest extends UntrustedFlowSource::Range {
      EndpointRequest() {
        exists(Function mkFn, FuncDef endpoint, FunctionOutput res |
          mkFn.getResultType(0).hasQualifiedName(endpointPackagePath(), "Endpoint") and
          res.isResult() and
          this = DataFlow::parameterNode(endpoint.getParameter(1))
        |
          exists(Function endpointFn | endpointFn.getFuncDecl() = endpoint |
            endpointFn.getARead().getASuccessor*() = res.getEntryNode(mkFn.getFuncDecl())
          )
          or
          exists(FuncLit endpointLit |
            DataFlow::exprNode(endpointLit).getASuccessor*() = res.getEntryNode(mkFn.getFuncDecl())
          )
        )
      }
    }
  }
}
