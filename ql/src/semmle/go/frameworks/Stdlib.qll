/**
 * Provides classes modeling security-relevant aspects of the standard libraries.
 */

import go
import semmle.go.frameworks.stdlib.ArchiveTar
import semmle.go.frameworks.stdlib.ArchiveZip
import semmle.go.frameworks.stdlib.Bufio
import semmle.go.frameworks.stdlib.Bytes
import semmle.go.frameworks.stdlib.CompressBzip2
import semmle.go.frameworks.stdlib.CompressFlate
import semmle.go.frameworks.stdlib.CompressGzip
import semmle.go.frameworks.stdlib.CompressLzw
import semmle.go.frameworks.stdlib.CompressZlib
import semmle.go.frameworks.stdlib.Fmt
import semmle.go.frameworks.stdlib.Mime
import semmle.go.frameworks.stdlib.MimeMultipart
import semmle.go.frameworks.stdlib.MimeQuotedprintable
import semmle.go.frameworks.stdlib.Encoding
import semmle.go.frameworks.stdlib.EncodingAscii85
import semmle.go.frameworks.stdlib.EncodingAsn1
import semmle.go.frameworks.stdlib.EncodingBase32
import semmle.go.frameworks.stdlib.EncodingBase64
import semmle.go.frameworks.stdlib.EncodingBinary
import semmle.go.frameworks.stdlib.EncodingCsv
import semmle.go.frameworks.stdlib.EncodingGob
import semmle.go.frameworks.stdlib.EncodingHex
import semmle.go.frameworks.stdlib.EncodingJson
import semmle.go.frameworks.stdlib.EncodingPem
import semmle.go.frameworks.stdlib.EncodingXml
import semmle.go.frameworks.stdlib.Html
import semmle.go.frameworks.stdlib.HtmlTemplate
import semmle.go.frameworks.stdlib.Log
import semmle.go.frameworks.stdlib.Io
import semmle.go.frameworks.stdlib.IoIoutil
import semmle.go.frameworks.stdlib.Errors
import semmle.go.frameworks.stdlib.Expvar
import semmle.go.frameworks.stdlib.Path
import semmle.go.frameworks.stdlib.PathFilepath
import semmle.go.frameworks.stdlib.Reflect
import semmle.go.frameworks.stdlib.Strconv
import semmle.go.frameworks.stdlib.Strings
import semmle.go.frameworks.stdlib.TextScanner
import semmle.go.frameworks.stdlib.TextTabwriter
import semmle.go.frameworks.stdlib.TextTemplate

/** A `String()` method. */
class StringMethod extends TaintTracking::FunctionModel, Method {
  StringMethod() {
    getName() = "String" and
    getNumParameter() = 0 and
    getResultType(0) = Builtin::string_().getType()
  }

  override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
    inp.isReceiver() and outp.isResult()
  }
}

/**
 * A model of the built-in `append` function, which propagates taint from its arguments to its
 * result.
 */
private class AppendFunction extends TaintTracking::FunctionModel {
  AppendFunction() { this = Builtin::append() }

  override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
    inp.isParameter(_) and outp.isResult()
  }
}

/**
 * A model of the built-in `copy` function, which propagates taint from its second argument
 * to its first.
 */
private class CopyFunction extends TaintTracking::FunctionModel {
  CopyFunction() { this = Builtin::copy() }

  override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
    inp.isParameter(1) and outp.isParameter(0)
  }
}

/** Provides models of commonly used functions in the `os` package. */
module OS {
  /**
   * A call to a function in `os` that accesses the file system.
   */
  private class OsFileSystemAccess extends FileSystemAccess::Range, DataFlow::CallNode {
    int pathidx;

    OsFileSystemAccess() {
      exists(string fn | getTarget().hasQualifiedName("os", fn) |
        fn = "Chdir" and pathidx = 0
        or
        fn = "Chmod" and pathidx = 0
        or
        fn = "Chown" and pathidx = 0
        or
        fn = "Chtimes" and pathidx = 0
        or
        fn = "Create" and pathidx = 0
        or
        fn = "Lchown" and pathidx = 0
        or
        fn = "Link" and pathidx in [0 .. 1]
        or
        fn = "Lstat" and pathidx = 0
        or
        fn = "Mkdir" and pathidx = 0
        or
        fn = "MkdirAll" and pathidx = 0
        or
        fn = "NewFile" and pathidx = 1
        or
        fn = "Open" and pathidx = 0
        or
        fn = "OpenFile" and pathidx = 0
        or
        fn = "Readlink" and pathidx = 0
        or
        fn = "Remove" and pathidx = 0
        or
        fn = "RemoveAll" and pathidx = 0
        or
        fn = "Rename" and pathidx in [0 .. 1]
        or
        fn = "Stat" and pathidx = 0
        or
        fn = "Symlink" and pathidx in [0 .. 1]
        or
        fn = "Truncate" and pathidx = 0
      )
    }

    override DataFlow::Node getAPathArgument() { result = getArgument(pathidx) }
  }

  /** The `Expand` function. */
  class Expand extends TaintTracking::FunctionModel {
    Expand() { hasQualifiedName("os", "Expand") }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isParameter(0) and outp.isResult()
    }
  }

  /** The `ExpandEnv` function. */
  class ExpandEnv extends TaintTracking::FunctionModel {
    ExpandEnv() { hasQualifiedName("os", "ExpandEnv") }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isParameter(0) and outp.isResult()
    }
  }

  /** The `os.Exit` function, which ends the process. */
  private class Exit extends Function {
    Exit() { hasQualifiedName("os", "Exit") }

    override predicate mayReturnNormally() { none() }
  }
}

/** Provides a class for modeling functions which convert strings into integers. */
module IntegerParser {
  /**
   * A function that converts strings into integers.
   *
   * Extend this class to model new APIs. If you want to refine existing API models,
   * extend `IntegerParser` instead.
   */
  abstract class Range extends Function {
    /**
     * Gets the maximum bit size of the return value, if this makes
     * sense, where 0 represents the bit size of `int` and `uint`.
     */
    int getTargetBitSize() { none() }

    /**
     * Gets the `FunctionInput` containing the maximum bit size of the
     * return value, if this makes sense. Note that if the value of the
     * input is 0 then it means the bit size of `int` and `uint`.
     */
    FunctionInput getTargetBitSizeInput() { none() }
  }
}

/** Provides models of commonly used functions in the `net/url` package. */
module URL {
  /** The `PathEscape` or `QueryEscape` function. */
  class Escaper extends TaintTracking::FunctionModel {
    Escaper() {
      hasQualifiedName("net/url", "PathEscape") or hasQualifiedName("net/url", "QueryEscape")
    }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isParameter(0) and outp.isResult()
    }
  }

  /** The `PathUnescape` or `QueryUnescape` function. */
  class Unescaper extends TaintTracking::FunctionModel {
    Unescaper() {
      hasQualifiedName("net/url", "PathUnescape") or hasQualifiedName("net/url", "QueryUnescape")
    }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isParameter(0) and outp.isResult(0)
    }
  }

  /** The `Parse`, `ParseQuery` or `ParseRequestURI` function, or the `URL.Parse` method. */
  class Parser extends TaintTracking::FunctionModel {
    Parser() {
      hasQualifiedName("net/url", "Parse") or
      this.(Method).hasQualifiedName("net/url", "URL", "Parse") or
      hasQualifiedName("net/url", "ParseQuery") or
      hasQualifiedName("net/url", "ParseRequestURI")
    }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isParameter(0) and
      outp.isResult(0)
      or
      this instanceof Method and
      inp.isReceiver() and
      outp.isResult(0)
    }
  }

  /** A method that returns a part of a URL. */
  class UrlGetter extends TaintTracking::FunctionModel, Method {
    UrlGetter() {
      exists(string m | hasQualifiedName("net/url", "URL", m) |
        m = "EscapedPath" or
        m = "Hostname" or
        m = "Port" or
        m = "Query" or
        m = "RequestURI"
      )
    }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isReceiver() and outp.isResult()
    }
  }

  /** The method `URL.MarshalBinary`. */
  class UrlMarshalBinary extends TaintTracking::FunctionModel, Method {
    UrlMarshalBinary() { hasQualifiedName("net/url", "URL", "MarshalBinary") }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isReceiver() and outp.isResult(0)
    }
  }

  /** The method `URL.ResolveReference`. */
  class UrlResolveReference extends TaintTracking::FunctionModel, Method {
    UrlResolveReference() { hasQualifiedName("net/url", "URL", "ResolveReference") }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      (inp.isReceiver() or inp.isParameter(0)) and
      outp.isResult()
    }
  }

  /** The function `User` or `UserPassword`. */
  class UserinfoConstructor extends TaintTracking::FunctionModel {
    UserinfoConstructor() {
      hasQualifiedName("net/url", "User") or
      hasQualifiedName("net/url", "UserPassword")
    }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isParameter(_) and outp.isResult()
    }
  }

  /** A method that returns a part of a Userinfo struct. */
  class UserinfoGetter extends TaintTracking::FunctionModel, Method {
    UserinfoGetter() {
      exists(string m | hasQualifiedName("net/url", "Userinfo", m) |
        m = "Password" or
        m = "Username"
      )
    }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isReceiver() and outp.isResult(0)
    }
  }

  /** A method that returns all or part of a Values map. */
  class ValuesGetter extends TaintTracking::FunctionModel, Method {
    ValuesGetter() {
      exists(string m | hasQualifiedName("net/url", "Values", m) |
        m = "Encode" or
        m = "Get"
      )
    }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isReceiver() and outp.isResult()
    }
  }
}

/** Provides models of commonly used APIs in the `regexp` package. */
module Regexp {
  private class Pattern extends RegexpPattern::Range, DataFlow::ArgumentNode {
    string fnName;

    Pattern() {
      exists(Function fn | fnName.matches("Match%") or fnName.matches("%Compile%") |
        fn.hasQualifiedName("regexp", fnName) and
        this = fn.getACall().getArgument(0)
      )
    }

    override DataFlow::Node getAParse() { result = this.getCall() }

    override string getPattern() { result = this.asExpr().getStringValue() }

    override DataFlow::Node getAUse() {
      fnName.matches("MustCompile%") and
      result = this.getCall().getASuccessor*()
      or
      fnName.matches("Compile%") and
      result = this.getCall().getResult(0).getASuccessor*()
      or
      result = this
    }
  }

  private class MatchFunction extends RegexpMatchFunction::Range, Function {
    MatchFunction() {
      exists(string fn | fn.matches("Match%") | this.hasQualifiedName("regexp", fn))
    }

    override FunctionInput getRegexpArg() { result.isParameter(0) }

    override FunctionInput getValue() { result.isParameter(1) }

    override FunctionOutput getResult() { result.isResult(0) }
  }

  private class MatchMethod extends RegexpMatchFunction::Range, Method {
    MatchMethod() {
      exists(string fn | fn.matches("Match%") | this.hasQualifiedName("regexp", "Regexp", fn))
    }

    override FunctionInput getRegexpArg() { result.isReceiver() }

    override FunctionInput getValue() { result.isParameter(0) }

    override FunctionOutput getResult() { result.isResult() }
  }

  private class ReplaceFunction extends RegexpReplaceFunction::Range, Method {
    ReplaceFunction() {
      exists(string fn | fn.matches("ReplaceAll%") | this.hasQualifiedName("regexp", "Regexp", fn))
    }

    override FunctionInput getRegexpArg() { result.isReceiver() }

    override FunctionInput getSource() { result.isParameter(0) }

    override FunctionOutput getResult() { result.isResult() }
  }
}

/** Provides models of some functions in the `crypto/cipher` package. */
module CryptoCipher {
  private class AeadOpenFunction extends TaintTracking::FunctionModel, Method {
    AeadOpenFunction() { this.hasQualifiedName("crypto/cipher", "AEAD", "Open") }

    override predicate hasTaintFlow(FunctionInput inp, FunctionOutput outp) {
      inp.isParameter(2) and
      outp.isResult(0)
    }
  }
}
