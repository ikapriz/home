#!/usr/bin/perl -w

use strict;
use File::Temp;

my $debug=1;
my @chef_servers=('prod','stage','qa_cloud'); 

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $ymd = sprintf("%04d%02d%02d_%02d%02d%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);

my $dir=File::Temp::tempdir( "/var/tmp/chef_compare_cookbookXXXX", CLEANUP => 1);

print `git clone git\@github.com:iheartradio/iheart-chef.git $dir/iheart-chef`;

my $first=1;
my $cookbook;
foreach my $var (@ARGV)
{
	print "Checking cookbook $var ...\n";
	if ($first)
	{
		$cookbook=$var;
		$first=0;
	}
	else
	{
		print `knife cookbook upload $cookbook -c ~/knife/knife.${var}.rb -o $dir/iheart-chef/cookbooks`
	}
}


