#!/usr/bin/perl -w
use strict;

use Data::Dumper;
use Labyrinth::Test::Harness;
use Labyrinth::Plugin::CPAN;
use Labyrinth::Variables;
use Test::Database;
use Test::More tests => 47;

my @plugins = qw(
    Labyrinth::Plugin::CPAN
);

my $exceptions = 'Test.php|Net-ITE.pm|CGI.pm';
my $symlinks = {
          'Net-ITE.pm' => 'Net-ITE',
          'Math-Gsl' => 'Math-GSL',
          'CGI.pm' => 'CGI'
        };
my $merged = {
          'Math-GSL' => [
                          'Math-Gsl',
                          'Math-GSL'
                        ],
          'CGI' => [
                     'CGI.pm',
                     'CGI'
                   ],
          'Net-ITE' => [
                         'Net-ITE.pm',
                         'Net-ITE'
                       ]
        };
my $ignore = {
          'new.spirit' => 1,
          'perl5n.os' => 1,
          'FLAT.FA' => 1
        };
my $osnames = {
          'aix' => 'AIX',
          'freebsd' => 'FreeBSD',
          'hpux' => 'HP-UX',
          'minix' => 'MINIX',
          'bitrig' => 'BITRIG',
          'bsdos' => 'BSD/OS',
          'dragonfly' => 'Dragonfly BSD',
          'haiku' => 'Haiku',
          'gnu' => 'GNU Hurd',
          'linux' => 'GNU/Linux',
          'nto' => 'QNX Neutrino',
          'cygwin' => 'Windows (Cygwin)',
          'os2' => 'OS/2',
          'mswin32' => 'Windows (Win32)',
          'dec_osf' => 'Tru64',
          'sco' => 'SCO',
          'vms' => 'VMS',
          'openbsd' => 'OpenBSD',
          'midnightbsd' => 'MidnightBSD',
          'beos' => 'BeOS',
          'irix' => 'IRIX',
          'gnukfreebsd' => 'Debian GNU/kFreeBSD',
          'os390' => 'OS390/zOS',
          'interix' => 'Interix',
          'solaris' => 'SunOS/Solaris',
          'netbsd' => 'NetBSD',
          'macos' => 'Mac OS classic',
          'mirbsd' => 'MirOS BSD',
          'darwin' => 'Mac OS X'
        };
my $perls = [
          '5.7.3',
          '5.7.2',
          '5.7.1',
          '5.6.1',
          '5.6.0',
          '5.5.670',
          '5.5.660',
          '5.5.650',
          '5.5.640',
          '5.5.3',
          '5.5.2',
          '5.5.1',
          '5.4.4',
          '5.4.3',
          '5.4.0',
          '5.3.97',
          '5.3.0'
        ];

my $dists = [
    ['Acme-CPANAuthors-BackPAN-OneHundred']
];

my $profile1 = {
          'display' => 'Barbie (BARBIE)',
          'addressid' => '4',
          'fulldate' => '201411010004',
          'email' => 'barbie@missbarbell.co.uk',
          'guid' => 'guid-test-4',
          'pause' => 'BARBIE',
          'id' => '4',
          'testerid' => '1',
          'name' => 'Barbie',
          'contact' => 'barbie@cpan.org',
          'address' => 'Barbie <barbie@missbarbell.co.uk>'
        };
my $profile2 = {
          'address' => 'Barbie <barbie@missbarbell.co.uk>',
          'testerid' => '1',
          'name' => 'Barbie',
          'pause' => 'BARBIE',
          'email' => 'barbie@missbarbell.co.uk',
          'addressid' => '4',
          'contact' => 'barbie@cpan.org',
          'display' => 'Barbie (BARBIE)'
        };

# -----------------------------------------------------------------------------
# Set up

my $loader = Labyrinth::Test::Harness->new( keep => 0 );
my $dir = $loader->directory;

my $cpanstats = create_database();

my $res = $loader->prep(
    sql     => [ "t/data/test-base.sql" ],
    files   => { 
        't/data/phrasebook.ini' => 'cgi-bin/config/phrasebook.ini',
        't/data/cpan-config.ini' => 'cgi-bin/config/cpan-config.ini'
    },
    config  => {
        'INTERNAL'  => { logclear => 0, cpan_config => $dir . '/cgi-bin/config/cpan-config.ini' },
        'CPANSTATS' => $cpanstats
    }
);
diag($loader->error)    unless($res);

SKIP: {
    skip "Unable to prep the test environment", 47  unless($res);

    $res = is($loader->labyrinth(@plugins),1);
    diag($loader->error)    unless($res);

    # -------------------------------------------------------------------------
    # Public methods

    my $cpan = Labyrinth::Plugin::CPAN->new();
    isa_ok($cpan,'Labyrinth::Plugin::CPAN');

    my $dbx = $cpan->DBX('cpanstats');
    isa_ok($dbx,'Labyrinth::DBUtils');
    my @rows = $dbx->GetQuery('array','GetAuthorDists','BARBIE');
    is_deeply(\@rows,$dists,'.. got matching author dists');

    $cpan->Configure();
    is_deeply($cpan->exceptions,    $exceptions,    '.. matches exceptions');
    is_deeply($cpan->symlinks,      $symlinks,      '.. matches symlinks');
    is_deeply($cpan->merged,        $merged,        '.. matches merged');
    is_deeply($cpan->ignore,        $ignore,        '.. matches ignore');
    is_deeply($cpan->osnames,       $osnames,       '.. matches osnames');
    is_deeply($cpan->mklist_perls,  $perls,         '.. matches perls');

    #diag('my $exceptions = '    .Dumper($cpan->exceptions));
    #diag('my $symlinks = '      .Dumper($cpan->symlinks));
    #diag('my $merged = '        .Dumper($cpan->merged));
    #diag('my $ignore = '        .Dumper($cpan->ignore));
    #diag('my $osnames = '       .Dumper($cpan->osnames));
    #diag('my $perls = '         .Dumper($cpan->mklist_perls));
    
    my ($osname,$oscode) = $cpan->OSName('GNUKFREEBSD');
    is($osname,'Debian GNU/kFreeBSD','.. returns correct OS name');
    is($oscode,'gnukfreebsd','.. returns correct OS code');

    ($osname,$oscode) = $cpan->OSName('BLAH');
    is($osname,'BLAH','.. returns correct OS name');
    is($oscode,'blah','.. returns correct OS code');

    ($osname,$oscode) = $cpan->OSName();
    is($osname,undef,'.. returns no OS name');
    is($oscode,undef,'.. returns no OS code');

    is( $cpan->check_oncpan('Acme-CPANAuthors-BackPAN-OneHundred','1.02'), 0, '.. not on CPAN');
    is( $cpan->check_oncpan('Acme-CPANAuthors-BackPAN-OneHundred','1.03'), 1, '.. on CPAN');

    my @testers = (
        [ 'Barbie <barbie@missbarbell.co.uk>', 'barbie@missbarbell.co.uk', 'Barbie', 2, 2 ],
        [ 'Example <barbie@example.com>', 'barbie@example.com', 'CPAN Tester', -1, 0 ],
        [ undef, 'admin@cpantesters.org', 'CPAN Testers Admin', -1, 0 ]
    );

    for my $tester (@testers) {
        my ($email,$name,$userid,$addressid) = $cpan->FindTester($tester->[0]);
        is($email,      $tester->[1], ".. email matches for FindTester ($tester->[0])");
        is($name,       $tester->[2], '.. name matches for FindTester');
        is($userid,     $tester->[3], '.. userid matches for FindTester');
        is($addressid,  $tester->[4], '.. addressid matches for FindTester');
    }

    my $profile = $cpan->GetTesterProfile('guid-test-4');
    is_deeply($profile,$profile1);
    $profile = $cpan->GetTesterProfile('guid-test-4');
    is_deeply($profile,$profile1); # second call should use cache
    $profile = $cpan->GetTesterProfile('guid-test-5','Barbie <barbie@missbarbell.co.uk>');
    is_deeply($profile,$profile2); # guid not found, using tester address
    $profile = $cpan->GetTesterProfile('guid-test-6');
    is_deeply($profile,undef); # no guid, using tester address
    $profile = $cpan->GetTesterProfile();
    is_deeply($profile,undef); # no guid or address

    $loader->refresh( \@plugins, { user => { name => 'pause:BARBIE', author => undef, fakename => undef, tester => undef } } );
    $cpan->Rename();
    is($tvars{user}{name},'pause:BARBIE','.. Rename pause:BARBIE');
    is($tvars{user}{author},'BARBIE');
    is($tvars{user}{tester},undef);
    is($tvars{user}{fakename},'BARBIE');

    $loader->refresh( \@plugins, { user => { name => 'imposter:Barbie', author => undef, fakename => undef, tester => undef } } );
    $cpan->Rename();
    is($tvars{user}{name},'imposter:Barbie','.. Rename imposter:Barbie');
    is($tvars{user}{author},'BARBIE');
    is($tvars{user}{tester},undef);
    is($tvars{user}{fakename},'BARBIE');

    $loader->refresh( \@plugins, { user => { name => 'imposter:2', author => undef, fakename => undef, tester => undef } } );
    $cpan->Rename();
    is($tvars{user}{name},'imposter:2','.. Rename imposter:2');
    is($tvars{user}{author},undef);
    is($tvars{user}{tester},2);
    is($tvars{user}{fakename},'Barbie');
}

sub create_database {
    my $td1 = Test::Database->handle( 'mysql' );
    unless($td1) {
        die "Unable to load a test database instance.";
        return 0;
    }

    Labyrinth::Test::Harness::create_mysql_databases($td1,['t/data/test-cpanstats.sql']);

    my %opts;
    ($opts{dsn}, $opts{dbuser}, $opts{dbpass}) =  $td1->connection_info();
    ($opts{driver})    = $opts{dsn} =~ /dbi:([^;:]+)/;
    ($opts{database})  = $opts{dsn} =~ /database=([^;]+)/;
    ($opts{database})  = $opts{dsn} =~ /dbname=([^;]+)/     unless($opts{database});
    ($opts{dbhost})    = $opts{dsn} =~ /host=([^;]+)/;
    ($opts{dbport})    = $opts{dsn} =~ /port=([^;]+)/;
    my %db_config = map {my $v = $opts{$_}; defined($v) ? ("cpanstats_$_" => $v) : () }
                        qw(driver database dbfile dbhost dbport dbuser dbpass);

    $db_config{cpanstats_dictionary} = 'CPANSTATS';
    return \%db_config;
}