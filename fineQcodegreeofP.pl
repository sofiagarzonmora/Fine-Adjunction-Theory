use application "polytope";
use strict;
use warnings;
#The operator | appends columns
#The operator / appends rows


#Creates the polytope and computes its facets in the matrix Acorepts
my $p = new Polytope(VERTICES=>[[1,0,0,0],[1,2,0,0],[1,0,4,0],[1,2,2,0],[1,0,0,7],[1,0,4,7]]);
my $Acorepts = new Matrix<Rational>($p->FACETS);
#print $p->FACETS, "\n";
my $v1 = ones_vector($Acorepts->rows);
#print $v1;
$Acorepts->col(0) = $v1;
my $m = $p->VERTICES;
#print "Vertices of Acore:", "\n";
#print $Acorepts, "\n";


#Collects all relevant valid inequalities from facets in a matrix
my $ineqs = new Matrix<Rational>($p->FACETS);
#print "Facets of Polytope P:", "\n";
#print_constraints($p->FACETS);
#print $ineqs, "\n";
#print $p->VOLUME;



#Creates the polytope Acore in dual space with vertices the facets of P
my $Acore = new Polytope(POINTS=>$Acorepts);
#Obtains a matrix with the interior lattice points of Acore
my $intlatpts = new Matrix<Rational>($Acore -> INTERIOR_LATTICE_POINTS);
#print "Interior Lattice Points of Acore: ", "\n";
#print $intlatpts, "\n";



#Obtains all other relevant valid inequalities by minimizing
#Computes the a0 of the valid inequalities
#FIX:This should be if the row is non-zero
if($intlatpts->rows > 0){
   foreach (0..$intlatpts->rows-1){
	my $line = $intlatpts->row($_);
	$line->[0] = 0;
	if($line != zero_vector($intlatpts->cols) ){
		my $lprelevant=new LinearProgram<Rational>(LINEAR_OBJECTIVE=>$intlatpts->row($_));
		#print "Inequality: ", $intlatpts->row($_), "\n";
		my $pol = new Polytope<Rational>(POINTS=>$m, LP=>$lprelevant);
		#print "Min: ";
		#print $pol->LP->MINIMAL_VERTEX, "\n";
		my $minvertex = $pol->LP->MINIMAL_VERTEX;
		#print "Inequality: ", $intlatpts->row($_);
		my $a0 =  $intlatpts->row($_)*$minvertex;
		#print "Multiplication: ", $a0 , "\n";
		my $vec = $intlatpts->row($_);
		$vec->[0] = -$a0;
		#Adds valid inequalities which do not define facets to matrix of constraints
		      if($vec != zero_vector($vec->dim)){
			      $ineqs /= $vec;
			      #print "entry:", $vec->[0], "\n";
			      #print "Ineqs:", $ineqs, "\n";
			}
		}
	}
}



#Computes the Fine mountain of P and compares with clasical mountain
my $Facets = new Matrix<Rational>($p->FACETS);

my $Fine = common::primitive($ineqs);

#print "Facets: ", $Facets, "\n";
#print "Fine: ", $Fine, "\n";
#print_constraints($Fine);

$Facets |= -ones_vector<Integer>($Facets->rows);
$Facets /= unit_vector<Integer>($Facets->cols,($Facets->cols)-1);
my $mount = new Polytope<Rational>(INEQUALITIES=>$Facets);
    
$Fine |= -ones_vector<Integer>($Fine->rows);
$Fine /= unit_vector<Integer>($Fine->cols,($Fine->cols)-1);
my $Finemount = new Polytope<Rational>(INEQUALITIES=>$Fine);

print "Fine Mount: ", $Finemount->VERTICES, "\n";
#print "Classical Mount: ", $mount->VERTICES, "\n";

#print $p->Q_CODEGREE;
#print $p->VISUAL;
#print $Finemount->VISUAL;
#print $Finemount->FACETS;


#Obtains the height of the mountain which is the Fine Q-codegree
my $adim = $p->CONE_AMBIENT_DIM;
$adim -= 1;
my $vmount = unit_vector<Rational>($adim+2,$adim+1);
my $lpmount=new LinearProgram<Rational>(LINEAR_OBJECTIVE=>$vmount);
my $Fineheight = new Polytope<Rational>(INEQUALITIES=>$Fine,LP=>$lpmount);
my $FineQCodeg = 1/($Fineheight->LP->MAXIMAL_VALUE);
print "Fine Q-codegree: " , $FineQCodeg, "\n";

print "Classical Q-codegree: ", $p->Q_CODEGREE, "\n";
  

   

