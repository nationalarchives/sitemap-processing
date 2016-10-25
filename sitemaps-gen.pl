#main site
my @urls = ('http://livelb.nationalarchives.gov.uk/page-sitemap1.xml',
			'http://livelb.nationalarchives.gov.uk/page-sitemap2.xml',
			'http://livelb.nationalarchives.gov.uk/page-sitemap3.xml',
			'http://livelb.nationalarchives.gov.uk/online-exhibitions-sitemap.xml');
use LWP::Simple;
use XML::Parser;
use URI;
use File::stat;
use Time::localtime;
foreach my $url (@urls)
	{
	my $content = get $url;
	die "Nah!" unless defined $content;
	my $filename = "wp-" . (URI->new($url)->path_segments)[-1];
	open(my $handler, ">", $filename) or die "couldn't open $filename";
	binmode($handler, ":utf8");
	$content =~ s/livelb/www/g;
	$content =~ s/<\?xml-stylesheet(.*)\?>//g;
	my $parser = XML::Parser->new($content);
	eval { $parser->parse($content)};
	if( $@ ) {
		print "ERROR: $shortname not well formed\n";
	} else
	{
		print "$shortname well formed\n";
		print $handler $content;
		print "writing $filename ...\n";
	}
	close $handler;
}
print "main site done\n";

#child sites
sub processchild {
	my ($url, $prepath, $shortname) = @_;
	print "processing " . $shortname . "...\n";
	my $thisurl = URI->new($url);
	my $childsiteurl = ($thisurl->scheme) . "://" . ($thisurl->host);
	my $replacetext = "http://www.nationalarchives.gov.uk" . $prepath;
	my $newchildsiteurl;
	($newchildsiteurl = $childsiteurl) =~ s/\Q$childsiteurl/$replacetext/g;
	my $content = get $url;
	my $filename = "wp-" . $shortname . "-" . ($thisurl->path_segments)[-1];
	open(my $handler, ">", $filename) or die "couldn't open $filename";
	binmode($handler, ":utf8");
	my $content = get $url;
	$content =~ s/$childsiteurl/$newchildsiteurl/g;
	$content =~ s/<\?xml-stylesheet(.*)\?>//g;
	my $parser = XML::Parser->new($content);
	eval { $parser->parse($content)};
	if( $@ ) {
		print "ERROR: $shortname not well formed\n";
	} else
	{
		print "$shortname well formed\n";
		print $handler $content;
		print "writing $filename ...\n";
	}
	close $handler;
}

processchild('http://archives-sector.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/archives-sector', 'archives-sector');
processchild('http://research.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/about/our-role', 'research-scholarship');
processchild('http://commercial.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/about/commercial-opportunities', 'commercial');
processchild('http://fww.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/first-world-war', 'first-world-war');
processchild('http://jobs.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/about/jobs', 'jobs');
processchild('http://pressroom.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/about/pressroom', 'pressroom');
processchild('http://foi.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/freedom-of-information', 'freedom-of-information');
processchild('http://getinvolved.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/about/get-involved', 'get-involved');
processchild('http://help-legal.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/help', 'help');
processchild('http://labs.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/labs', 'labs');
processchild('http://black-history.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/black-history', 'black-history');
processchild('http://cabinet.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/cabinet-office-100', 'cabinet-office-100');
processchild('http://great-wharton.livelb.nationalarchives.gov.uk/page-sitemap.xml', '/first-world-war/home-front-stories', 'great-wharton');
print "child sites done\n";

opendir my $dir, "." or die "Cannot open directory";
@files = grep(/sitemap[0-9]{0,1}\.xml$/,readdir($dir));
closedir $dir;

my $outfile = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n";
foreach my $file (@files)
{

	open (my $handler, "<", $file);
	$timestamp = ctime(stat($handler)->mtime);
	close $handler;
	$outfile .= "\t<sitemap>\n\t\t<loc>http://www.nationalarchives.gov.uk/sitemaps/" . $file . "</loc>\n\t\t<lastmod>".  $timestamp ."</lastmod>\n\t</sitemap>\n";
}
$outfile .= "</sitemapindex>";


open(my $handler, ">", "sitemap-index.xml") or die "couldn't open sitemap-index";
print $handler $outfile;
close $handler;


