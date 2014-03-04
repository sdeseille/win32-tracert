use strict;
use warnings;

 
use Test::More tests => 7;

use_ok 'Win32::Tracert';

my $route = new_ok('Win32::Tracert');

can_ok($route,'to_trace');

can_ok($route,'found');

can_ok($route,'hops');

can_ok($route,'path');

my $parser_object=new_ok('Win32::Tracert::Parser');



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
