#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper qw(Dumper);
use JSON;

my $data   = "file.dat";
my $length = 24;
my $verbose;

GetOptions ("length=i" => \$length,    # numeric
		   "file=s"   => \$data,      # string
		   "verbose"  => \$verbose)  # flag
or die "Incorrect usage!\n";

if ($verbose)
{
	print Dumper \@ARGV;
}

for my $cluster (@ARGV)
{
	if ($cluster =~ /([^\.]*)\./)
	{
		$cluster=$1;
	}

    print "Checking $cluster\n";

	my $out=`grep -rl "role\\\[$cluster\\\]" ~/OPS/iheart-chef/node_json/*`;

	if ($verbose)
	{
		print "out=$out"; 
	}

	for my $node (sort (split (/[\r\n]+/, $out)))
	{
		print "\nNode=$node\n";

		my $json;
		{
		  local $/; #Enable 'slurp' mode
		  open my $fh, "<", "$node";
		  $json = <$fh>;
		  close $fh;
		}

		my $data = decode_json($json);

		if ($verbose)
		{
			print Dumper $data;
		}

		my $ip = $$data{'normal'}{'elasticsearchnew'}{'ip'};

		print "IP=$ip\n";

		my $p=`ssh $ip "ps -ef" | grep elas | awk '{print \$2}'`;
		chomp $p;

		print "Process=$p\n";

		my $eshost=`ssh $ip "grep network.host /data/apps/ihr-search/configs/elasticsearch.yml" | awk '{print \$2}'`;
		chomp $eshost;

		print "eshost=$eshost\n";

		$json=`curl -s -XGET "http://$eshost:9200/_cluster/health?pretty=true"`;

		my $status = decode_json($json);

		print "status=" . $$status{'status'} ."\n";

		if ($verbose)
		{
			print `curl -XGET "http://$eshost:9200/_cluster/health?pretty=true"`;
		}
 
	}
}
