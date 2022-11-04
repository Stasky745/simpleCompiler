import java.io.*;

import org.antlr.v4.runtime.*;


//Jordi LANS Compiler. Exemple de classe i metode main
public class main {
	

	public static void main(String args[]) throws Exception{
		if(args.length == 0){
			System.out.println("Es requereix un fitxer d'entrada");
			System.exit(0);
		}
		
		practica1Lexer lexer = new practica1Lexer(new ANTLRFileStream(args[0]));
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		practica1Parser p = new practica1Parser(tokens);
		p.main();
		if(p.getNumberOfSyntaxErrors()==0){
			System.out.println("No errors");
		}
		else
			System.out.println("Errors");
	}

}
