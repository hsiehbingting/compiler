all: myparser.g testParser.java
	java -jar antlr-3.5.3-complete-no-st3.jar myparser.g
	javac -cp antlr-3.5.3-complete-no-st3.jar:. *.java
clean: 
	rm -f *.class myparser.tokens myparserLexer.java myparserParser.java