/**
 * @name Wrong usage of package unsafe
 * @description Casting between types with different memory sizes can produce reads to
 *              memory locations that are after the target buffer, and/or unexpected values.
 * @kind path-problem
 * @problem.severity error
 * @id go/wrong-usage-of-unsafe
 * @tags security
 *       external/cwe/cwe-119
 *       external/cwe/cwe-126
 */

import go
import DataFlow::PathGraph

/* A conversion to a `unsafe.Pointer` */
class ConversionToUnsafePointer extends DataFlow::TypeCastNode {
  ConversionToUnsafePointer() { getType().getUnderlyingType() instanceof UnsafePointerType }
}

/* Type casting from a `unsafe.Pointer`.*/
class UnsafeTypeCastingConf extends TaintTracking::Configuration {
  UnsafeTypeCastingConf() { this = "UnsafeTypeCastingConf" }

  predicate isSource(DataFlow::Node source, ConversionToUnsafePointer conv) { source = conv }

  predicate isSink(DataFlow::Node sink, DataFlow::TypeCastNode ca) {
    ca.getOperand().getType() instanceof UnsafePointerType and
    sink = ca
  }

  override predicate isSource(DataFlow::Node source) { isSource(source, _) }

  override predicate isSink(DataFlow::Node sink) { isSink(sink, _) }
}

/**
 * Type casting from a smaller to a larger type through the use of unsafe pointers.
 */
predicate castToLargerType(DataFlow::PathNode source, DataFlow::PathNode sink, string message) {
  exists(
    UnsafeTypeCastingConf cfg, DataFlow::TypeCastNode castBig, ConversionToUnsafePointer castLittle
  |
    cfg.hasFlowPath(source, sink) and
    cfg.isSource(source.getNode(), castLittle) and
    cfg.isSink(sink.getNode(), castBig) and
    exists(int archIntAndPtrSize | archIntAndPtrSize = [32, 64] |
      getMaxReadableBytes(castBig, archIntAndPtrSize) >
        getMaxReadableBytes(castLittle.getOperand(), archIntAndPtrSize)
    ) and
    message =
      "Dangerous typecast to larger type: " + getUnderlyingObjectType(castLittle.getOperand()) +
        " to " + getUnderlyingObjectType(castBig)
  )
}

class IntSize extends int {
  IntSize() { this = [32, 64] }
}

int getNumericTypeSize(NumericType typ, IntSize archIntAndPtrSize) {
  // Return `typ`'s size, or `archIntAndPtrSize` if it is architecture-dependent (int, uint, uintptr)
  not exists(typ.getSize()) and
  result = archIntAndPtrSize
  or
  result = typ.getSize()
}

int getArrayTypeSize(ArrayType typ, IntSize archIntAndPtrSize) {
  result = typ.getLength() * getTypeSize(typ.getElementType(), archIntAndPtrSize)
}

int getTypeSize(Type type, IntSize archIntAndPtrSize) {
  (
    result = getArrayTypeSize(type, archIntAndPtrSize) or
    result = getNumericTypeSize(type, archIntAndPtrSize)
  )
}

Type getUnderlyingObjectType(DataFlow::Node node) {
  if exists(node.(DataFlow::AddressOperationNode).getOperand().(DataFlow::ElementReadNode))
  then
    result =
      node
          .(DataFlow::AddressOperationNode)
          .getOperand()
          .(DataFlow::ElementReadNode)
          .getBase()
          .getType()
  else result = node.getType().getUnderlyingType().(PointerType).getBaseType()
}

int getMaxReadableBytes(DataFlow::Node node, IntSize archIntAndPtrSize) {
  result = getTypeSize(getUnderlyingObjectType(node).getUnderlyingType(), archIntAndPtrSize)
}

from DataFlow::PathNode source, DataFlow::PathNode sink, string message
where castToLargerType(source, sink, message)
select sink.getNode(), source, sink, "$@.", source.getNode(), message
