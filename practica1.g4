/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

grammar practica1;

@header {
    import java.io.*;
    import java.lang.Object;
    import java.util.Vector;
}

@members {
    SymTable TS = new SymTable<Registre>(1001);
    int contVar=0;
    Bytecode x;
    Boolean errorsem=false;
    Long saltLinia;
}

// Regla Sintactica: qualsevol token diferent de EOF
inici : (~EOF)+;

// Regles Lexiques

// COMENTARIS
COMENTARILLARG: '/*' (~'*')* '*'+ (~('/' | '*') (~'*')* '*'+)* '/' -> skip;
COMENTARI: '//' (~('\n'|'\r'))* -> skip;

// PARAULES_CLAU:
PC_PROGRAMA: 'programa';
PC_FI_PROGRAMA: 'fiprograma';
PC_CONSTANT: 'const';
PC_TIPUS: 'tipus';
PC_VAR: 'var';
PC_TUPLA: 'tupla';
PC_FI_TUPLA: 'fitupla';
PC_REAL: 'real';
PC_ENTER: 'enter';
PC_CARACTER: 'car';
PC_BOOL: 'boolea';
PC_ACCIO: 'accio';
PC_FI_ACCIO: 'fiaccio';
PC_FUNCIO: 'funcio';
PC_FI_FUNCIO: 'fifuncio';
PC_SI: 'si';
PC_LLAVORS: 'llavors';
PC_ALTRAMENT: 'altrament';
PC_FI_SI: 'fisi';
PC_PER: 'per';
PC_DE: 'de';
PC_FINS: 'fins';
PC_PAS: 'pas';
PC_FES: 'fes';
PC_FI_PER: 'fiper';
PC_RETORNA: 'retorna';
PC_LLEGEIX: 'llegeix';
PC_ESCRIU: 'escriu';
PC_ESCRIULN: 'escriuln';
PC_VECTOR: 'vector';
PC_INICI: 'inici';
PC_FI: 'fi';
PC_PE: 'pe';
PC_PES: 'pes';
PC_REPETEIX: 'repeteix';
PC_FINS_QUE: 'finsque';
PC_ES_CERT: 'escert';

// CONSTANTS:
CT_CERT: 'cert';
CT_FALS: 'fals';

CT_ENTER: DIGIT (DIGIT | '0')* | '0';
CT_CAR: '\'' '\u0000'..'\u007F' '\'';
CT_STRING: '"' (~('"'))* '"';
CT_REAL: (DIGIT ('.' (DIGIT | '0')+)? 'E' OP_MINUS? (DIGIT | '0')+) | ((DIGIT | '0')* '.' (DIGIT | '0')+);

// OPERADORS
OP_STAR: '*';
OP_PLUS: '+';
OP_MINUS: '-';
OP_DIV: '/';
OP_MOD: '%';
OP_PUNT: '.';
OP_ASSIGNACIO: ':=';
OP_MESPETITIGUAL: '<=';
OP_MESGRANIGUAL: '>=';
OP_DIFERENT: '!=';
OP_IGUAL: '==';
OP_MESPETIT: '<';
OP_MESGRAN: '>';
OP_LPAREN: '(';
OP_RPAREN: ')';
OP_LCLAUD: '[';
OP_RCLAUD: ']';
OP_I: '&';
OP_O: '|';
OP_NEGACIO: '~';
OP_NO: 'no';
OP_DIV_ENT: '\\';

// IDENTIFICADORS
fragment
DIGIT: '1'..'9';
fragment
LLETRA: 'a'..'z' | 'A'..'Z';
IDENT: ('_')* LLETRA (LLETRA | DIGIT | '0' | '_')*;

// ESPAIS:
WS: (' ' | '\t' | '\n' | '\r') -> skip;

// SEPARADORS:
SEP_SEMI: ';';
SEP_DOSPUNTS: ':';
SEP_COMA: ',';

/** SEMÀNTIC **/

//main: bdc* bdt* bdaf* PC_PROGRAMA IDENT bdv* sentencia* PC_FI_PROGRAMA iaf*;
main
@init {
  x=new Bytecode("compilat");
  saltLinia=x.addConstant("S","\n");
  Vector<Long> trad=new Vector<Long>(10);
}
:
bdc* bdt* bdaf* PC_PROGRAMA IDENT (b=bdv{trad.addAll($b.trad);})*
(sen=sentencia{trad.addAll($sen.trad);})* PC_FI_PROGRAMA iaf*
{
  if (!errorsem)
  {
    trad.add(x.RETURN);
    x.addMainCode(10L,10L,trad);
    x.write();
  }
}
;

//exprmenys1: expr0 ((OP_I | OP_O) expr0)*;
exprmenys1 returns [Vector<Long> trad, char tipus]
@init{
  $trad=new Vector<Long>(10);
}
:
e=expr0
{
  $trad=$e.trad;
  $tipus=$e.tipus;
}
(i=OP_I e0=expr0
  {
    if ($e.tipus=='B' && $e0.tipus=='B')
    {
      $trad=$e.trad;
      $trad.addAll($e0.trad);
      $trad.add(x.IAND);
      $tipus='B';
    }
    else
    {
        errorsem=true;
        System.out.println("Valor a 'I' no boolea. Linia: "+$i.line);
      $tipus='E';
    }
  }
  | o=OP_O e0=expr0
  {
    if ($e.tipus=='B' && $e0.tipus=='B')
    {
      $trad=$e.trad;
      $trad.addAll($e0.trad);
      $trad.add(x.IOR);
      $tipus='B';
    }
    else
    {
        errorsem=true;
        System.out.println("Valor a 'O' no boolea. Linia: "+$o.line);
      $tipus='E';
    }
  }
  )*
  ;

//expr0: expr ((OP_MESGRAN | OP_MESGRANIGUAL | OP_MESPETIT | OP_MESPETITIGUAL | OP_IGUAL | OP_DIFERENT) expr)?;
expr0 returns [Vector<Long> trad, char tipus]
@init{
  $trad=new Vector<Long>(10);
}
:
e=expr
{
  $trad=$e.trad;
  $tipus=$e.tipus;
}
(err=OP_MESPETITIGUAL e1=expr
  {
    if ($e.tipus==$e1.tipus)
		{
			$trad.addAll($e1.trad);
			if($e1.tipus=='R'){
                $trad.add(x.FCMPG);
                $trad.add(x.IFLE);
            }
            else{
                $trad.add(x.IF_ICMPLE);
            }
			Long salt=8L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(0L);
			$trad.add(x.GOTO);
			salt=5L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(1L);
			$tipus='B';
		}
		else
		{
		    errorsem=true;
            System.out.println("Tipus no iguals. Linia: "+$err.line);
			$tipus='E';
		}
  }
  | err=OP_MESPETIT e1=expr
  {
    if ($e.tipus==$e1.tipus)
		{
			$trad.addAll($e1.trad);
			if($e1.tipus=='R'){
                $trad.add(x.FCMPG);
                $trad.add(x.IFLT);
            }
            else{
                $trad.add(x.IF_ICMPLT);
            }
			Long salt=8L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(0L);
			$trad.add(x.GOTO);
			salt=5L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(1L);
			$tipus='B';
		}
		else
		{
		    errorsem=true;
            System.out.println("Tipus no iguals. Linia: "+$err.line);
			$tipus='E';
		}
  }
  | err=OP_MESGRANIGUAL e1=expr
  {
    if ($e.tipus==$e1.tipus)
		{
			$trad.addAll($e1.trad);
			if($e1.tipus=='R'){
                $trad.add(x.FCMPG);
                $trad.add(x.IFGE);
            }
            else{
                $trad.add(x.IF_ICMPGE);
            }
			Long salt=8L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(0L);
			$trad.add(x.GOTO);
			salt=5L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(1L);
			$tipus='B';
		}
		else
		{
		    errorsem=true;
            System.out.println("Tipus no iguals. Linia: "+$err.line);
			$tipus='E';
		}
  }
  | err=OP_MESGRAN e1=expr
  {
    if ($e.tipus==$e1.tipus)
		{
			$trad.addAll($e1.trad);
            if($e1.tipus=='R'){
                $trad.add(x.FCMPG);
                $trad.add(x.IFGT);
            }
            else{
                $trad.add(x.IF_ICMPGT);
            }
			Long salt=8L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(0L);
			$trad.add(x.GOTO);
			salt=5L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(1L);
			$tipus='B';
		}
		else
		{
		    errorsem=true;
            System.out.println("Tipus no iguals. Linia: "+$err.line);
			$tipus='E';
		}
  }
  | err=OP_IGUAL e1=expr
  {
    if ($e.tipus==$e1.tipus)
    {
        $trad.addAll($e1.trad);
        if($e1.tipus=='R'){
            $trad.add(x.FCMPG);
            $trad.add(x.IFEQ);
        }
        else{
            $trad.add(x.IF_ICMPEQ);
        }
        Long salt=8L;
        $trad.add(x.nByte(salt,2));
        $trad.add(x.nByte(salt,1));
        $trad.add(x.BIPUSH);
        $trad.add(0L);
        $trad.add(x.GOTO);
        salt=5L;
        $trad.add(x.nByte(salt,2));
        $trad.add(x.nByte(salt,1));
        $trad.add(x.BIPUSH);
        $trad.add(1L);
        $tipus='B';
    }
    else
    {
        errorsem=true;
        System.out.println("Tipus no iguals. Linia: "+$err.line);
        $tipus='E';
    }
  }
  | err=OP_MESPETIT e1=expr
  {
    if ($e.tipus==$e1.tipus)
		{
			$trad.addAll($e1.trad);
            if($e1.tipus=='R'){
                $trad.add(x.FCMPG);
                $trad.add(x.IFLT);
            }
            else{
                $trad.add(x.IF_ICMPLT);
            }
			Long salt=8L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(0L);
			$trad.add(x.GOTO);
			salt=5L;
			$trad.add(x.nByte(salt,2));
			$trad.add(x.nByte(salt,1));
			$trad.add(x.BIPUSH);
			$trad.add(1L);
			$tipus='B';
		}
		else
		{
		    errorsem=true;
            System.out.println("Tipus no iguals. Linia: "+$err.line);
			$tipus='E';
		}
  }
  | err=OP_DIFERENT e1=expr
    {
      if ($e.tipus==$e1.tipus)
        {
            $trad.addAll($e1.trad);
            if($e1.tipus=='R'){
                $trad.add(x.FCMPG);
                $trad.add(x.IFNE);
            }
            else{
                $trad.add(x.IF_ICMPNE);
            }
            Long salt=8L;
            $trad.add(x.nByte(salt,2));
            $trad.add(x.nByte(salt,1));
            $trad.add(x.BIPUSH);
            $trad.add(0L);
            $trad.add(x.GOTO);
            salt=5L;
            $trad.add(x.nByte(salt,2));
            $trad.add(x.nByte(salt,1));
            $trad.add(x.BIPUSH);
            $trad.add(1L);
            $tipus='B';
        }
        else
        {
            errorsem=true;
              System.out.println("Tipus no iguals. Linia: "+$err.line);
            $tipus='E';
        }
    }
  )?
  ;

//expr: expr2 ((OP_PLUS | OP_MINUS) expr2)*;
expr returns [Vector<Long> trad, char tipus]
@init{
  $trad=new Vector<Long>(10);
}
:
e2 = expr2
{
  $trad=$e2.trad;
  $tipus=$e2.tipus;
}
(err=OP_PLUS ex2=expr2
  {
    if (($e2.tipus=='I' || $e2.tipus=='R') && ($ex2.tipus=='I' || $ex2.tipus=='R'))
    {
      if($e2.tipus=='R' || $ex2.tipus=='R'){
        if($e2.tipus=='I'){
            $trad.add(x.I2F);
            $trad.addAll($ex2.trad);
        }
        else{
            $trad.addAll($ex2.trad);
            $trad.add(x.I2F);
        }
        $tipus='R';
        $trad.add(x.FADD);
      }
      else{
        $tipus='I';
        $trad.add(x.IADD);
      }
    }
    else
    {
        errorsem=true;
        System.out.println("Suma de tipus incorrectes. Linia: "+$err.line);
      $tipus='E';
    }
  }
  | err=OP_MINUS ex2=expr2
  {
    if (($e2.tipus=='I' || $e2.tipus=='R') && ($ex2.tipus=='I' || $ex2.tipus=='R'))
    {
      if($e2.tipus=='R' || $ex2.tipus=='R'){
        if($e2.tipus=='I'){
            $trad.add(x.I2F);
            $trad.addAll($ex2.trad);
        }
        else{
            $trad.addAll($ex2.trad);
            $trad.add(x.I2F);
        }
        $tipus='R';
        $trad.add(x.FSUB);
      }
      else{
        $trad.add(x.ISUB);
        $tipus='I';
      }
    }
    else
    {
        errorsem=true;
        System.out.println("Resta de tipus incorrectes. Linia: "+$err.line);
      $tipus='E';
    }
  }
  )*
  ;

//expr2: expr3 ((OP_STAR | OP_DIV | OP_DIV_ENT | OP_MOD) expr3)*;
expr2 returns [Vector<Long> trad, char tipus]
@init{
  $trad=new Vector<Long>(10);
}
:
e3=expr3
{
  $trad=$e3.trad;
  $tipus=$e3.tipus;
}
(err=OP_STAR ex3=expr3
  {
    if (($e3.tipus=='I' || $e3.tipus=='R') && ($ex3.tipus=='I' || $ex3.tipus=='R'))
    {
      if($e3.tipus=='R' || $ex3.tipus=='R'){
        if($e3.tipus=='I'){
            $trad.add(x.I2F);
            $trad.addAll($ex3.trad);
        }
        else if($ex3.tipus=='I'){
            $trad.addAll($ex3.trad);
            $trad.add(x.I2F);
        }
        else{
            $trad.addAll($ex3.trad);
        }
        $trad.add(x.FMUL);
        $tipus='R';
      }
      else{
        $trad.addAll($ex3.trad);
        $trad.add(x.IMUL);
        $tipus='I';
      }
    }
    else{
        errorsem=true;
        System.out.println("Multiplicacio de tipus incorrectes. Linia: "+$err.line);
        $tipus='E';
    }
  }
  | err=OP_DIV ex3=expr3
  {
    if (($e3.tipus=='I' || $e3.tipus=='R') && ($ex3.tipus=='I' || $ex3.tipus=='R'))
    {
      $trad=$e3.trad;
      if($e3.tipus=='I') $trad.add(x.I2F);
      $trad.addAll($ex3.trad);
      if($ex3.tipus=='I') $trad.add(x.I2F);
      $trad.add(x.FDIV);
      $tipus='R';
    }
    else
    {
        errorsem=true;
        System.out.println("Divisio de tipus incorrectes. Linia: "+$err.line);
      $tipus='E';
    }
  }
  | err=OP_DIV_ENT ex3=expr3
  {
    if (($e3.tipus=='I' || $e3.tipus=='R') && ($ex3.tipus=='I' || $ex3.tipus=='R'))
    {
      $trad=$e3.trad;
      if($e3.tipus=='F') $trad.add(x.F2I);
      $trad.addAll($ex3.trad);
      if($ex3.tipus=='F') $trad.add(x.F2I);
      $trad.add(x.IDIV);
      $tipus='I';
    }
    else
    {
        errorsem=true;
        System.out.println("Divisio entera de tipus incorrectes. Linia: "+$err.line);
      $tipus='E';
    }
  }
  | err=OP_MOD ex3=expr3
  {
    if (($e3.tipus=='I' || $e3.tipus=='R') && ($ex3.tipus=='I' || $ex3.tipus=='R'))
    {
      $trad=$e3.trad;
      if($e3.tipus=='I') $trad.add(x.I2F);
      $trad.addAll($ex3.trad);
      if($ex3.tipus=='I') $trad.add(x.I2F);
      $trad.add(x.FREM);
      $tipus='I';
    }
    else
    {
        errorsem=true;
        System.out.println("MOD de tipus incorrectes. Linia: "+$err.line);
      $tipus='E';
    }
  }
  )*
  ;

//expr3: (OP_NEGACIO | OP_NO)* exprbase; !!!!!!!!!!!!!!!!!!!!!!
expr3 returns [Vector<Long> trad, char tipus]
@init {
  $trad=new Vector<Long>(10);
  Boolean negat = false;
}
:
(err=OP_NO eb=exprbase
{
    if ($eb.tipus=='B')
    {
        $trad=$eb.trad;
        $trad.add(x.IFEQ);
        Long salt=8L;
        $trad.add(x.nByte(salt,2));
        $trad.add(x.nByte(salt,1));
        $trad.add(x.BIPUSH);
        $trad.add(0L);
        $trad.add(x.GOTO);
        salt=5L;
        $trad.add(x.nByte(salt,2));
        $trad.add(x.nByte(salt,1));
        $trad.add(x.BIPUSH);
        $trad.add(1L);
        $tipus='B';
    }
    else
    {
        errorsem=true;
        System.out.println("Negacio de tipus incorrecte. Linia: "+$err.line);
        $tipus='E';
    }
})
|((err=OP_NEGACIO{negat = true;})? eb=exprbase
{
  if(negat) {
    if ($eb.tipus=='I' || $eb.tipus=='R')
    {
      $trad=$eb.trad;
      $trad.add(x.ICONST_M1);
      $trad.add(x.IMUL);
        if($eb.tipus=='R'){
          $tipus='R';
        }
        else{
          $tipus='I';
        }
    }
    else
    {
      errorsem = true;
      System.out.println("Negació unària d'un tipus no acceptat. Linia: "+$err.line);
      $tipus='E';
    }
  }
  else{
    $trad=$eb.trad;
	$tipus=$eb.tipus;
  }
})
;

//exprbase: accesTupla | accesVector | valorTipusBasic | IDENT | OP_LPAREN exprmenys1 OP_RPAREN | cridaFuncio | CT_ENTER | CT_REAL;
exprbase returns [Vector<Long> trad, char tipus]
@init {
  $trad=new Vector<Long>(10);
}
:
at=accesTupla
{

}
| av=accesVector
{

}
| i=IDENT
{
  if (!(TS.existeix($i.text)))
  {
      errorsem=true;
      $tipus='E';
      System.out.println("No existeix variable. Linia: "+$i.line);
  }
  else{
      Registre r=(Registre)TS.obtenir($i.text);
      $tipus=r.getTipus();
      if(r.getConstant()==0){
          if (r.getTipus()=='I' || r.getTipus()=='C' || r.getTipus()=='B')
          {
              $trad.add(x.ILOAD);
              $trad.add(new Long(r.getAdreca()));
          }
          else if(r.getTipus()=='R')
          {
              $trad.add(x.FLOAD);
              $trad.add(new Long(r.getAdreca()));
          }
      }
      else{
          $trad.add(x.LDC_W);
          $trad.add(x.nByte(r.getAdreca(),2));
          $trad.add(x.nByte(r.getAdreca(),1));
      }
  }
}
| OP_LPAREN em1=exprmenys1 OP_RPAREN
{
  $trad=$em1.trad;
  $tipus=$em1.tipus;
}
| cf=cridaFuncio
{

}
| tb=valorTipusBasic
{
  $trad=$tb.trad;
  $tipus=$tb.tipus;
}
;

//sentencia: (assignacio | cridaAccio | rw) SEP_SEMI | (condicional | loop_for | loop_while);
sentencia returns [Vector<Long> trad]
@init 	{
	$trad=new Vector<Long>(10);
}
:
((a=assignacio
{
  $trad=$a.trad;
}
|varRW=rw
{
  $trad=$varRW.trad;
}
|cridaAccio
{}
)
SEP_SEMI)
|(con=condicional
{
    $trad=$con.trad;
}
|fr=loop_for
{
    $trad=$fr.trad;
}
|wh=loop_while
{
    $trad=$wh.trad;
}
);

//rw: llegir | escriure | escriure_ln;
rw returns [Vector<Long> trad]
@init 	{
	$trad=new Vector<Long>(10);
}
:
e=escriure
{
  $trad=$e.trad;
}
| eln=escriure_ln
{
    $trad=$eln.trad;
}
| ll=llegeix
{
    $trad=$ll.trad;
};

//escriure: PC_ESCRIU OP_LPAREN (CT_STRING | exprmenys1) (SEP_COMA (CT_STRING | exprmenys1))* OP_RPAREN;
escriure returns [Vector<Long> trad]
@init 	{
	$trad=new Vector<Long>(10);
}
:
PC_ESCRIU OP_LPAREN
(str=CT_STRING
{
	Long idStr = x.addConstant("S", $str.text.substring(1,$str.text.length()-1));
	$trad.add(x.LDC_W);
	$trad.add(x.nByte(idStr,2));
	$trad.add(x.nByte(idStr,1));
	$trad.add(x.INVOKESTATIC);
	$trad.add(x.nByte(x.mPutString,2));
	$trad.add(x.nByte(x.mPutString,1));
}
| ee=exprmenys1
{
    if ($ee.tipus != 'E')
    {
      $trad.addAll($ee.trad);
      $trad.add(x.INVOKESTATIC);
      if ($ee.tipus=='I')
      {
        $trad.add(x.nByte(x.mPutInt,2));
        $trad.add(x.nByte(x.mPutInt,1));
      }
      else if ($ee.tipus=='R')
     {
       $trad.add(x.nByte(x.mPutFloat,2));
       $trad.add(x.nByte(x.mPutFloat,1));
     }
     else if ($ee.tipus=='C')
      {
        $trad.add(x.nByte(x.mPutChar,2));
        $trad.add(x.nByte(x.mPutChar,1));
      }
      else
      {
        $trad.add(x.nByte(x.mPutBoolean,2));
        $trad.add(x.nByte(x.mPutBoolean,1));
      }
    }
}
  )
(SEP_COMA(str=CT_STRING
  {
  	Long idStr = x.addConstant("S", $str.text.substring(1,$str.text.length()-1));
    $trad.add(x.LDC_W);
    $trad.add(x.nByte(idStr,2));
    $trad.add(x.nByte(idStr,1));
    $trad.add(x.INVOKESTATIC);
    $trad.add(x.nByte(x.mPutString,2));
    $trad.add(x.nByte(x.mPutString,1));
  }
  | ee=exprmenys1
  {
      if ($ee.tipus != 'E')
      {
        $trad.addAll($ee.trad);
        $trad.add(x.INVOKESTATIC);
        if ($ee.tipus=='I')
        {
          $trad.add(x.nByte(x.mPutInt,2));
          $trad.add(x.nByte(x.mPutInt,1));
        }
        else if ($ee.tipus=='R')
           {
             $trad.add(x.nByte(x.mPutFloat,2));
             $trad.add(x.nByte(x.mPutFloat,1));
           }
       else if ($ee.tipus=='C')
            {
              $trad.add(x.nByte(x.mPutChar,2));
              $trad.add(x.nByte(x.mPutChar,1));
            }
        else
        {
          $trad.add(x.nByte(x.mPutBoolean,2));
          $trad.add(x.nByte(x.mPutBoolean,1));
        }
      }
  }
  )
  )*
OP_RPAREN;

//escriure_ln: PC_ESCRIULN OP_LPAREN ((CT_STRING | exprmenys1) (SEP_COMA (CT_STRING | exprmenys1))*)? OP_RPAREN;
escriure_ln returns [Vector<Long> trad]
@init 	{
	$trad=new Vector<Long>(10);
}
:
PC_ESCRIULN OP_LPAREN
((str=CT_STRING
{
	Long idStr = x.addConstant("S", $str.text.substring(1,$str.text.length()-1));
	$trad.add(x.LDC_W);
	$trad.add(x.nByte(idStr,2));
	$trad.add(x.nByte(idStr,1));
	$trad.add(x.INVOKESTATIC);
	$trad.add(x.nByte(x.mPutString,2));
	$trad.add(x.nByte(x.mPutString,1));
}
| ee=exprmenys1
{
    if ($ee.tipus != 'E')
    {
      $trad.addAll($ee.trad);
      $trad.add(x.INVOKESTATIC);
      if ($ee.tipus=='I')
      {
        $trad.add(x.nByte(x.mPutInt,2));
        $trad.add(x.nByte(x.mPutInt,1));
      }
      else if ($ee.tipus=='R')
     {
       $trad.add(x.nByte(x.mPutFloat,2));
       $trad.add(x.nByte(x.mPutFloat,1));
     }
     else if ($ee.tipus=='C')
      {
        $trad.add(x.nByte(x.mPutChar,2));
        $trad.add(x.nByte(x.mPutChar,1));
      }
      else
      {
        $trad.add(x.nByte(x.mPutBoolean,2));
        $trad.add(x.nByte(x.mPutBoolean,1));
      }
    }
}
  )
(SEP_COMA(str=CT_STRING
  {
  	Long idStr = x.addConstant("S", $str.text.substring(1,$str.text.length()-1));
    $trad.add(x.LDC_W);
    $trad.add(x.nByte(idStr,2));
    $trad.add(x.nByte(idStr,1));
    $trad.add(x.INVOKESTATIC);
    $trad.add(x.nByte(x.mPutString,2));
    $trad.add(x.nByte(x.mPutString,1));
  }
  | ee=exprmenys1
  {
      if ($ee.tipus != 'E')
      {
        $trad.addAll($ee.trad);
        $trad.add(x.INVOKESTATIC);
        if ($ee.tipus=='I')
        {
          $trad.add(x.nByte(x.mPutInt,2));
          $trad.add(x.nByte(x.mPutInt,1));
        }
        else if ($ee.tipus=='R')
           {
             $trad.add(x.nByte(x.mPutFloat,2));
             $trad.add(x.nByte(x.mPutFloat,1));
           }
       else if ($ee.tipus=='C')
            {
              $trad.add(x.nByte(x.mPutChar,2));
              $trad.add(x.nByte(x.mPutChar,1));
            }
        else
        {
          $trad.add(x.nByte(x.mPutBoolean,2));
          $trad.add(x.nByte(x.mPutBoolean,1));
        }
      }
  }
  )
  )*
  )?
  {
    $trad.add(x.LDC_W);
    $trad.add(x.nByte(saltLinia,2));
    $trad.add(x.nByte(saltLinia,1));
    $trad.add(x.INVOKESTATIC);
    $trad.add(x.nByte(x.mPutString,2));
    $trad.add(x.nByte(x.mPutString,1));
  }
OP_RPAREN;

//llegir: PC_LLEGEIX OP_LPAREN IDENT OP_RPAREN;
llegeix returns [Vector<Long> trad]
@init {
    $trad=new Vector<Long>(10);
}
:
err=PC_LLEGEIX OP_LPAREN i=IDENT OP_RPAREN
{
    if (!(TS.existeix($i.text)))
    {
        errorsem=true;
        System.out.println("No existeix variable del 'llegeix'. Linia: "+$i.line);
    }
    else{
        Registre r=(Registre)TS.obtenir($i.text);
        if(r.getConstant() == 1){
            errorsem=true;
            System.out.println("Intentant llegir per una constant. Linia: "+$err.line);
        }
        else{
            if(r.getTipus() != 'E'){
                if (r.getTipus()=='I')
                {
                    $trad.add(x.INVOKESTATIC);
                    $trad.add(x.nByte(x.mGetInt,2));
                    $trad.add(x.nByte(x.mGetInt,1));
                    $trad.add(x.ISTORE);
                    $trad.add(new Long(r.getAdreca()));
                }
                else if(r.getTipus()=='C'){
                    $trad.add(x.INVOKESTATIC);
                    $trad.add(x.nByte(x.mGetChar,2));
                    $trad.add(x.nByte(x.mGetChar,1));
                    $trad.add(x.ISTORE);
                    $trad.add(new Long(r.getAdreca()));
                }
                else if(r.getTipus()=='B'){
                    $trad.add(x.INVOKESTATIC);
                    $trad.add(x.nByte(x.mGetBoolean,2));
                    $trad.add(x.nByte(x.mGetBoolean,1));
                    $trad.add(x.ISTORE);
                    $trad.add(new Long(r.getAdreca()));
                }
                else if(r.getTipus()=='R'){
                    $trad.add(x.INVOKESTATIC);
                    $trad.add(x.nByte(x.mGetFloat,2));
                    $trad.add(x.nByte(x.mGetFloat,1));
                    $trad.add(x.FSTORE);
                    $trad.add(new Long(r.getAdreca()));
                }
            }
        }
    }
};

//valorTipusBasic: CT_CERT | CT_FALS | CT_CAR | CT_ENTER | CT_REAL;
valorTipusBasic returns [Vector<Long> trad, char tipus]
@init 	{
	$trad=new Vector<Long>(10);
}
:
CT_CERT
{
  $tipus = 'B';
  Long idE=x.addConstant("Z","Cert");
  $trad.add(x.LDC_W);
  $trad.add(x.nByte(idE,2));
  $trad.add(x.nByte(idE,1));
}
| CT_FALS
{
  $tipus = 'B';
  Long idE=x.addConstant("Z","Fals");
  $trad.add(x.LDC_W);
  $trad.add(x.nByte(idE,2));
  $trad.add(x.nByte(idE,1));
}
| car=CT_CAR
{
  $tipus = 'C';
  Long idE=x.addConstant("C",$car.text.substring(1,2));
  $trad.add(x.LDC_W);
  $trad.add(x.nByte(idE,2));
  $trad.add(x.nByte(idE,1));
}
| ent=CT_ENTER
{
  $tipus = 'I';
  Long idE=x.addConstant("I",$ent.text);
  $trad.add(x.LDC_W);
  $trad.add(x.nByte(idE,2));
  $trad.add(x.nByte(idE,1));
}
| real=CT_REAL
{
    $tipus = 'R';
    Long idR=x.addConstant("F",$real.text);
    $trad.add(x.LDC_W);
    $trad.add(x.nByte(idR,2));
    $trad.add(x.nByte(idR,1));
};

//assignacio: (IDENT | accesTupla | accesVector) OP_ASSIGNACIO exprmenys1;
assignacio returns [Vector<Long> trad]
@init 	{
	$trad=new Vector<Long>(10);
}
:
(i=IDENT | accesTupla | accesVector) OP_ASSIGNACIO ee=exprmenys1
{
    if (!(TS.existeix($i.text)))
    {
        errorsem=true;
        System.out.println("No existeix variable. Linia: "+$i.line);
    }
    else{
        Registre r=(Registre)TS.obtenir($i.text);
        if(r.getConstant() == 1)
        {
            errorsem=true;
            System.out.println("Intent d'assignar a una constant. Linia: "+$i.line);
        }
        else{
            if(r.getTipus() == $ee.tipus | (r.getTipus() == 'R' && $ee.tipus=='I')){
                if (r.getTipus()!='R')
                {
                    $trad=$ee.trad;
                    $trad.add(x.ISTORE);
                    $trad.add(new Long(r.getAdreca()));
                }
                else{
                    if(r.getTipus() == $ee.tipus){
                        $trad=$ee.trad;
                        $trad.add(x.FSTORE);
                        $trad.add(new Long(r.getAdreca()));
                    }
                    else{
                        $trad=$ee.trad;
                        $trad.add(x.I2F);
                        $trad.add(x.FSTORE);
                        $trad.add(new Long(r.getAdreca()));
                    }
                }
            }
        }
    }
}
;

//bdv: PC_VAR IDENT SEP_DOSPUNTS tipusValor SEP_SEMI;
bdv returns [Vector<Long> trad]
@init {
    $trad=new Vector<Long>(10);
}
:
PC_VAR i=IDENT SEP_DOSPUNTS tv=tipusValor SEP_SEMI
{
    if($tv.tipus != 'E'){
        if (!(TS.existeix($i.text)))
        {
            Registre r;
            r=new Registre($i.text,$tv.tipus,contVar++);
            TS.inserir($i.text,r);
            $trad.add(x.BIPUSH);
            $trad.add(0L);
            if($tv.tipus == 'R'){
                $trad.add(x.I2F);
                $trad.add(x.FSTORE);
                $trad.add(new Long(r.getAdreca()));
            }
            else{
                $trad.add(x.ISTORE);
                $trad.add(new Long(r.getAdreca()));
            }
        }
        else{
            errorsem=true;
            System.out.println("Es declara una variable que ja existeix. Linia: "+$i.line);
        }
    }
};

//bdc: PC_CONSTANT IDENT SEP_DOSPUNTS nomTipusBasic OP_ASSIGNACIO valorTipusBasic SEP_SEMI;
bdc
@init {}
:
PC_CONSTANT i=IDENT SEP_DOSPUNTS ntb=nomTipusBasic OP_ASSIGNACIO vtb=valorTipusBasic SEP_SEMI
{
    if($ntb.tipus!='E' && $vtb.tipus!='E'){
        if (!(TS.existeix($i.text)))
        {
            Registre r;
            if($ntb.tipus == $vtb.tipus){
                Long id;
                if($ntb.tipus=='R'){
                    id=x.addConstName($i.text,"F",$vtb.text);
                }
                else if($ntb.tipus=='B'){
                    id=x.addConstName($i.text,"Z",$vtb.text);
                }
                else{
                    id=x.addConstName($i.text,String.valueOf($ntb.tipus),$vtb.text);
                }
                r=new Registre($i.text,$vtb.tipus,id,1);
                TS.inserir($i.text,r);
            }
            else if($ntb.tipus == 'R' && $vtb.tipus == 'I'){
                Long id=x.addConstName($i.text,"F",$vtb.text+".0");
                r=new Registre($i.text,'R',id,1);
                TS.inserir($i.text,r);
            }
            else{
                errorsem=true;
                System.out.println("S'assigna a una constant un tipus basic no declarat. Linia: "+$i.line);
            }
        }
        else{
            errorsem=true;
            System.out.println("Es declara una constant que ja existeix. Linia: "+$i.line);
        }
    }
}
;

//tipusValor: nomTipusBasic | IDENT;
tipusValor returns [char tipus]
@init {}
:
ntp=nomTipusBasic
{
    $tipus=$ntp.tipus;
}
| i=IDENT
{
    if(TS.existeix($i.text)){
        Registre r=(Registre)TS.obtenir($i.text);
        if(r.getTipus()=='T') $tipus=r.getTipus();
        else
        {
            errorsem=true;
            System.out.println("L'identificador no és tipus 'tupla'. Linia: "+$i.line);
            $tipus='E';
        }
    }
    else{
        errorsem=true;
        System.out.println("L'identificador no existeix. Linia: "+$i.line);
        $tipus='E';
    }
};

//nomTipusBasic: PC_BOOL | PC_CARACTER | PC_ENTER | PC_REAL;
nomTipusBasic returns [char tipus]
@init 	{
$tipus='E';
}
:
b=PC_BOOL {$tipus='B';}
| c=PC_CARACTER {$tipus='C';}
| e=PC_ENTER {$tipus='I';}
| r=PC_REAL {$tipus='R';}
;

//condicional: PC_SI exprmenys1 PC_LLAVORS sentencia* (PC_ALTRAMENT sentencia*)? PC_FI_SI;
condicional returns [Vector<Long> trad]
@init 	{
    $trad=new Vector<Long>(10);
}
:
err=PC_SI ee=exprmenys1 {Vector<Long> trad2 = new Vector<Long>(10);Vector<Long> trad3 = new Vector<Long>(10);}
PC_LLAVORS (cc=sentencia {trad2.addAll($cc.trad);})* (PC_ALTRAMENT (cc2=sentencia {trad3.addAll($cc2.trad);})*)? PC_FI_SI
{
	if ($ee.tipus == 'B')
	{
		$trad=$ee.trad;
		$trad.add(x.IFEQ);
		Long salt=trad2.size()+6L;
		$trad.add(x.nByte(salt,2));
		$trad.add(x.nByte(salt,1));
		$trad.addAll(trad2);
		$trad.add(x.GOTO);
		salt=trad3.size()+3L;
		$trad.add(x.nByte(salt,2));
		$trad.add(x.nByte(salt,1));
		$trad.addAll(trad3);
	}
	else{
	    errorsem=true;
        System.out.println("Tipus d'expressio a 'SI' no boolea. Linia: "+$err.line);
	}
}
;

//loop_while: PC_REPETEIX sentencia* PC_FINS_QUE exprmenys1 PC_ES_CERT;
loop_while returns [Vector<Long> trad]
@init 	{
  $trad=new Vector<Long>(10);
}
:
PC_REPETEIX {Vector<Long> trad2 = new Vector<Long>(10);}
(cc=sentencia{trad2.addAll($cc.trad);})*
err=PC_FINS_QUE ee=exprmenys1
PC_ES_CERT
{
	if ($ee.tipus == 'B')
	{
	    $trad.addAll(trad2);
		$trad.addAll($ee.trad);
		$trad.add(x.IFNE);
		Long salt=6L;
		$trad.add(x.nByte(salt,2));
		$trad.add(x.nByte(salt,1));
		salt=0L-$trad.size();
		$trad.add(x.GOTO);
		$trad.add(x.nByte(salt,2));
		$trad.add(x.nByte(salt,1));
	}
	else{
        errorsem=true;
        System.out.println("Tipus d'expressio a 'REPETEIX' no boolea. Linia: "+$err.line);
    }
}
;

//loop_for: PC_PER IDENT PC_DE exprmenys1 PC_FINS exprmenys1 (PC_PAS exprmenys1)? PC_FES sentencia* PC_FI_PER;
loop_for returns [Vector<Long> trad]
@init 	{
  $trad=new Vector<Long>(10);
  Boolean exPas=false;
}
:
PC_PER {Vector<Long> trad2 = new Vector<Long>(10);}
i=IDENT PC_DE ini=exprmenys1 PC_FINS fi=exprmenys1 (PC_PAS pas=exprmenys1{exPas=true;})? PC_FES (s=sentencia{trad2.addAll($s.trad);})* PC_FI_PER
{
    if (!(TS.existeix($i.text)))
    {
        errorsem=true;
        System.out.println("No existeix variable del 'PER'. Linia: "+$i.line);
    }
    else{
        Registre r=(Registre)TS.obtenir($i.text);
        if(r.getConstant() == '1'){
            errorsem=true;
            System.out.println("Utilitzacio d'una constant en el 'PER'. Linia: "+$i.line);
        }
        else{
            if(r.getTipus() == 'I'){
                Long salt;
                $trad.addAll($ini.trad);
                $trad.add(x.ISTORE);
                $trad.add(new Long(r.getAdreca()));
                $trad.add(x.ILOAD);
                $trad.add(new Long(r.getAdreca()));
                $trad.addAll($fi.trad);

                if(exPas){
                    $trad.addAll($pas.trad);
                    $trad.add(x.IFGT);
                    salt=9L;
                    $trad.add(x.nByte(salt,2));
                    $trad.add(x.nByte(salt,1));

                    //pas negatiu
                    $trad.add(x.IF_ICMPLT); //Surt de rang (surt del per)
                    salt=15L+$pas.trad.size()+trad2.size();
                    $trad.add(x.nByte(salt,2));
                    $trad.add(x.nByte(salt,1));
                    salt=6L;
                    $trad.add(x.GOTO);
                    $trad.add(x.nByte(salt,2));
                    $trad.add(x.nByte(salt,1));

                    //pas positiu
                    $trad.add(x.IF_ICMPGT); //Surt de rang (surt del per)
                    salt=trad2.size()+$pas.trad.size()+9L;
                    $trad.add(x.nByte(salt,2));
                    $trad.add(x.nByte(salt,1));

                    $trad.addAll(trad2); //sentencia

                    $trad.add(x.ILOAD);
                    $trad.add(new Long(r.getAdreca()));
                    $trad.addAll($pas.trad);
                    $trad.add(x.IADD);

                    salt=0L-$pas.trad.size()-trad2.size()-$pas.trad.size()-$fi.trad.size()-19L;
                    $trad.add(x.GOTO);
                    $trad.add(x.nByte(salt,2));
                    $trad.add(x.nByte(salt,1));

                }
                else{
                    $trad.add(x.IF_ICMPGT); //Surt de rang (surt del per)
                    salt=trad2.size()+11L;
                    $trad.add(x.nByte(salt,2));
                    $trad.add(x.nByte(salt,1));

                    $trad.addAll(trad2);

                    $trad.add(x.ILOAD);
                    $trad.add(new Long(r.getAdreca()));
                    $trad.add(x.BIPUSH);
                    $trad.add(1L);
                    $trad.add(x.IADD);

                    salt=0L-trad2.size()-$fi.trad.size()-12L;
                    $trad.add(x.GOTO);
                    $trad.add(x.nByte(salt,2));
                    $trad.add(x.nByte(salt,1));
                }
            }
            else{
                errorsem=true;
                System.out.println("Variable del 'PER' no es entera. Linia: "+$i.line);
            }
        }
    }
}
;


accesTupla: IDENT OP_PUNT IDENT;
accesVector: IDENT OP_LCLAUD exprmenys1 OP_RCLAUD;

tipusVector: PC_VECTOR PC_DE nomTipusBasic PC_INICI CT_ENTER PC_FI CT_ENTER;
tipusTupla: PC_TUPLA campsTupla+ PC_FI_TUPLA;
campsTupla: IDENT SEP_DOSPUNTS nomTipusBasic SEP_SEMI;

decAccio: PC_ACCIO IDENT OP_LPAREN parFormalsAccio? OP_RPAREN;
decFuncio: PC_FUNCIO IDENT OP_LPAREN parFormalsFuncio? OP_RPAREN PC_RETORNA (OP_LPAREN nomTipusBasic OP_RPAREN | nomTipusBasic);
parFormalsAccio: (PC_PE | PC_PES)? IDENT SEP_DOSPUNTS tipusValor (SEP_COMA  (PC_PE | PC_PES)? IDENT SEP_DOSPUNTS tipusValor)*;
parFormalsFuncio: PC_PE? IDENT SEP_DOSPUNTS tipusValor (SEP_COMA PC_PE? IDENT SEP_DOSPUNTS tipusValor)*;

cridaAccio: IDENT OP_LPAREN (exprmenys1 (SEP_COMA exprmenys1)*)? OP_RPAREN;
cridaFuncio: IDENT OP_LPAREN (exprmenys1 (SEP_COMA exprmenys1)*)? OP_RPAREN;

impAccio: decAccio bdv* sentencia* PC_FI_ACCIO;
impFuncio: decFuncio bdv* sentencia* PC_RETORNA exprmenys1 SEP_SEMI PC_FI_FUNCIO;

bdt: PC_TIPUS IDENT SEP_DOSPUNTS (nomTipusBasic | tipusVector | tipusTupla) SEP_SEMI;
bdaf: (decAccio | decFuncio) SEP_SEMI;
iaf: impAccio | impFuncio;