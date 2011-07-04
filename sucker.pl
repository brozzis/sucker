#!/usr/bin/perl -w

# use myconfig;
#use CGI;

#use strict;use warnings;
#use WWW::Curl;
#use WWW::Curl::Easy;


use DBI;

$dsn = "DBI:mysql:database=sucker;host=localhost";

$dbh = DBI->connect($dsn, "root", "", {'RaiseError' => 1} );

my $sth = $dbh->prepare("select found from img where dir=? and img=?");
my $sth2 = $dbh->prepare("replace into img (dir, img, found) values (?,?,?)");

sub memo
{
    my $curl = WWW::Curl::Easy->new();
    my $fh   = 'README';
    if( $curl ){
        $curl->setopt(CURLOPT_HEADER,1);
        $curl->setopt(CURLOPT_URL, 
        'ftp://ftp.perl.org/pub/CPAN/README');
        my $response_body;
        
        open(my $fh, '>', \$response_body);
        $curl->setopt(CURLOPT_WRITEDATA, $fh);
        $curl->setopt(CURLOPT_VERBOSE,1);
        my $retcode = $curl->perform();

        if ($retcode != 0) {
            warn "An error happened: ", $curl->strerror($retcode), " (+$retcode)\n";
            warn "errbuf: ", $curl->errbuf;
        }
        $curl->curl_easy_cleanup; 
    } else {
        warn " WWW::Curl::Easy->new() failed";
    }
}


# le più vecchie a giugno 2011
$last_dir=3895;
$last_img=249525; 

# le mie foto di panos I
$last_dir=3874;
$last_img=247362; 

$dir_limit=20;

$last_dir=shift || $last_dir;
$last_img=shift || $last_img;



# $dir=$last_dir;
# $img=$last_img;

$base_url=qq();
    
sub iamlost_dir {
    my ($c, $i)=@_;
    my $x = 0;
    my $ERR=0;

    print "\nI am lost!\n";
    if(check_directory($c)) {
	print "directory $c is good\n";
	while(! check_couple($c, $i) or $ERR) {
	    save_couple($c, $i, 'FALSE');
	    print "\r$c, $i ($x)        ";
	    $i--;
	    $x++;
	    $ERR=1 if ($x>1000)
	}
    }
    
    if ($ERR) {
	return 0;
    }
    else 
    {
	save_couple($c, $i, 'TRUE');
	return $i;
    }
    
}


#
# file costante, ruota dir
#x
sub iamlost {
    my ($c, $i)=@_;
    my $x = 0;
    my $ERR=0;

    print "\nI am lost!\n";
    if(check_directory($c)) {
	print "directory $c is good\n";
	while((! check_couple($c, $i)) or $ERR) {
	    save_couple($c, $i, 'FALSE');
	    print "\r$c, $i ($x)        ";
	    $c--;
	    $x++;
	    $ERR=1 if ($x>100)
	}
    }
    
    if ($ERR) {
	return 0;
    }
    else 
    {
	save_couple($c, $i, 'TRUE');
	return $c;
    }
    
}



sub iamlost_forward {
    my ($c, $i)=@_;
    my $x = 0;
    my $ERR=0;

    print "\nI am lost!\n";
    if(check_directory($c)) {
	print "directory $c is good\n";
	while((! check_couple($c, $i)) or $ERR) {
	    save_couple($c, $i, 'FALSE');
	    print "\r$c, $i ($x)        ";
	    $c++;
	    $x++;
	    $ERR=1 if ($x>100)
	}
    }
    
    if ($ERR) {
	return 0;
    }
    else 
    {
	save_couple($c, $i, 'TRUE');
	return $c;
    }
    
}




sub go_backwards {

    my ($c, $i, $file_not_found)=@_;

    my $ERR=0;
    my $dir_not_found;
    my $last_attempt=0;

    while(! $ERR) {
	print "\r$c, $i: $file_not_found        ";
	if (check_couple($c, $i)) {
	    print " OK ";
	    save_couple($c, $i, 1);
	    --$i; 
	    $count{$c}++;
	    $file_not_found=0;
	    $dir_not_found=0;
	    
	    $last_c_good=$c;
	    $last_i_good=$i;
	} else {
	    print " NO ";
	    save_couple($c, $i, 0);
	    $file_not_found++;
	    # go_backwards( --$c, $i, $file_not_found );
	    $c--;
	    if ($file_not_found>$dir_limit) {
		$c+=$dir_limit; 
		--$i; 
		$file_not_found = 0;
		$dir_not_found++;
		if ($dir_not_found>9) {
		    $last_attempt++;
		    $c+=4;
		    $i-=32; # 64 è la media ottenuta da #img / #dir
		    if ($last_attempt>2) {
			$ERR=1;
		    }
		}
	    }
	}
	
    }
    iamlost( $last_c_good, $last_i_good );
    
    
}

sub go_forwards {

    my ($c, $i, $file_not_found)=@_;

    my $ERR=0;
    my $dir_not_found;
    my $last_attempt=0;

    while(! $ERR) {
	print "\r$c, $i: $file_not_found        ";
	if (check_couple($c, $i)) {
	    print " OK ";
	    save_couple($c, $i, 1);
	    $i++; 
	    $count{$c}++;
	    $file_not_found=0;
	    $dir_not_found=0;
	    
	    $last_c_good=$c;
	    $last_i_good=$i;
	} else {
	    print " NO ";
	    save_couple($c, $i, 0);
	    $file_not_found++;
	    # go_backwards( --$c, $i, $file_not_found );
	    $c++;
	    if ($file_not_found>$dir_limit) {
		$c-=$dir_limit; 
		$i++; 
		$file_not_found = 0;
		$dir_not_found++;
		if ($dir_not_found>9) {
		    $last_attempt++;
		    $c-=4;
		    $i+=32; # 64 è la media ottenuta da #img / #dir
		    if ($last_attempt>2) {
			$ERR=1;
		    }
		}
	    }
	}
	
    }
    iamlost_forward( $last_c_good, $last_i_good );
    
    
}


sub save_couple {
    my ($c, $i, $result)=@_;

    # print qq($c, $i \n);

    $sth2->execute($c,$i,$result) or die $dbh->errstr;
    # qx/mysql sucker -e "replace into img (dir, img, found) values ($c,$i,$result);"/;
}


sub check_in_web {

    my ($c, $i)=@_;

    my $out=qx(curl  --user-agent "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"  -s -I ${base_url}/$c/${i}_L.jpg|head -1);
    # print qq(${base_url}/$c/$i_L.jpg);
    $out =~ m#HTTP/1.1\s+(\d+)#;
    # print "$1 ";
    return ($1==200);
}
 

sub check_directory {

    my ($c, $i)=@_;

    my $out=qx(curl  --user-agent "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"  -s -I ${base_url}/$c/|head -1);
    $out =~ m#HTTP/1.1\s+(\d+)#;
    return ($1!=404); # un
}
 


sub check_in_db {
    my ($c,$i) = @_;

    $sth->execute( $c, $i );
    my $ref = $sth->fetchrow_hashref() ;

    return $ref->{'found'};
}


sub check_couple {
    my ($c,$i) = @_;

    die "dir negativa!" if ($c<=0);
    die "img negativa!" if ($i<=0);
    $val = check_in_db($c,$i);

    if (defined($val)) {
	return $val;
    }
	
    return check_in_web($c, $i);

}


sub curl {
    # do something with Curl here
    # ...
}

sub check_c {
    my ($dir) = @_;
    return curl($dir);
}



# print "short\n";
# print iamlost($last_dir, $last_img);
# die;


%count = ();

print "\nrunning!\n";
# go_backwards($last_dir, $last_img, 0);
go_forwards($last_dir, $last_img, 0);

print "\nstop!\n";

foreach $k ( keys %count ) { $tot += $count{$k}; }
printf "trovati : \n\t %d: collezioni, %d immagini complessive\n", $#count, $tot; 
