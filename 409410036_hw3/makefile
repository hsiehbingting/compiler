all: myChecker.g myChecker_test.java
	java -jar antlr-3.5.3-complete-no-st3.jar myChecker.g
	javac -cp antlr-3.5.3-complete-no-st3.jar:. *.java
clean: 
	rm -f *.tokens *.class myCheckerLexer* myCheckerParser* 