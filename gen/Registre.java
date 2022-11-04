// Josep Suy abril 2007



public class Registre  {

	String lexema;
	char tipus;
	long adreca;
	int constant;


public Registre() {
	lexema="";
	tipus='I';
	adreca=0;
	constant=0;
	}


public Registre(String l) {
	lexema=l;
	tipus='I';
	adreca=0;
	constant=0;
	}
public Registre(String l, char t) {
	lexema=l;
	tipus=t;
	adreca=0;
	constant=0;
	}
public Registre(String l, char t, long a) {
	lexema=l;
	tipus=t;
	adreca=a;
	constant=0;
	}
public Registre(String l, char t, long a, int c) {
	lexema=l;
	tipus=t;
	adreca=a;
	constant=c;
	}


public String getLexema() {
	return (lexema);
	}
public char getTipus() {
	return (tipus);
	}
public long getAdreca() {
	return (adreca);
	}
public long getConstant() {
	return (constant);
}

public void putLexema(String l) {
	lexema=l;
	}
public void putTipus(char t) {
	tipus=t;
	}
public void putAdreca(long a) {
	adreca=a;
}
public void putConstant(int c) {
		constant=c;
	}
}
