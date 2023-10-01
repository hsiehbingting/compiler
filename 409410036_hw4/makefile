all: myCompiler.g myCompiler_test.java
	java -jar antlr-3.5.3-complete-no-st3.jar myCompiler.g
	javac -cp antlr-3.5.3-complete-no-st3.jar:. *.java
clean: 
	rm -f *.tokens *.class myCompilerLexer* myCompilerParser* 