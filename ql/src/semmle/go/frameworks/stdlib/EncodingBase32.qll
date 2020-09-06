/**
 * Provides classes modeling security-relevant aspects of the `encoding/base32` package.
 */

import go

/** Provides models of commonly used functions in the `encoding/base32` package. */
module EncodingBase32 {
  private class FunctionModels extends TaintTracking::FunctionModel {
    FunctionInput inp;
    FunctionOutput outp;

    FunctionModels() {
      // signature: func NewDecoder(enc *Encoding, r io.Reader) io.Reader
      hasQualifiedName("encoding/base32", "NewDecoder") and
      (inp.isParameter(1) and outp.isResult())
      or
      // signature: func NewEncoder(enc *Encoding, w io.Writer) io.WriteCloser
      hasQualifiedName("encoding/base32", "NewEncoder") and
      (inp.isResult() and outp.isParameter(1))
    }

    override predicate hasTaintFlow(FunctionInput input, FunctionOutput output) {
      input = inp and output = outp
    }
  }

  private class MethodModels extends TaintTracking::FunctionModel, Method {
    FunctionInput inp;
    FunctionOutput outp;

    MethodModels() {
      // signature: func (*Encoding).Decode(dst []byte, src []byte) (n int, err error)
      this.hasQualifiedName("encoding/base32", "Encoding", "Decode") and
      (inp.isParameter(1) and outp.isParameter(0))
      or
      // signature: func (*Encoding).DecodeString(s string) ([]byte, error)
      this.hasQualifiedName("encoding/base32", "Encoding", "DecodeString") and
      (inp.isParameter(0) and outp.isResult(0))
      or
      // signature: func (*Encoding).Encode(dst []byte, src []byte)
      this.hasQualifiedName("encoding/base32", "Encoding", "Encode") and
      (inp.isParameter(1) and outp.isParameter(0))
      or
      // signature: func (*Encoding).EncodeToString(src []byte) string
      this.hasQualifiedName("encoding/base32", "Encoding", "EncodeToString") and
      (inp.isParameter(0) and outp.isResult())
    }

    override predicate hasTaintFlow(FunctionInput input, FunctionOutput output) {
      input = inp and output = outp
    }
  }
}
