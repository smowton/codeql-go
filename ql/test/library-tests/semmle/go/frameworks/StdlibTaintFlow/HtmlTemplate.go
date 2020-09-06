// Code generated by https://github.com/gagliardetto/codebox. DO NOT EDIT.

package main

import (
	"html/template"
	"io"
)

func TaintStepTest_HtmlTemplateHTMLEscape_B0I0O0(sourceCQL interface{}) interface{} {
	fromByte656 := sourceCQL.([]byte)
	var intoWriter414 io.Writer
	template.HTMLEscape(intoWriter414, fromByte656)
	return intoWriter414
}

func TaintStepTest_HtmlTemplateHTMLEscapeString_B0I0O0(sourceCQL interface{}) interface{} {
	fromString518 := sourceCQL.(string)
	intoString650 := template.HTMLEscapeString(fromString518)
	return intoString650
}

func TaintStepTest_HtmlTemplateHTMLEscaper_B0I0O0(sourceCQL interface{}) interface{} {
	fromInterface784 := sourceCQL.(interface{})
	intoString957 := template.HTMLEscaper(fromInterface784)
	return intoString957
}

func TaintStepTest_HtmlTemplateJSEscape_B0I0O0(sourceCQL interface{}) interface{} {
	fromByte520 := sourceCQL.([]byte)
	var intoWriter443 io.Writer
	template.JSEscape(intoWriter443, fromByte520)
	return intoWriter443
}

func TaintStepTest_HtmlTemplateJSEscapeString_B0I0O0(sourceCQL interface{}) interface{} {
	fromString127 := sourceCQL.(string)
	intoString483 := template.JSEscapeString(fromString127)
	return intoString483
}

func TaintStepTest_HtmlTemplateJSEscaper_B0I0O0(sourceCQL interface{}) interface{} {
	fromInterface989 := sourceCQL.(interface{})
	intoString982 := template.JSEscaper(fromInterface989)
	return intoString982
}

func TaintStepTest_HtmlTemplateURLQueryEscaper_B0I0O0(sourceCQL interface{}) interface{} {
	fromInterface417 := sourceCQL.(interface{})
	intoString584 := template.URLQueryEscaper(fromInterface417)
	return intoString584
}

func TaintStepTest_HtmlTemplateTemplateExecute_B0I0O0(sourceCQL interface{}) interface{} {
	fromInterface991 := sourceCQL.(interface{})
	var intoWriter881 io.Writer
	var mediumObjCQL template.Template
	mediumObjCQL.Execute(intoWriter881, fromInterface991)
	return intoWriter881
}

func TaintStepTest_HtmlTemplateTemplateExecuteTemplate_B0I0O0(sourceCQL interface{}) interface{} {
	fromInterface186 := sourceCQL.(interface{})
	var intoWriter284 io.Writer
	var mediumObjCQL template.Template
	mediumObjCQL.ExecuteTemplate(intoWriter284, "", fromInterface186)
	return intoWriter284
}

func RunAllTaints_HtmlTemplate() {
	{
		source := newSource(0)
		out := TaintStepTest_HtmlTemplateHTMLEscape_B0I0O0(source)
		sink(0, out)
	}
	{
		source := newSource(1)
		out := TaintStepTest_HtmlTemplateHTMLEscapeString_B0I0O0(source)
		sink(1, out)
	}
	{
		source := newSource(2)
		out := TaintStepTest_HtmlTemplateHTMLEscaper_B0I0O0(source)
		sink(2, out)
	}
	{
		source := newSource(3)
		out := TaintStepTest_HtmlTemplateJSEscape_B0I0O0(source)
		sink(3, out)
	}
	{
		source := newSource(4)
		out := TaintStepTest_HtmlTemplateJSEscapeString_B0I0O0(source)
		sink(4, out)
	}
	{
		source := newSource(5)
		out := TaintStepTest_HtmlTemplateJSEscaper_B0I0O0(source)
		sink(5, out)
	}
	{
		source := newSource(6)
		out := TaintStepTest_HtmlTemplateURLQueryEscaper_B0I0O0(source)
		sink(6, out)
	}
	{
		source := newSource(7)
		out := TaintStepTest_HtmlTemplateTemplateExecute_B0I0O0(source)
		sink(7, out)
	}
	{
		source := newSource(8)
		out := TaintStepTest_HtmlTemplateTemplateExecuteTemplate_B0I0O0(source)
		sink(8, out)
	}
}
