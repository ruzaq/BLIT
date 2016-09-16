#!/usr/bin/perl -w
# tp-theft (http://thinkwiki.org/wiki/Script_for_theft_alarm_using_HDAPS)
# This script uses the HDAPS accelerometer found on recent ThinkPad models
# to emit an audio alarm when the laptop is tilted. In sufficiently
# populated environments, it can be used as a laptop theft deterrent.
#
# This file is placed in the public domain and may be freely distributed.
#
# 2006-05-16: Script simplified by Guido Socher, just beep

use strict;
use vars qw($opt_a $opt_s $opt_h);
use Getopt::Std;
use Time::HiRes qw (sleep);
sub help();
#
getopts("ash")||die "ERROR: No such option. -h for help\n";
help() if ($opt_h);
#
##############################
# alarms are generated with writing 15 to /proc/acpi/ibm/beep
# To stop it you need to run 
# tp-theft -s
#
# meaning of ACPI sounds -- /proc/acpi/ibm/beep
# 0 - stop a sound in progress (but use 17 to stop 16)
# 2 - two beeps, pause, third beep ("low battery")
# 3 - single beep
# 4 - high, followed by low-pitched beep ("unable")
# 5 - single beep
# 6 - very high, followed by high-pitched beep ("AC/DC")
# 7 - high-pitched beep
# 9 - three short beeps
# 10 - very long beep
# 12 - low-pitched beep
# 15 - three high-pitched beeps repeating constantly, stop with 0
# 16 - one medium-pitched beep repeating constantly, stop with 17
# 17 - stop 16
##############################

my $thresh = 0.9;   # tilt threshold (increase value to decrease sensitivity)
my $interval = 0.1;  # sampling interval in seconds
my $depth = 8;       # number of recent samples to analyze
my $pos_file='/sys/devices/platform/hdaps/position';
my $blink_speed='0.25';

##############################

sub get_pos(){
    # The file looks like this:
    # (383,371)
    open(POS,$pos_file) or die "Can't open HDAPS file $pos_file: $!\n";
    $_=<POS>;
    m/^\((-?\d+),(-?\d+)\)$/ or die "Can't parse $pos_file content\n";
    return ($1,$2);
}

sub stddev(@) {
    my $sum=0;
    my $sumsq=0;
    my $n=$#_+1;
    for my $v (@_) {
        $sum += $v;
        $sumsq += $v*$v;
    }
    return sqrt($n*$sumsq - $sum*$sum)/($n*($n-1));
}

sub alarm_on {
        open (BEEP,">/proc/acpi/ibm/beep")|| die "ERROR: can not write to /proc/acpi/ibm/beep\n";
        print BEEP "15";
        close BEEP;
}
sub alarm_off {
        open (BEEP,">/proc/acpi/ibm/beep")|| die "ERROR: can not write to /proc/acpi/ibm/beep\n";
        print BEEP "0";
        close BEEP;
}

sub light_on {
        open (BEEP,">/proc/acpi/ibm/light")|| die "ERROR: can not write to /proc/acpi/ibm/light\n";
        print BEEP "on";
        close BEEP;
}
sub light_off {
        open (BEEP,">/proc/acpi/ibm/light")|| die "ERROR: can not write to /proc/acpi/ibm/light\n";
        print BEEP "off";
        close BEEP;
}


sub help(){
print "tp-theft -- use the Thinkpad built-in two-axis accelerometer, 
as part of the HDAPS feature to generate a theft alarm.

USAGE: tp-theft [-ahs]

OPTIONS: -a start alarm system
         -h this help
         -s stop alarm
         
The ibm_acpi kernel module needs to be loaded (e.g from an init-script).
ibm_acpi is used to generate the alarm.

USAGE EXAMPLES:
Start tp-theft (when you come back stop it with Crtl-c):
tp-theft -a

Stop an ongoing alarm:
tp-theft -s
";

exit 0;
}
if (! -w "/proc/acpi/ibm/beep"){
    die "ERROR: can not write to /proc/acpi/ibm/beep. Did you load the ibm_acpi kernel module? Did you make it writeable for an init script?";
}

if ($opt_s){
    open (BEEP,">/proc/acpi/ibm/beep")|| die "ERROR: can not write to /proc/acpi/ibm/beep\n";
    print BEEP "0";
    close BEEP;
    exit 0;
}
help() unless ($opt_a);
my (@XHIST, @YHIST);
my ($x,$y);
($x,$y) = get_pos();
for (1..$depth) {
    push(@XHIST,$x);
    push(@YHIST,$y);
}
my $xdev;
my $ydev;
my $tilted;
print "Starting accelerometer monitor...\n";
while (1) {
    ($x,$y) = get_pos();
    shift(@XHIST); push(@XHIST,$x);
    shift(@YHIST); push(@YHIST,$y);
    $xdev = stddev(@XHIST);
    $ydev = stddev(@YHIST);

    # Print variance and history
    #print "debug X: v=$xdev (".join(',',@XHIST).")  Y: v=$ydev (".join(",",@YHIST).")\n";

    $tilted = $xdev>$thresh || $ydev>$thresh;
    if ($tilted){
        system("/usr/bin/logger -p authpriv.alert -t ThinkPad-AntiTheft Theft ALARM!!");
        # print "Theft ALARM!!\n";
        # this will block until the command is played:
        alarm_on();
        for my $i (0..5) {
            light_on();
            sleep ($blink_speed);
            light_off();
            sleep ($blink_speed);
        }
        alarm_off();
        exit 1;
    }
    select(undef, undef, undef, $interval); # sleep
}
# vim:sw=4:ts=4:si:et:nowrap:
