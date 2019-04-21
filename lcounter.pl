#!/usr/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
use Carp qw(croak);
use File::Basename qw(basename);
use DateTime;
use feature qw(say);
use constant ARRAY => ref [];
use constant HASH  => ref {};


our $VERSION = '1.02';
our $LAST    = '2019-04-21';
our $FIRST   = '2018-09-05';


#----------------------------------My::Toolset----------------------------------
sub show_front_matter {
    # """Display the front matter."""
    
    my $prog_info_href = shift;
    my $sub_name = join('::', (caller(0))[0, 3]);
    croak "The 1st arg of [$sub_name] must be a hash ref!"
        unless ref $prog_info_href eq HASH;
    
    # Subroutine optional arguments
    my(
        $is_prog,
        $is_auth,
        $is_usage,
        $is_timestamp,
        $is_no_trailing_blkline,
        $is_no_newline,
        $is_copy,
    );
    my $lead_symb = '';
    foreach (@_) {
        $is_prog                = 1  if /prog/i;
        $is_auth                = 1  if /auth/i;
        $is_usage               = 1  if /usage/i;
        $is_timestamp           = 1  if /timestamp/i;
        $is_no_trailing_blkline = 1  if /no_trailing_blkline/i;
        $is_no_newline          = 1  if /no_newline/i;
        $is_copy                = 1  if /copy/i;
        # A single non-alphanumeric character
        $lead_symb              = $_ if /^[^a-zA-Z0-9]$/;
    }
    my $newline = $is_no_newline ? "" : "\n";
    
    #
    # Fill in the front matter array.
    #
    my @fm;
    my $k = 0;
    my $border_len = $lead_symb ? 69 : 70;
    my %borders = (
        '+' => $lead_symb.('+' x $border_len).$newline,
        '*' => $lead_symb.('*' x $border_len).$newline,
    );
    
    # Top rule
    if ($is_prog or $is_auth) {
        $fm[$k++] = $borders{'+'};
    }
    
    # Program info, except the usage
    if ($is_prog) {
        $fm[$k++] = sprintf(
            "%s%s - %s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $prog_info_href->{titl},
            $prog_info_href->{expl},
            $newline,
        );
        $fm[$k++] = sprintf(
            "%sVersion %s (%s)%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $prog_info_href->{vers},
            $prog_info_href->{date_last},
            $newline,
        );
    }
    
    # Timestamp
    if ($is_timestamp) {
        my %datetimes = construct_timestamps('-');
        $fm[$k++] = sprintf(
            "%sCurrent time: %s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $datetimes{ymdhms},
            $newline,
        );
    }
    
    # Author info
    if ($is_auth) {
        $fm[$k++] = $lead_symb.$newline if $is_prog;
        $fm[$k++] = sprintf(
            "%s%s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $prog_info_href->{auth}{$_},
            $newline,
        ) for qw(name posi affi mail);
    }
    
    # Bottom rule
    if ($is_prog or $is_auth) {
        $fm[$k++] = $borders{'+'};
    }
    
    # Program usage: Leading symbols are not used.
    if ($is_usage) {
        $fm[$k++] = $newline if $is_prog or $is_auth;
        $fm[$k++] = $prog_info_href->{usage};
    }
    
    # Feed a blank line at the end of the front matter.
    if (not $is_no_trailing_blkline) {
        $fm[$k++] = $newline;
    }
    
    #
    # Print the front matter.
    #
    if ($is_copy) {
        return @fm;
    }
    else {
        print for @fm;
        return;
    }
}


sub validate_argv {
    # """Validate @ARGV against %cmd_opts."""
    
    my $argv_aref     = shift;
    my $cmd_opts_href = shift;
    my $sub_name = join('::', (caller(0))[0, 3]);
    croak "The 1st arg of [$sub_name] must be an array ref!"
        unless ref $argv_aref eq ARRAY;
    croak "The 2nd arg of [$sub_name] must be a hash ref!"
        unless ref $cmd_opts_href eq HASH;
    
    # For yn prompts
    my $the_prog = (caller(0))[1];
    my $yn;
    my $yn_msg = "    | Want to see the usage of $the_prog? [y/n]> ";
    
    #
    # Terminate the program if the number of required arguments passed
    # is not sufficient.
    #
    my $argv_req_num = shift; # (OPTIONAL) Number of required args
    if (defined $argv_req_num) {
        my $argv_req_num_passed = grep $_ !~ /-/, @$argv_aref;
        if ($argv_req_num_passed < $argv_req_num) {
            printf(
                "\n    | You have input %s nondash args,".
                " but we need %s nondash args.\n",
                $argv_req_num_passed,
                $argv_req_num,
            );
            print $yn_msg;
            while ($yn = <STDIN>) {
                system "perldoc $the_prog" if $yn =~ /\by\b/i;
                exit if $yn =~ /\b[yn]\b/i;
                print $yn_msg;
            }
        }
    }
    
    #
    # Count the number of correctly passed command-line options.
    #
    
    # Non-fnames
    my $num_corr_cmd_opts = 0;
    foreach my $arg (@$argv_aref) {
        foreach my $v (values %$cmd_opts_href) {
            if ($arg =~ /$v/i) {
                $num_corr_cmd_opts++;
                next;
            }
        }
    }
    
    # Fname-likes
    my $num_corr_fnames = 0;
    $num_corr_fnames = grep $_ !~ /^-/, @$argv_aref;
    $num_corr_cmd_opts += $num_corr_fnames;
    
    # Warn if "no" correct command-line options have been passed.
    if (not $num_corr_cmd_opts) {
        print "\n    | None of the command-line options was correct.\n";
        print $yn_msg;
        while ($yn = <STDIN>) {
            system "perldoc $the_prog" if $yn =~ /\by\b/i;
            exit if $yn =~ /\b[yn]\b/i;
            print $yn_msg;
        }
    }
    
    return;
}


sub show_elapsed_real_time {
    # """Show the elapsed real time."""
    
    my @opts = @_ if @_;
    
    # Parse optional arguments.
    my $is_return_copy = 0;
    my @del; # Garbage can
    foreach (@opts) {
        if (/copy/i) {
            $is_return_copy = 1;
            # Discard the 'copy' string to exclude it from
            # the optional strings that are to be printed.
            push @del, $_;
        }
    }
    my %dels = map { $_ => 1 } @del;
    @opts = grep !$dels{$_}, @opts;
    
    # Optional strings printing
    print for @opts;
    
    # Elapsed real time printing
    my $elapsed_real_time = sprintf("Elapsed real time: [%s s]", time - $^T);
    
    # Return values
    if ($is_return_copy) {
        return $elapsed_real_time;
    }
    else {
        say $elapsed_real_time;
        return;
    }
}


sub pause_shell {
    # """Pause the shell."""
    
    my $notif = $_[0] ? $_[0] : "Press enter to exit...";
    
    print $notif;
    while (<STDIN>) { last; }
    
    return;
}


sub construct_timestamps {
    # """Construct timestamps."""
    
    # Optional setting for the date component separator
    my $date_sep  = '';
    
    # Terminate the program if the argument passed
    # is not allowed to be a delimiter.
    my @delims = ('-', '_');
    if ($_[0]) {
        $date_sep = $_[0];
        my $is_correct_delim = grep $date_sep eq $_, @delims;
        croak "The date delimiter must be one of: [".join(', ', @delims)."]"
            unless $is_correct_delim;
    }
    
    # Construct and return a datetime hash.
    my $dt  = DateTime->now(time_zone => 'local');
    my $ymd = $dt->ymd($date_sep);
    my $hms = $dt->hms($date_sep ? ':' : '');
    (my $hm = $hms) =~ s/[0-9]{2}$//;
    
    my %datetimes = (
        none   => '', # Used for timestamp suppressing
        ymd    => $ymd,
        hms    => $hms,
        hm     => $hm,
        ymdhms => sprintf("%s%s%s", $ymd, ($date_sep ? ' ' : '_'), $hms),
        ymdhm  => sprintf("%s%s%s", $ymd, ($date_sep ? ' ' : '_'), $hm),
    );
    
    return %datetimes;
}


sub rm_duplicates {
    # """Remove duplicate items from an array."""
    
    my $aref = shift;
    my $sub_name = join('::', (caller(0))[0, 3]);
    croak "The 1st arg of [$sub_name] must be an array ref!"
        unless ref $aref eq ARRAY;
    
    my(%seen, @uniqued);
    @uniqued = grep !$seen{$_}++, @$aref;
    @$aref = @uniqued;
    
    return;
}
#-------------------------------------------------------------------------------


sub parse_argv {
    # """@ARGV parser"""
    
    my(
        $argv_aref,
        $cmd_opts_href,
        $run_opts_href,
    ) = @_;
    my %cmd_opts = %$cmd_opts_href; # For regexes
    
    # Parser: Overwrite default run options if requested by the user.
    my $field_sep = ',';
    foreach (@$argv_aref) {
        # Files
        push @{$run_opts_href->{files}}, $_ if -e;
        
        # Comment symbols
        if (/$cmd_opts{comment_symbs}/) {
            s/$cmd_opts{comment_symbs}//i;
            @{$run_opts_href->{comment_symbs}} = split /$field_sep/;
        }
        
        # Report file path
        if (/$cmd_opts{report_path}/) {
            s/$cmd_opts{report_path}//i;
            $run_opts_href->{report_path} = $_;
        }
        
        # Report file
        if (/$cmd_opts{report}/) {
            s/$cmd_opts{report}//i;
            $run_opts_href->{report} = $_;
        }
        
        # The front matter won't be displayed at the beginning of the program.
        if (/$cmd_opts{nofm}/) {
            $run_opts_href->{is_nofm} = 1;
        }
        
        # The shell won't be paused at the end of the program.
        if (/$cmd_opts{nopause}/) {
            $run_opts_href->{is_nopause} = 1;
        }
    }
    rm_duplicates($run_opts_href->{files});
    rm_duplicates($run_opts_href->{comment_symbs});
    
    return;
}


sub count_num_of_lines {
    # """Count the numbers of lines of designated text files."""
    
    my(
        $prog_info_href,
        $run_opts_href,
    ) = @_;
    
    my %files; # Numbers of lines, file by file
    my %tot_nums_of_lines = (
        comment => 0,
        blank   => 0,
        plain   => 0,
    );
    
    mkdir $run_opts_href->{report_path} if not -e $run_opts_href->{report_path};
    my $rpt = sprintf(
        "%s%s%s",
        $run_opts_href->{report_path},
        ($run_opts_href->{report_path} =~ /[\\\/]$/ ? '' : '/'),
        $run_opts_href->{report},
    );
    open my $rpt_fh, '>:encoding(UTF-8)', $rpt;
    my %tee_fhs = (
        rpt => $rpt_fh,
        scr => *STDOUT,
    );
    
    # Report file front matter
    my @fm = show_front_matter($prog_info_href, 'prog', 'auth', 'copy');
    my %datetimes = construct_timestamps('-');
    print $rpt_fh $_ for @fm;
    print $rpt_fh "Counted at [$datetimes{ymdhms}]\n";
    printf $rpt_fh (
        "Comment symbol%s: [%s]\n\n",
        ($run_opts_href->{comment_symbs}[1] ? 's' : ''),
        join(" ", @{$run_opts_href->{comment_symbs}}),
    );
    
    # Count the numbers of lines, file by file.
    foreach my $file (@{$run_opts_href->{files}}) {
        open my $fh, '<', $file;
        foreach my $line (<$fh>) {
            # Comment line
            if (grep { $line =~ /^\s*$_/ } @{$run_opts_href->{comment_symbs}}) {
                $files{$file}{comment}++;
                next;
            }
            # Blank line
            if ($line =~ /^\s*$/) {
                $files{$file}{blank}++;
                next;
            }
            # Plain line
            $files{$file}{plain}++;
        }
    }
    
    foreach my $file (sort keys %files) {
        # Print the numbers of lines, file by file.
        foreach my $fh (sort values %tee_fhs) {
            print $fh "File [$file]\n";
            printf $fh (
                "%-24s %s\n",
                "Number of $_ lines:",  # arg 1
                $files{$file}{$_} // 0, # arg 2
            ) for qw(comment blank plain);
            print $fh "\n";
        }
        
        # Count the total numbers of lines.
        $tot_nums_of_lines{comment} += $files{$file}{comment}
            if $files{$file}{comment};
        $tot_nums_of_lines{blank} += $files{$file}{blank}
            if $files{$file}{blank};
        $tot_nums_of_lines{plain} += $files{$file}{plain}
            if $files{$file}{plain};
    }
    
    # Print the total numbers of lines.
    foreach my $fh (sort values %tee_fhs) {
        print $fh "Total numbers of lines\n";
        printf $fh (
            "%-24s %s\n",
            "Number of $_ lines:",       # arg 1
            $tot_nums_of_lines{$_} // 0, # arg 2
        ) for qw(comment blank plain);
    }
    
    close $rpt_fh;
    
    # Notification
    printf("\n[%s] generated.\n", $rpt);
    
    return;
}


sub lcounter {
    # """lcounter main routine"""
    
    if (@ARGV) {
        my %prog_info = (
            titl       => basename($0, '.pl'),
            expl       => 'Count the numbers of lines of text files',
            vers       => $VERSION,
            date_last  => $LAST,
            date_first => $FIRST,
            auth       => {
                name => 'Jaewoong Jang',
                posi => 'PhD student',
                affi => 'University of Tokyo',
                mail => 'jan9@korea.ac.kr',
            },
        );
        my %cmd_opts = ( # Command-line opts
            comment_symbs => qr/-?-comment(?:_symbs)?\s*=\s*/i,
            report_path   => qr/-?-(?:re?po?r?t_)?path\s*=\s*/i,
            report        => qr/-?-(?:re?po?r?t|o(?:ut)?)\s*=\s*/i, # -o: legacy
            nofm          => qr/-?-nofm\b/i,
            nopause       => qr/-?-nopause\b/i,
        );
        my %run_opts = ( # Program run opts
            files         => [],
            comment_symbs => ['#'],
            report_path   => '.',
            report        => "$prog_info{titl}_result.txt",
            is_nofm       => 0,
            is_nopause    => 0,
        );
        
        # ARGV validation and parsing
        validate_argv(\@ARGV, \%cmd_opts);
        parse_argv(\@ARGV, \%cmd_opts, \%run_opts);
        
        # Notification - beginning
        show_front_matter(\%prog_info, 'prog', 'auth')
            unless $run_opts{is_nofm};
        
        # Main
        count_num_of_lines(\%prog_info, \%run_opts);
        
        # Notification - end
        show_elapsed_real_time();
        pause_shell()
            unless $run_opts{is_nopause};
    }
    
    system("perldoc \"$0\"") if not @ARGV;
    
    return;
}


lcounter();
__END__

=head1 NAME

lcounter - Count the numbers of lines of text files

=head1 SYNOPSIS

    perl lcounter.pl [file ...] [-comment_symbs=symb ...]
                     [-report_path=path] [-report=file]
                     [-nofm] [-nopause]

=head1 DESCRIPTION

    lcounter counts the numbers of lines of the designated text files.
    Multiple text files can be designated simultaneously and, therefore,
    the total numbers of lines of source code consisting of multiple
    module/package files can be counted as a whole.
    Lines are counted as:
    - Comment line
    - Blank line
    - Plain line

=head1 OPTIONS

    file ...
        Text files whose lines will be counted.

    -comment_symbs=symb ... (short form: -comment, default: #)
        Comment symbols of the designated text files.
        Multiple symbols are separated by the comma (,).

    -report_path=path (short form: -path, default: current working directory)
        The path in which the report file will be stored.

    -report=file (short form: -rpt, default: lcounter_result.txt)
        The report file to which the counted numbers of lines will be written.

    -nofm
        The front matter will not be displayed at the beginning of the program.

    -nopause
        The shell will not be paused at the end of the program.

=head1 EXAMPLES

    perl lcounter.pl lcounter.pl ./lib/My/Toolset.pm ./lib/My/Aux.pm
    perl lcounter.pl ms.tex -comment=%
    perl lcounter.pl depl.bat -comment=rem
    perl lcounter.pl mapdl.mac -comment=! -rpt=mac_num_lines.txt
    perl lcounter.pl accv.gp -comment=#,%
    perl lcounter.pl USAGE -path=./lines_counted

=head1 REQUIREMENTS

Perl 5

=head1 SEE ALSO

L<lcounter on GitHub|https://github.com/jangcom/lcounter>

=head1 AUTHOR

Jaewoong Jang <jan9@korea.ac.kr>

=head1 COPYRIGHT

Copyright (c) 2018-2019 Jaewoong Jang

=head1 LICENSE

This software is available under the MIT license;
the license information is found in 'LICENSE'.

=cut
