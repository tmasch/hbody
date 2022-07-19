# x11 colors
#"relativity_routines" => "ivory3",
#"utility_routines" => "khaki",
#"external_forces" => "crimson",
#"stellar_evolution" => "brown",
%modules=(
"utility_routines" => "cornflowerblue",
"relativity_routines" => "cornflowerblue",
"external_forces" => "cornflowerblue",
"stellar_evolution" => "cornflowerblue",
"binary_evolution" => "maroon",
"binary_routines" => "white",
"triple_routines" => "orange",
"quad_routines" => "orangered",
"chain_util" => "chartreuse",
"chain_routines" => "red",
"analysis_routines" => "skyblue",
"io_routines" => "slateblue",
"startup_routines" => "steelblue",
"nbody_routines" => "white",
"nbody_utilities" => "yellow",
"nbutil_1" => "magenta",
"nbutil_2" => "cyan"
);

$input=$ARGV[0];
if ($input){
@files_to_do=$input;
}
if (not $input){
@files_to_do=`ls *.dot`;
}

for $infile (@files_to_do){

$outfile=$infile;
chop $outfile;chop $outfile;chop $outfile;chop $outfile;chop $outfile;
#$outfile=$outfile.".pdf";
$outfile=$outfile.".png";
open(SRC,"<$infile");
open(TMPFILE,">work.dot");
while(<SRC>){
$tmp=$_;
if ($tmp =~ "label"){
    foreach $key (keys %modules) {
        $lbl="label=\"".$key;
        if ($tmp =~ $lbl){
#        print $key." xxx ".$tmp."\n";
        $color=$modules{$key};
        #print $key." ".$color;
        $color="fillcolor=\"".$color."\"";
        $tmp=~ s/fillcolor=\"white\"/$color/;
        #print $tmp."\n";
        @ttmp=split(/\[/,$tmp);
        $id=$ttmp[0];
        $id=~ s/ //g;
#        print "node id ".$id."\n";
        $nodes{$id}=$modules{$key};
        }
    }
}
print TMPFILE $tmp;
}
close(TMPFILE);
open(WORKFILE,"<work.dot");
open(TMPFILE,">tmp.dot");
while(<WORKFILE>){
$tmp=$_;
if ($tmp =~ "->"){
    @ttmp=split(/->/,$tmp);
    $id_source=$ttmp[0];
    $id=$ttmp[1];
    @ttmp=split(/\[/,$id);
    $id=$ttmp[0];
    $id=~ s/ //g;
    $id_source=~ s/ //g;
#    print "node id ".$id."\n";
#    print $key." xxx ".$tmp."\n";
    if ($nodes{$id} !~ $nodes{$id_source} ){
    $color=$nodes{$id};
    #print $key." ".$color;
    $color="color=\"".$color."\"";
    $tmp=~ s/color=\"midnightblue\"/$color/;
    }
#    print $tmp."\n";
    }
print TMPFILE $tmp;
}

print "infile ".$infile."\n";
print "outfile ".$outfile."\n";
$file=$outfile."1.pdf";
`dot -o $file -Tpdf tmp.dot`;
#`dot -o $outfile -Tpng tmp.dot`;

open(SBGRPH,">subgraph.dot");
print SBGRPH 'digraph G
{
  edge [fontname="FreeSans.ttf",fontsize="10",labelfontname="FreeSans.ttf",labelfontsize="10"];
  node [fontname="FreeSans.ttf",fontsize="10",shape=record];
  rankdir=LR;
  ';
$k=0;
foreach $key (keys %modules) {
$search="label=\\\"".$key."::";
$subgraph=`grep $search tmp.dot`;
if ($subgraph){
print SBGRPH "subgraph cluster_".$k." \{\n";
print SBGRPH "clusterrank=none;";
#print SBGRPH "subgraph  \{\n";
print SBGRPH $subgraph;
print SBGRPH "\}\n";
$k++;
}
}
$edges=`grep "\\->" tmp.dot`;
print SBGRPH $edges;
print SBGRPH "\}\n";
#`dot -o $outfile -Tpng subgraph.dot`;
`dot -o $outfile.pdf -Tpdf subgraph.dot`;
}




#`rm tmp.dot`;
#`rm work.dot`;
#`rm subgraph.dot`;