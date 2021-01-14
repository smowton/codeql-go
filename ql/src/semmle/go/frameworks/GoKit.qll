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

    private DataFlow::Node getAnEndpointFactoryResult() {
      exists(Function mkFn, FunctionOutput res |
        mkFn.getResultType(0).hasQualifiedName(endpointPackagePath(), "Endpoint") and
        result = res.getEntryNode(mkFn.getFuncDecl()).getAPredecessor*()
      )
    }

    private FuncDef getAnEndpointFunction() {
      exists(Function endpointFn | endpointFn.getFuncDecl() = result |
        endpointFn.getARead() = getAnEndpointFactoryResult()
      )
      or
      DataFlow::exprNode(result.(FuncLit)) = getAnEndpointFactoryResult()
    }

    private class EndpointRequest extends UntrustedFlowSource::Range {
      EndpointRequest() { this = DataFlow::parameterNode(getAnEndpointFunction().getParameter(1)) }
    }
  }
}
