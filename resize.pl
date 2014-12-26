#!C:/Perl/bin/perl.exe
use JSON;
use GD;
use CGI;
use strict;


sub resize {
    my $file = shift;
    my $sizes = shift;
    my $imgDir = shift || ".";

    if (!-d $imgDir) {
        mkdir $imgDir or die "Unable to create $imgDir";
    }
    
    if ($file && -e $file) {
        my $name = "img";
        my $mime = "jpg";
        if ($file =~ /[\/\\]*([a-zA-Z0-9-_ ]*)\.([a-z]+)$/i) {
            $name = $1;
            $mime = $2;
        }

        my $img;
        if (lc($mime) eq "jpg" || lc($mime) eq "jpeg") {
            $img = GD::Image->newFromJpeg($file);
        } elsif (lc($mime) eq "png") {
            $img = GD::Image->newFromPng($file);
        } else {
            die "Unsupported file format: $mime";
        }

        my ($w,$h) = $img->getBounds(); # find dimensions

        for my $size (keys %$sizes) {
            my $newimg;
            if ($sizes->{$size}->{crop}) {
                my ($cut,$xcut,$ycut);
                if ($w>$h){
                    $cut=$h;
                    $xcut=(($w-$h)/2);
                    $ycut=0;
                }
                if ($w<$h){
                    $cut=$w;
                    $xcut=0;
                    $ycut=(($h-$w)/2);
                }
                $newimg = new GD::Image($sizes->{$size}->{width}, $sizes->{$size}->{height}, 1);
                $newimg->copyResampled($img,0,0,$xcut,$ycut,$sizes->{$size}->{width}, $sizes->{$size}->{height},$cut,$cut);
            } else {
                my $gd;
                if ($w>$h) {
                    $newimg = new GD::Image($sizes->{$size}->{width}, (($h/$w)*$sizes->{$size}->{width}), 1);
                    $newimg->copyResampled($img,0,0,0,0,$sizes->{$size}->{width}, (($h/$w)*$sizes->{$size}->{width}),$w,$h);
                } else {
                    $newimg = new GD::Image(($w/$h)*$sizes->{$size}->{height}, ($sizes->{$size}->{height}), 1);
                    $newimg->copyResampled($img,0,0,0,0,($w/$h)*$sizes->{$size}->{height}, ($sizes->{$size}->{height}),$w,$h);

                }
            }

            open(my $thumbFile, ">", "$imgDir/$name-$size.jpg") or die "Cannot open $imgDir/$name-$size.jpg: $!";
            binmode $thumbFile;
            print $thumbFile $newimg->jpeg($sizes->{$size}->{quality});
            close $thumbFile;
            print "Wrote $imgDir/$name-$size.jpg\n";
        }
        print "Done.\n";
    } else {
        die "Can't find file $file\n";
    }
}




my $json = JSON->new->allow_nonref;

my ($file, $sizesPath, $imgDir) = @ARGV;

my $sizes = {};

if ($sizesPath && -e $sizesPath) {
    my $text = do { local(@ARGV, $/) = $sizesPath; <> };
    $sizes = $json->decode($text);
} else {
    die "$sizes does not exist."
}
    
resize($file, $sizes, $imgDir);


