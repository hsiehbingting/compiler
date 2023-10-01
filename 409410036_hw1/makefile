all: mylexer.g testLexer.java
	java -jar ../antlr-3.5.3-complete-no-st3.jar mylexer.g
	javac -cp ../antlr-3.5.3-complete-no-st3.jar:. *.java
clean: 
	rm -f *.class mylexer.java mylexer.tokens
	