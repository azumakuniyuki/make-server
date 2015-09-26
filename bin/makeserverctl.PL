#!/usr/bin/env perl
=head1 DESCRIPTION
    Support script for github.com/azumakuniyuki/make-server

=head1 USAGE
    Try --help option
=cut
#   ____ _     ___ 
#  / ___| |   |_ _|
# | |   | |    | | 
# | |___| |___ | | 
#  \____|_____|___|
#                  
package CLI;
use strict;
use warnings;
use IO::File;
use Fcntl qw(:flock);
use File::Basename qw/basename/;
use Sys::Syslog;
use Time::Piece;
use Data::Dumper;

sub new {
    my $class = shift;
    my $argvs = { @_ };
    my $param = {};
    my $thing = undef;

    return $class if ref $class eq __PACKAGE__;
    $param = {
        'started' => Time::Piece->new,
        'verbose' => $argvs->{'verbose'} || 0,
        'command' => $argvs->{'command'} ? $argvs->{'command'} : $0,
        'runmode' => $argvs->{'runmode'} || 1,
        'stream' => {
            'stdin'  => -t STDIN  ? 1 : 0,
            'stdout' => -t STDOUT ? 1 : 0,
            'stderr' => -t STDERR ? 1 : 0,
        },
    };
    $thing = bless $param, __PACKAGE__;
    return $thing;
}

sub stdin  { shift->{'stream'}->{'stdin'} }
sub stdout { shift->{'stream'}->{'stdout'} }
sub stderr { shift->{'stream'}->{'stderr'} }
sub r { my( $x, $y ) = @_; $x->{'runmode'} = $y if defined $y; return $x->{'runmode'}; }
sub v { my( $x, $y ) = @_; $x->{'verbose'} = $y if defined $y; return $x->{'verbose'}; }

sub e {
    # @Description  Print error message and exit
    # @Param <mesg> (String) Error message text
    # @Param <bool> (Boolean) continue or not
    # @Return       1 or exit(1)
    my $self = shift;
    my $mesg = shift; return 0 unless length $mesg;
    my $cont = shift || 0;

    printf( STDERR " * error0: %s\n", $mesg ) if $self->stderr;
    printf( STDERR " * error0: ******** ABORT ********\n" ) if $self->stderr;
    $cont ? return 1 : exit(1);
}

sub p {
    # @Description  Print debug message
    # @Param <mesg> (String) Debug message text
    # @Param <level>(Integer) Debug level
    # @Return       0 or 1
    my $self = shift;
    my $mesg = shift; return 0 unless length $mesg;
    my $rung = shift || 1;

    return 0 unless $self->stderr;
    return 0 unless $self->v;
    return 0 unless $self->v >= $rung;

    chomp $mesg; printf( STDERR " * debug%d: %s\n", $rung, $mesg );
    return 1;
}

1;

#                  _       
#  _ __ ___   __ _(_)_ __  
# | '_ ` _ \ / _` | | '_ \ 
# | | | | | | (_| | | | | |
# |_| |_| |_|\__,_|_|_| |_|
#                          
package main;
use strict;
use warnings;

BEGIN {
    if( @ARGV ) {
        if( $ARGV[0] eq '--modules' ) {
            require IO::File;
            my $filehandle = IO::File->new( $0, 'r' ) || die $!;
            my $modulelist = [];
            my $modulename = '';

            while( ! $filehandle->eof ) {
                my $r = $filehandle->getline;
                next if $r =~ /\A\s*#/;
                next if $r =~ /\A=/;
                next if $r =~ /\A\s*\z/;
                next if $r =~ /\buse (?:strict|warnings|utf8)/;

                $modulename = $1 if $r =~ m{\b(?:use|require)[ ]+([A-Za-z][0-9A-Za-z:]+)[ ;]};

                next unless $modulename;
                next if grep { $modulename eq $_ } @$modulelist;
                push @$modulelist, $modulename; $modulename = q();
            }
            $filehandle->close;
            printf( "%s\n", $_ ) for @$modulelist;
            exit 0;

        } elsif( $ARGV[0] eq '--cpanm' ) {
            # Get cpanm command
            my $commandurl = 'http://xrl.us/cpanm';
            my $searchpath = [ '/usr/local/bin/', '/usr/bin/', '/bin/', './' ];
            my $commandset = { 'wget' => '-c', 'curl' => '-LOk' };
            my $scriptpath = qx/which cpanm/; chomp $scriptpath;
            my $getcommand = q();

            if( -x $scriptpath ) {
                printf "%s\n", $scriptpath;
                exit 0;
            }

            foreach my $e ( keys %$commandset ) {
                # Find command to get something from URL
                $getcommand   = qx/which $e/; chomp $getcommand;
                $getcommand   = '' unless -x $getcommand;
                $getcommand ||= shift @{ [ grep { $_ .= $e; $_ if -x $_ } @$searchpath ] };
                next unless $getcommand;

                $getcommand .= ' '.$commandset->{ $e };
                last;
            }

            $scriptpath = './cpanm';
            if( -f $scriptpath ) {
                chmod( '0755', $scriptpath );
                printf( "%s\n", $scriptpath ); 
                exit 0;
            }
            system qq($getcommand $commandurl > /dev/null 2>&1);
            chmod( '0755', $scriptpath ) if -x $scriptpath;
            printf "%s\n", $scriptpath;
            exit 0;
        }
    }
}

use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use File::Basename qw/basename/;
use File::Copy;

my $Version = '3.0.0';
my $RootDir = '@@MAKESERVER_DISTRIBUTION_DIRECTORY@@';
my $SysRoot = '@@MAKESERVER_MAINPROGRAMS_DIRECTORY@@';
my $Setting = {};
my $Default = {};
my $Options = {
    'exec'   => ( 1 << 0 ),
    'test'   => ( 1 << 1 ),
    'setup'  => ( 1 << 2 ),
    'update' => ( 1 << 3 ),
    'shadow' => ( 1 << 4 ),
    'roles'  => ( 1 << 5 ),
};
my $Command = CLI->new( 
    'command' => join( ' ', $0, @ARGV ),
);
my $SaltIDs = {
    'MD5'       => 1,
    'SHA256'    => 5,
    'SHA512'    => 6,
};

$Command->r( parseoptions() );

if( $Command->r & $Options->{'exec'} ) {

    if( $Command->r & $Options->{'setup'} ) {
        # --setup option and --update option
        my $currentdir = qx|pwd|; chomp $currentdir;
        my $makefiles0 = [ 
            'Makefile', 'Vagrant.mk', 'Ansible.mk', 'Serverspec.mk',
            'Rakefile', '.rspec', 
            '.make-server-directory', '.default-inventoryfile',
            '.default-playbook-file',
        ];
        my $subdirlist = [ 
            '.ssh', 'lib', 'script', $SysRoot, $SysRoot.'/roles', $SysRoot.'/spec',
        ];
        my $tobecopied = [];

        if( $RootDir ne $currentdir ) {
            # Current directory is not $RootDir
            while(1) {
                if( -d $RootDir ) {
                    if( -x $RootDir ) {
                        $Command->p( 'make-server root directory = '.$RootDir, 1 );
                    } else {
                        $Command->e( 'make-server root directory:'.$RootDir.' is not executable', 1 );
                        last;
                    }
                } else {
                    $Command->e( 'make-server root directory:'.$RootDir.' does not exist', 1 );
                    last;
                }

                if( -w $currentdir ) {
                    $Command->p( 'Destination directory = '.$currentdir, 1 );

                } else {
                    # Destination directory is not writable
                    $Command->e( $currentdir.' is not writable', 1 );
                    last;
                }

                push @$tobecopied, @$makefiles0,
                push @$tobecopied, map { $_.'/Makefile' } @$subdirlist;

                for my $e ( @$tobecopied ) {
                    # Copy each Makefile to the current directory
                    my $f = sprintf( "%s/%s", $RootDir, $e );
                    my $v = sprintf( "%s/%s", $currentdir, $e );

                    next unless -e $f;
                    next unless -r $f;

                    if( -e $v ) {
                        # Target file already exists
                        if( $Command->r & $Options->{'update'} ) {

                            if( $e =~ m/\A[.]default-.+/ ) {
                                # .default-* files are not updated
                                $Command->p( '[ SKIP ] '.$v.' is not updated', 1 );

                            } else {
                                # Update each Makefile
                                $Command->p( '[UPDATE] '.$v, 1 );
                                copy( $f, $v ) 
                            }

                        } else {
                            # Each Makefile already exists
                            $Command->p( '[ SKIP ] '.$v.' already exists', 1 );
                        }
                    } else {
                        # Target file does not exist
                        if( $e =~ m|.+/.+| ) {
                            # Make sub directory
                            my $d = sprintf( "%s/%s", $currentdir, [ split('/',$e) ]->[0] );
                            $Command->p( '[ MAKE ] '.$d, 1 );
                            mkdir $d;
                        }

                        $Command->p( '[ COPY ] '.$v, 1 );
                        copy( $f, $v ) 
                    }
                }

                for my $e ( @$subdirlist ) {
                    # Copy files in each directory
                    my $d = sprintf( "%s/%s", $RootDir, $e );
                    my $v = sprintf( "%s/%s", $currentdir, $e );
                }
                last;
            }
        } else {
            # Current directory is the root directory
            $Command->e( 'Current directory is the root directory of "make-server": '.$currentdir );
        }

    } elsif( $Command->r & $Options->{'roles'} ) {
        # Show available roles
        require File::Find;
        my $currentdir = qx|pwd|; chomp $currentdir;
        my $rolestable = { 'root' => [], 'user' => [] };
        my $copiedrole = [];
        my $tobeseeked = [ $RootDir.'/'.$SysRoot.'/roles' ];
        my $findoption = { 'wanted' => \&roleindex };

        push @$tobeseeked, $currentdir unless $currentdir =~ m/$RootDir/;
        for my $e ( @$tobeseeked ) {
            # Find tasks/main.yml from each directory
            my $v = $e; $v .= '/' unless $v =~ m|/\z|;
            File::Find::finddepth( $findoption, $v );
        }

        sub roleindex {
            my $foundfile = $_;
            my $directory = '';
            my $rolespath = '';
            {
                no warnings 'once'; 
                $directory = $File::Find::dir;
                $rolespath = $File::Find::name;
            }

            return undef unless $directory =~ m|/tasks\z|;
            return undef unless $foundfile =~ m|\Amain[.]yml\z|;
            $directory =~ s|/tasks\z||;

            if( $rolespath =~ m|$RootDir/$SysRoot| ) {
                # The role exists in $RootDir
                push @{ $rolestable->{'root'} }, $directory;

            } else {
                # The role exists only in `pwd`
                push @{ $rolestable->{'user'} }, $directory;
            }
            return 0;
        }

        for my $e ( @{ $rolestable->{'user'} } ) {
            # Print roles in user's directory
            my $v = $e; $v =~ s|\A.+$SysRoot/roles/||;
            my $x = '.';

            printf( "%s", '- ' );
            printf( "%s", $v );
            printf( " %s ", $x x ( 32 - length($v) ) );
            if( -d sprintf( "%s/%s/roles/%s", $RootDir, $SysRoot, $v ) ) {
                # Installed role
                printf( "%s\n", 'Installed' );
                push @$copiedrole, $v;

            } else {
                # User-defined role
                printf( "%s\n", 'Only in '.$currentdir );
            }
        }

        for my $e ( @{ $rolestable->{'root'} } ) {
            # Print roles in user's directory
            my $v = $e; $v =~ s|\A$RootDir/$SysRoot/roles/||;
            my $x = '.';

            next if grep { $v eq $_ } @$copiedrole;

            printf( "%s", '- ' );
            printf( "%s", $v );
            printf( " %s ", $x x ( 32 - length($v) ) );
            printf( "%s\n", 'Available to be installed using `make <role-name>-role`' );
        }

    } elsif( $Command->r & $Options->{'shadow'} ) {
        # Codes bellow have been moved from bin/make-up-shadow
        require Crypt::Passwd::XS;

        my $plaintext1 = shift @ARGV;
        my $hashedtext = '';
        my $saltstring = '';
        my $partofsalt = '';
        my $saltsource = [ 0..9, 'A'..'Z', 'a'..'z' ];

        while(1) {
            last if length $saltstring == 8;
            $saltstring .= $saltsource->[ int(rand(scalar(@$saltsource) - 1)) ];
        }

        $partofsalt .= sprintf( "%s%d%s", '$', $SaltIDs->{ $Setting->{'algorithm'} }, '$' );
        $partofsalt .= $saltstring;

        $Command->p( 'Algorithm = '.$Setting->{'algorithm'}, 1 );
        $Command->p( 'Plain text = '.$plaintext1, 1 );
        $Command->p( 'Salt string = '.$saltstring, 1 );

        if( $Setting->{'algorithm'} eq 'MD5' ) {
            # $1$...
            $hashedtext = Crypt::Passwd::XS::unix_md5_crypt( $plaintext1, $saltstring );

        } elsif( $Setting->{'algorithm'} eq 'SHA256' ) {
            # $5$...
            $hashedtext = Crypt::Passwd::XS::unix_sha256_crypt( $plaintext1, $saltstring );

        } elsif( $Setting->{'algorithm'} eq 'SHA512' ) {
            # $6$...
            $hashedtext = Crypt::Passwd::XS::unix_sha512_crypt( $plaintext1, $saltstring );
        }

        printf( "%s\n", $hashedtext );

    } else {
        help();
        exit;
    }
}

sub location {
    # @Description  Check the current directory is the root directory or not
    # @Param <none>
    # @Return       0 = is not the root directory, 1 = is in the root directory
    my $currdir = qx|pwd|; chomp $currdir;
    my $rexpath = qr|$RootDir/.+|;
    return 1 if $RootDir eq $currdir;
    return 1 if $currdir =~ $rexpath;
    return 0;
}

sub rootdir {
    # @Description  Print the path to root directory of make-server
    exit 1 if $RootDir =~ m/\A[@].+[@]\z/;
    print $RootDir."\n";
    exit 0
}

sub parseoptions {
    # @Description  Command line option parser
    # @Param <none>
    # @Return <v>   (Integer) The value of the run mode
    my $r = 0;      # Run mode value
    my $p = {};     # Parsed options
    my $o = [
        'setup',            # Setting up files at current directory
        'update-makefile',  # Update(Override) Makefiles and other files
        'shadow-passwd',    # Make shadow password string
        'role-index',       # Show installed roles and available roles
        'algorithm|a=s',    # For --shadow option
    ];

    Getopt::Long::GetOptions( $p, 'verbose|v+', @$o,
        'data'      => sub { print <DATA>; exit 0; },
        'help'      => sub { help(); exit 0; },
        'version'   => sub { printf( STDERR "%s\n", $Version ); exit 0; },
        'rootdir'   => sub { rootdir(); },
        'location'  => sub { exit location(); },
    );

    if( defined $p->{'shadow-passwd'} ) {
        # Options for making shadow password string
        $r |= $Options->{'shadow'};

        if( $p->{'algorithm'} ) {
            # Set the value of "algorithn"
            if( grep { uc( $p->{'algorithm'} ) eq $_ } ( keys %$SaltIDs ) ) {
                # Check the value of algorithm and set into $Setting variable
                $Setting->{'algorithm'} = uc $p->{'algorithm'};
            }
        }
        $Setting->{'algorithm'} ||= 'SHA512';

    } else {
        # Options except --shadow-passwd
        if( defined $p->{'role-index'} ) {
            # role index
            $r |= $Options->{'roles'};

        } elsif( defined $p->{'setup'} || defined $p->{'update-makefile'} ) {
            # setup
            $r |= $Options->{'setup'};
            $r |= $Options->{'update'} if defined $p->{'update-makefile'};
            $p->{'verbose'}++;
        }
    }
    $Setting = $Default unless keys %$Setting;

    # Check the value of $RootDir, $SysRoot
    $Command->e( 'Invalid value in $RootDir: '.$RootDir ) if $RootDir =~ m/\A[@].+[@]\z/;
    $Command->e( 'Invalid value in $SysRoot: '.$SysRoot ) if $SysRoot =~ m/\A[@].+[@]\z/;
    $Command->e( 'Empty value in $RootDir: '.$RootDir ) unless length $RootDir;
    $Command->e( 'Empty value in $SysRoot: '.$SysRoot ) unless length $SysRoot;

    $r |= $Options->{'exec'};

    $Command->v( $p->{'verbose'} );
    $Command->p( sprintf( "Debug level = %d", $Command->v ), 1 );
    $Command->p( sprintf( "Run mode = %d", $r ), 1 );
    return $r;
}

sub help {
    # @Description  Print help message
    printf( STDERR "%s OPTIONS \n", $0 );
    printf( STDERR "  --rootdir           : Print the distribution directory and exit\n" );
    printf( STDERR "  --location          : Check current directory is distribution directory or not\n" );
    printf( STDERR "                        This script exits at status 1 when here is distribution directory\n" );
    printf( STDERR "  --setup             : Setting up Makefiles at current directory\n" );
    printf( STDERR "  --update-makefile   : Update Makefiles in current directory\n" );
    printf( STDERR "  --role-index        : Show available roles\n" );
    printf( STDERR "\n" );
    printf( STDERR "%s OPTIONS <plain-text>\n", $0 );
    printf( STDERR "  --shadow-passwd     : Create shadow password string\n" );
    printf( STDERR "  -a, --algorithm <v> : Shadow password algorithm: MD5, SHA256, SHA512(default)\n" );
    printf( STDERR "\n" );
    printf( STDERR '  --help              : Help screen'."\n" );
    printf( STDERR '  --version           : Print the version number'."\n" );
    printf( STDERR '  -v, --verbose       : Verbose mode'."\n" );
    printf( STDERR '  --cpanm             : Find or download cpanm command'."\n" );
    printf( STDERR '  --modules           : Print required perl module list'."\n" );
    printf( STDERR "\n" );
}

__DATA__
