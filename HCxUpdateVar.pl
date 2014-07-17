#!/usr/bin/perl

my $version = '0.1';
my $author_info = <<EOF;
##########################################
#   Author: Andre Duclos
#  Created: 2014-07-06
# Modified: 2014-07-06
#
#  Version: $version
#    https://github.com/shyrka973/HCxUpdateVar
##########################################
EOF

use strict;

use Getopt::Long;
use Pod::Usage;
use LWP::UserAgent;
use JSON;

my $realm = "fibaro";
my $port = "80";


my %options = ();
GetOptions(\%options,
           'host=s',
           'user=s',
           'passwd=s',
           'var=s',
           'value=s',
           'sceneid=s',
           'version',
           'help|?'
    ) or pod2usage(2);

pod2usage(-verbose => 2) if (exists($options{'help'}));

if ($options{version}) {
    print "\n\tVersion: $version\n\n";
    print "$author_info\n";
    exit;
}

if  (	defined($options{"host"}) &&
		defined($options{"user"}) && defined($options{"passwd"}) &&
		defined($options{"var"}) &&  defined($options{"value"}) ) {

	my $host = $options{"host"};
	my $user = $options{"user"};
	my $pass = $options{"passwd"};
	my $var = $options{"var"};
	my $value = $options{"value"};

	my $netloc = $host.":".$port;
	my $url = "http://" . $host . "/api/globalVariables";

	my %data = ( "name" => $var, "value" => $value );
	my $json = JSON->new;
	my $data = $json->encode(\%data);

	# Create the user agent
	my $ua = LWP::UserAgent->new();
	$ua->timeout(20);
	$ua->credentials($netloc, $realm, $user, $pass);

	# Do the HTTP put request
	my $response = $ua->put($url, 'Content' => $data, 'Content-Type' => 'application/json' );

	if ($response->is_success) {
		if (defined($options{"sceneid"})) {
			my $sceneid = $options{"sceneid"};
			
			$response = $ua->get("http://" . $host . "/api/sceneControl?id=" . $sceneid . "&action=start");
			if ($response->is_success) {
				exit;
			}
			else {
				die $response->status_line;
			}
		}
	}
	else {
		die $response->status_line;
	}
}

__DATA__

__END__

=head1 NOM

HCxUpdateVar.pl - Met a jour une variable globale donnée sur un Fibaro Home Center ou Lite (HCx)

=head1 SYNOPSIS


HCxUpdateVar.pl [options]

  Options:

	--host=...          Adresse IP du HCx
	--user=...          Utilisateur
	--passwd=...        Mot de passe
	--var=...           Variable globale a mettre à jour
	--value=...         Valeur a donner
	--sceneid=...       ID de la scene a lancer apres avoir modifier la variable globale
	                    Pour palier au bug suivant:
	                    La modification d'une variable globale par l'api ne lance pas les scenes (%global)
