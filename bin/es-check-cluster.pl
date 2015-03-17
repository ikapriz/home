#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper qw(Dumper);
use JSON;

my $data   = "file.dat";
my $length = 24;
my $verbose;
my $restart;
my $nowait=0;

GetOptions ("length=i" => \$length,    # numeric
		   "file=s"   => \$data,      # string
		   "verbose"  => \$verbose,  # flag
		   "nowait"  => \$nowait,  # flag
		   "restart" => \$restart)
or die "Incorrect usage!\n";

if ($verbose)
{
	print Dumper \@ARGV;
}

sub es_status 
{
	my ($esnode) = @_;

	my $json=`curl -s -XGET "http://$esnode:9200/_cluster/health?pretty=true"`;

	my $status = decode_json($json);

	return $$status{'status'};
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

		print "status=" . es_status($eshost)  ."\n";

		if ($verbose)
		{
			print `curl -XGET "http://$eshost:9200/_cluster/health?pretty=true"`;
		}

		if ($restart)
		{
			while ($p ne "")
			{
				print "Killing process $p\n";
				my $o=`ssh $ip "sudo kill $p"`;
				chomp $o;

				if ($o ne "")
				{
					print "$o\n";
				}
				$p=`ssh $ip "ps -ef" | grep elas | awk '{print \$2}'`;
				chomp $p;
			}

			print "Killed\n";
			print "Starting elasticsearch\n";

			print `ssh $ip "sudo /sbin/service elasticsearch start"`;

			if (! $nowait)
			{
				my $status=es_status($eshost);
				my $n=10;

				while ($status ne 'green' && $n > 0) 
				{
					if ($n % 60 == 0)
					{
						print "$n status=$status ... waiting for green\n";
					}
					$n-=1;
					$status=es_status($eshost);
					sleep (1);
				}

				print "$n status=$status\n";

				if ($n <= 0)
				{
					print "Error: Cluster is still $status, please restart manually!\n";
					exit;
				}
			}
		}
	}
}
