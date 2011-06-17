#!/usr/bin/perl -w

use CGI;
$q = CGI->new;                        # create new CGI object
print $q->header,                    # create the HTTP header
    $q->start_html('hello world'), # start the HTML
    $q->h1('hello world'),         # level 1 header
    $q->end_html;                  # end the HTML


$last_dir=3895;
$last_img=249525; 
$dir=$last_dir;
$img=249525;
    
 
sub inc_dir {
    $last_dir = $dir;
    $last_img = $img;
    $dir++;
}

sub inc_img {
    $last_dir = $dir;
    $last_img = $img;
    $img++;
}

sub dec_dir {
    $last_dir = $dir;
    $last_img = $img;
    $dir--;
}

sub dec_img {
    $last_dir = $dir;
    $last_img = $img;
    $img--;
}


sub getUrl {
    # get from db url
    # $url=...
}

sub getPage {
    ($dir, $img) = @_;
    $url = qq($url/$dir/${img}_L.jpg);
    return curl $url;
    
}
if (getPage()) {
    print qq(<img src="$url">);
} else {
    if ($lastCmd == "incdir") { inc_img; }  # mettere un limite qui
    if ($lastCmd == "decdir") { } 
    if ($lastCmd == "incimg") { inc_dir; } 
    if ($lastCmd == "decimg") { } 
}
