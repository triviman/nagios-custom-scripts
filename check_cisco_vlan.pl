!/usr/bin/perl
########## ORIGINAL SCRIPT ##########################################
# original idea from petrus http://serverfault.com/users/46213/petrus
# in serverfault post http://serverfault.com/questions/340856/automate-hop-by-hop-telnet-to-cisco-router
############## THIS SCRIPT ##########################################
#
# create for check with nagios VLAN status in cisco L3 switches
# credits by TRiVi @triviman
# feel free of modify/fix and improve this script.
#
#change password to your password
use Net::Telnet::Cisco;

my $substr = $ARGV[1];

if ($#ARGV == -1) {
        print "Usage : $0 <ip address>\n";
}
else {

        my $host = $ARGV[0];
        my $session = Net::Telnet::Cisco->new(Host => $host);
        $session->login('', 'd3l4m4nch4');
        my $execute="sh vlan brief | inc $substr ";
        my @resultado = $session->cmd($execute);

        my @columnas = split(/\s+/, $resultado[0]);
        my $estado=$columnas[2];

        if ( $estado eq "active" ){
        print "OK VLAN UP | estado=$estado \n"; exit(0);
        }
        else{
        print " CRITICAL VLAN DOWN | estado=inactive \n"; exit(2);
        }
        $session->close;
}
