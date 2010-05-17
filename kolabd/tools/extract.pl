## Perl script to extract strings from all the files and print
## to stdout for use with xgettext.

# perl extract.pl | xgettext --keyword=_ -C --no-location -
# msgfmt  -vvv -o locales/de_DE/LC_MESSAGES/messages.mo messages.po

use File::Find;
use Cwd;
use strict;

my($ext) = '(\.php$|\.inc$|\.dist$)';
my(%strings);

find(\&extract, cwd . '/..');

print join("\n", sort keys %strings), "\n";

sub extract { 
  my($file) = $File::Find::name;
  if ($file =~ /$ext/) {
    open F, $file;
    while (<F>) {
      while (s/_\("(.*?)"\)//) {
        $strings{"_(\"$1\")"}++;
      }
    }
    close F;
  }
}
