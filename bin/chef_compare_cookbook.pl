#!/usr/bin/perl


my @chef_servers=('prod','stage','qa_cloud'); 

foreach my $var (@ARGV)
{
	print "Checking cookbook $var ...\n";
	foreach my $server (@chef_servers)
	{
		print `knife cookbook show $var -c ~/knife/knife.${server}.rb`;
	}
}


