# Hey Emacs, this is -*- perl -*- !
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..11\n"; }
END {print "not ok 1\n" unless $loaded;}
use XML::Parser::PerlSAX;

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# Test Plan:
#
#   * done; standard loading test
#   * not done; parse a document with data for all events
#   * not done; check all properties returned from events
#   * not done; check location

#
# The following is copied from XML::Parser by Clark Cooper
#
open(ZOE, '>zoe.ent');
print ZOE "'cute'";
close(ZOE);

# XML string for tests

my $xmlstring =<<"End_of_XML;";
<!DOCTYPE foo
  [
    <!NOTATION bar PUBLIC "qrs">
    <!ENTITY zinger PUBLIC "xyz" "abc" NDATA bar>
    <!ENTITY fran SYSTEM "fran-def">
    <!ENTITY zoe  SYSTEM "zoe.ent">
   ]>
<foo>
  First line in foo
  <boom>Fran is &fran; and Zoe is &zoe;</boom>
  <bar id="jack" stomp="jill">
  <?line-noise *&*&^&<< ?>
    1st line in bar
    <blah> 2nd line in bar </blah>
    3rd line in bar <!-- Isn't this a doozy -->
  </bar>
  <zap ref="zing" />
  This, '\240', would be a bad character in UTF-8.
</foo>
End_of_XML;

# Handlers
my @tests;
my $pos ='';

my $parser = XML::Parser::PerlSAX->new;
if ($parser) {
    print "ok 2\n";
} else {
    print "not ok 2\n";
    exit;
}

# Tests 4..11
eval {
    $parser->parse( Source => { String => $xmlstring,
                                Encoding => 'ISO-8859-1' },
                    Handler => TestHandler->new( Tests => \@tests ) );
};

if ($@) {
    print "Parse error:\n$@";
} else {
    $tests[3] ++;
}

unlink('zoe.ent') if (-f 'zoe.ent');

for (3 .. 11)
{
    print "not " unless $tests[$_];
    print "ok $_\n";
}

exit;

package TestHandler;

sub new {
    my $type = shift;
    return bless { @_ }, $type;
}

sub characters {
    my $self = shift;
    $self->{Tests}[4] ++;
}

sub start_element {
    my $self = shift;
    $self->{Tests}[5] ++;
}

sub end_element {
    my $self = shift;
    $self->{Tests}[6] ++;
}

sub processing_instruction {
    my $self = shift;
    $self->{Tests}[7] ++;
}

sub notation_decl {
    my $self = shift;
    $self->{Tests}[8] ++;
}

sub unparsed_entity_decl {
    my $self = shift;
    $self->{Tests}[9] ++;
}

sub resolve_entity {
    my $self = shift;
    my $entity = shift;

    if ($entity->{SystemId} eq 'fran-def') {
	$self->{Tests}[10] ++;
	return { String => 'pretty' };
    } elsif ($entity->{SystemId} eq 'zoe.ent') {
	$self->{Tests}[11] ++;
        local(*FOO);
        open(FOO, $entity->{SystemId}) or die "Couldn't open $entity->{SystemId}";
        return { ByteStream => *FOO };
    }
}
