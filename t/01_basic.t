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
