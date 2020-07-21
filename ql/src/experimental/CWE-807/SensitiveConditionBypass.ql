/**
 * @name User-controlled bypassing of sensitive action
 * @description This query tests for user-controlled bypassing
 *  of sensitive actions.
 * @id go/sensitive-condition-bypass
 * @kind problem
 * @problem.severity warning
 * @tags external/cwe/cwe-807
 *       external/cwe/cwe-247
 *       external/cwe/cwe-350
 */

import go
import SensitiveConditionBypass
import semmle.go.controlflow.ControlFlowGraphImpl

predicate isPostBodyNode(ControlFlow::Node node) {
  exists(ControlFlow::Node rNode, ReturnStmt r | rNode.isFirstNodeOf(r) |
    node = rNode.getASuccessor+()
  )
  or
  exists(ControlFlow::Node pNode, CallExpr ce |
    exists(ce.getTarget()) and not ce.getTarget().mayReturnNormally()
  |
    node = pNode.getASuccessor+()
  )
  or
  CFG::lastNode(any(FuncDef f).getBody(), node.getAPredecessor+())
}

predicate conditionGuardsConvergeAt(
  ControlFlow::ConditionGuardNode cgn, ControlFlow::ConditionGuardNode otherCgn,
  ReachableBasicBlock merge
) {
  cgn.getCondition() = otherCgn.getCondition() and
  cgn != otherCgn and
  cgn.getASuccessor*() = merge and
  otherCgn.getASuccessor*() = merge and
  // Convergeance isn't end-of-function-body
  not isPostBodyNode(merge.getFirstNode())
}

predicate conditionalArmsConverge(ControlFlow::ConditionGuardNode cgn) {
  conditionGuardsConvergeAt(cgn, _, _)
}

from
  ControlFlow::ConditionGuardNode guard, DataFlow::Node sensitiveSink,
  SensitiveExpr::Classification classification, Configuration config, DataFlow::PathNode source,
  DataFlow::PathNode operand, ComparisonExpr comp
where
  // there should be a flow between source and the operand sink
  config.hasFlowPath(source, operand) and
  // both the operand should belong to the same comparision expression
  operand.getNode().asExpr() = comp.getAnOperand() and
  // get the ConditionGuardNode corresponding to the comparision expr.
  guard.getCondition() = comp and
  // the sink `sensitiveSink` should be sensitive,
  isSensitive(sensitiveSink, classification) and
  // the guard should control the sink
  guard.dominates(sensitiveSink.getBasicBlock()) and
  // control-flow should converge after the comparison
  conditionalArmsConverge(guard)
select comp,
  "User-controlled input is compared against constant string $@, maybe bypassing sensitive operation $@.",
  comp.(ConstComparisonExpr).getConstOperand(), comp.(ConstComparisonExpr).getConstString(),
  sensitiveSink, sensitiveSink.toString()
