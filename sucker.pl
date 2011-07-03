#!/usr/bin/perl -w

# use myconfig;
#use CGI;

#use strict;use warnings;
#use WWW::Curl;
#use WWW::Curl::Easy;

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





$dir=$last_dir;
$img=$last_img;

$base_url=qq(http://sime.photoadmit.com/jpg_L/);
    

sub go_backwards_rec {

    my ($c, $i, $file_not_found)=@_;

    print "$c, $i: $file_not_found\n";
    if (check_couple($c, $i)) {
	save_couple($c, $i, 'TRUE');
	go_backwards($c, --$i, 0);
    } else {
	save_couple($c, $i, 'FALSE');
	$file_not_found++;
	go_backwards( --$c, $i, $file_not_found );
	if ($file_not_found>5) {
	    go_backwards( $c+4, --$i, $file_not_found ); 
	}
    }
    
    
    
}


sub go_backwards {

    my ($c, $i, $file_not_found)=@_;

    my $ERR=0;
    my $dir_not_found;
    while(! $ERR) {
	print "$c, $i: $file_not_found\n";
	if (check_couple($c, $i)) {
	    save_couple($c, $i, 'TRUE');
	    --$i; 
	    $file_not_found=0;
	    $dir_not_found=0;
	} else {
	    save_couple($c, $i, 'FALSE');
	    $file_not_found++;
	    # go_backwards( --$c, $i, $file_not_found );
	    $c--;
	    if ($file_not_found>5) {
		$c+4; 
		--$i; 
		$file_not_found = 0;
		$dir_not_found++;
		if ($dir_not_found>9) {
		    $ERR=1;
		}
	    }
	}
    }
    
    
}

sub save_couple {
    my ($c, $i, $result)=@_;

    # print qq($c, $i \n);

    qx/mysql sucker -e "replace into img (dir, img, esito) values ($c,$i,$result);"/;
}

sub check_in_web {

    my ($c, $i)=@_;

    my $out=qx(curl  --user-agent "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"  -s -I ${base_url}/$c/${i}_L.jpg|head -1);
    # print qq(${base_url}/$c/$i_L.jpg);
    $out =~ m#HTTP/1.1\s+(\d+)#;
    print "$1 ";
    return ($1==200);
}
 
sub check_in_db {
    my ($c,$i) = @_;
    
    return 0;
}


sub check_couple {
    my ($c,$i) = @_;

    if (check_in_db($c,$i)) {
	return 1;
    } else {
	return check_in_web($c, $i);

    }

}


sub curl {
    # do something with Curl here
    # ...
}

sub check_c {
    my ($dir) = @_;
    return curl($dir);
}



go_backwards($last_dir, $last_img, 0);

