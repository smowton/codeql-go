// Code generated by https://github.com/gagliardetto/codebox. DO NOT EDIT.

package main

import "sync"

func TaintStepTest_SyncMapLoad_B0I0O0(sourceCQL interface{}) interface{} {
	fromMap656 := sourceCQL.(sync.Map)
	intoInterface414, _ := fromMap656.Load(nil)
	return intoInterface414
}

func TaintStepTest_SyncMapLoadOrStore_B0I0O0(sourceCQL interface{}) interface{} {
	fromMap518 := sourceCQL.(sync.Map)
	intoInterface650, _ := fromMap518.LoadOrStore(nil, nil)
	return intoInterface650
}

func TaintStepTest_SyncMapLoadOrStore_B1I0O0(sourceCQL interface{}) interface{} {
	fromInterface784 := sourceCQL.(interface{})
	var intoMap957 sync.Map
	intoMap957.LoadOrStore(fromInterface784, nil)
	return intoMap957
}

func TaintStepTest_SyncMapLoadOrStore_B1I0O1(sourceCQL interface{}) interface{} {
	fromInterface520 := sourceCQL.(interface{})
	var mediumObjCQL sync.Map
	intoInterface443, _ := mediumObjCQL.LoadOrStore(fromInterface520, nil)
	return intoInterface443
}

func TaintStepTest_SyncMapLoadOrStore_B1I1O0(sourceCQL interface{}) interface{} {
	fromInterface127 := sourceCQL.(interface{})
	var intoMap483 sync.Map
	intoMap483.LoadOrStore(nil, fromInterface127)
	return intoMap483
}

func TaintStepTest_SyncMapLoadOrStore_B1I1O1(sourceCQL interface{}) interface{} {
	fromInterface989 := sourceCQL.(interface{})
	var mediumObjCQL sync.Map
	intoInterface982, _ := mediumObjCQL.LoadOrStore(nil, fromInterface989)
	return intoInterface982
}

func TaintStepTest_SyncMapRange_B0I0O0(sourceCQL interface{}) interface{} {
	fromMap417 := sourceCQL.(sync.Map)
	var intoFunckeyInterfaceValueInterfaceBool584 func(interface{}, interface{}) bool
	fromMap417.Range(intoFunckeyInterfaceValueInterfaceBool584)
	return intoFunckeyInterfaceValueInterfaceBool584
}

func TaintStepTest_SyncMapStore_B0I0O0(sourceCQL interface{}) interface{} {
	fromInterface991 := sourceCQL.(interface{})
	var intoMap881 sync.Map
	intoMap881.Store(fromInterface991, nil)
	return intoMap881
}

func TaintStepTest_SyncMapStore_B0I1O0(sourceCQL interface{}) interface{} {
	fromInterface186 := sourceCQL.(interface{})
	var intoMap284 sync.Map
	intoMap284.Store(nil, fromInterface186)
	return intoMap284
}

func TaintStepTest_SyncPoolGet_B0I0O0(sourceCQL interface{}) interface{} {
	fromPool908 := sourceCQL.(sync.Pool)
	intoInterface137 := fromPool908.Get()
	return intoInterface137
}

func TaintStepTest_SyncPoolPut_B0I0O0(sourceCQL interface{}) interface{} {
	fromInterface494 := sourceCQL.(interface{})
	var intoPool873 sync.Pool
	intoPool873.Put(fromInterface494)
	return intoPool873
}

func RunAllTaints_Sync() {
	{
		source := newSource(0)
		out := TaintStepTest_SyncMapLoad_B0I0O0(source)
		sink(0, out)
	}
	{
		source := newSource(1)
		out := TaintStepTest_SyncMapLoadOrStore_B0I0O0(source)
		sink(1, out)
	}
	{
		source := newSource(2)
		out := TaintStepTest_SyncMapLoadOrStore_B1I0O0(source)
		sink(2, out)
	}
	{
		source := newSource(3)
		out := TaintStepTest_SyncMapLoadOrStore_B1I0O1(source)
		sink(3, out)
	}
	{
		source := newSource(4)
		out := TaintStepTest_SyncMapLoadOrStore_B1I1O0(source)
		sink(4, out)
	}
	{
		source := newSource(5)
		out := TaintStepTest_SyncMapLoadOrStore_B1I1O1(source)
		sink(5, out)
	}
	{
		source := newSource(6)
		out := TaintStepTest_SyncMapRange_B0I0O0(source)
		sink(6, out)
	}
	{
		source := newSource(7)
		out := TaintStepTest_SyncMapStore_B0I0O0(source)
		sink(7, out)
	}
	{
		source := newSource(8)
		out := TaintStepTest_SyncMapStore_B0I1O0(source)
		sink(8, out)
	}
	{
		source := newSource(9)
		out := TaintStepTest_SyncPoolGet_B0I0O0(source)
		sink(9, out)
	}
	{
		source := newSource(10)
		out := TaintStepTest_SyncPoolPut_B0I0O0(source)
		sink(10, out)
	}
}
