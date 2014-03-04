use strict;
use warnings;
use Data::Dumper;
use utf8;


 
use Test::More tests => 3;

my $target='127.0.0.1';

use_ok 'Win32::Tracert';

my $route = Win32::Tracert->new(destination => "$target");

my $path = $route->to_trace;

ok($route->found($path),"Is route Found");

is ($route->hops($path),1,"Hops number to reach destination");

#print "nombre de saut pour atteindre la destination:",$route->hops($path),"\n";
#print Dumper $path;




=head

Les arguments sont:
    - destination (hostname ou @IP)
        Options :
           -d                 Ne pas convertir les adresses en noms d'hôtes.
           -h SautsMaxi       Nombre maximum de sauts pour rechercher la cible.
           -j ListeHôtes      Itinéraire source libre parmi la liste des hôtes.
           -w délai           Attente d'un délai en millisecondes pour chaque réponse.
   
    - text (résultat d'un tracert windows externe fourni en argument sous la forme d'une chaine de caracteres)




$target_ip='10.0.0.2';
my $route2 = Win32::Tracert->new(destination => "$target_ip");
my $route3 = Win32::Tracert->new(destination => "buggy");
$route3->to_find;
ok($route2->to_find->parse->found,"Is route Found");

=cut
