#!/usr/bin/perl -w

use strict;
use File::Temp;

my $debug=1;
my @chef_servers=('prod','stage','qa_cloud'); 

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $ymd = sprintf("%04d%02d%02d_%02d%02d%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);

my $dir=File::Temp::tempdir( "/var/tmp/chef_compare_cookbookXXXX", CLEANUP => 1);

foreach my $env (@chef_servers)
{
	mkdir "$dir/$env" || die "Cannot create $dir/$env: $!";
}

foreach my $var (@ARGV)
{
	print "Checking cookbook $var ...\n";
	foreach my $server (@chef_servers)
	{
		my $out=`knife cookbook show $var -c ~/knife/knife.${server}.rb`;
		print $out;
		
		chomp $out;
		
		if ($? == 0)
		{
			my @version=split(/ +/, $out);
			shift @version;

			foreach my $ver (@version)
			{
				print "$ver\n";
				my $out = `knife cookbook download $var $ver -c ~/knife/knife.${server}.rb -d $dir/$server`;

				if ($? == 0)
				{
				}
				else
				{
					print $out;
					exit;
				}
			}
		}
		else
		{
			if ($debug)
			{
				print "$out";
			}
		}
	}

	for my $i (0..$#chef_servers-1)
	{ 
		my $diffcmd="diff -r $dir/" . $chef_servers[$i] . " $dir/" . $chef_servers[$i+1];
		print "$diffcmd\n\n";
		print `$diffcmd`;
	}

}


