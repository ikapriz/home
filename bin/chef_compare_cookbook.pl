#!/usr/bin/perl

my $debug=1;
my @chef_servers=('prod','stage','qa_cloud'); 

foreach my $var (@ARGV)
{
	print "Checking cookbook $var ...\n";
	foreach my $server (@chef_servers)
	{
		my $out=`knife cookbook show $var -c ~/knife/knife.${server}.rb`;
		
		if ($? == 0)
		{
			my @version=split(/ /, $out);
		}
		else
		{
			if ($debug)
			{
				print "$out";
			}
		}
	}
}


