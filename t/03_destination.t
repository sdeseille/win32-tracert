use strict;
use warnings;
use Data::Dumper;
use utf8;


 
use Test::More tests => 4;

my $target='127.0.0.1';

use_ok 'Win32::Tracert';

my $route = Win32::Tracert->new(destination => "$target");

$route->to_trace;

ok($route->found(),"Is route Found");

is ($route->hops(),1,"Hops number to reach destination");

is ($route->to_trace->found->hops,1,"Chained methods call in order to find number of Hops to reach destination");

#print "nombre de saut pour atteindre la destination:",$route->hops($path),"\n";
#print Dumper $path;




=head

Les arguments sont:
    - destination (hostname ou @IP)
        Options�:
           -d                 Ne pas convertir les adresses en noms d'h�tes.
           -h SautsMaxi       Nombre maximum de sauts pour rechercher la cible.
           -j ListeH�tes      Itin�raire source libre parmi la liste des h�tes.
           -w d�lai           Attente d'un d�lai en millisecondes pour chaque r�ponse.
   
    - text (r�sultat d'un tracert windows externe fourni en argument sous la forme d'une chaine de caracteres)




$target_ip='10.0.0.2';
my $route2 = Win32::Tracert->new(destination => "$target_ip");
my $route3 = Win32::Tracert->new(destination => "buggy");
$route3->to_find;
ok($route2->to_find->parse->found,"Is route Found");

=cut