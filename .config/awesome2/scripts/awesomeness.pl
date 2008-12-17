#!/usr/bin/perl

# TODO:
# 1. Create a config file ($HOME/.awesomeness)
# 2. Make everything here a variable, configurable from the config file
#
#
# Val Polyakov <val@polyakov.me>
#
# July 27, 2008

use strict;
use warnings;

# use Audio::MPD;
# use Mail::MboxParser;
use Sys::Statistics::Linux::CpuStats;
use Sys::Statistics::Linux::NetStats;
use Sys::Statistics::Linux::MemStats;
use Sys::Statistics::Linux::DiskUsage;
use Weather::Google;
use encoding 'utf8';

# my $mpd     = Audio::MPD->new();
# my $mbox    = "/var/mail/val";
# my $mb      = Mail::MboxParser->new( $mbox, decode     => 'NONE',);
my $gw;  				# Google weather
my $weather_renew = 0; 			# initialize the counter
$gw = new Weather::Google(98037);	# Grab initial data when awesomeness.pl starts up

while (1) {

   # Get the unread email count
   #
   # my $unread_email_count = 0;
   # for my $msg ($mb->get_messages) {
   	# my $email_status = $msg->header->{status};
   # 
   	# if ($email_status) {
   		# if ($msg->header->{status} !~ /^R/) {
       			# $unread_email_count += 1;
     		# }
   	# } else {
	   # $unread_email_count += 1;
   	# }
   # }	
  
  # Grab fresh weather data every 300 seconds 
  #
  if ($weather_renew == 300) {
     $gw = new Weather::Google(98037);
     $weather_renew = 0;
  }
  my $current_weather_temp = "unknown";
  if ($gw->{current}->{temp_f}) { $current_weather_temp = $gw->{current}->{temp_f}; }
  my $current_weather_condition = "unknown";
  if ($gw->{current}->{condition}) { $current_weather_condition = $gw->{current}->{condition}; }


  # Various disk variables + current time
  #
  my $dsk_boot = "/dev/sda3";
  my $dsk_root = "/dev/sda7";
  my $dsk_win  = "/dev/sda2";
  my $dsk_dat  = "/dev/sda5";
  my $time      = localtime;

  my $lxs     = Sys::Statistics::Linux::CpuStats->new;
  my $netlxs  = Sys::Statistics::Linux::NetStats->new;
  my $memlxs  = Sys::Statistics::Linux::MemStats->new;
  my $disklxs = Sys::Statistics::Linux::DiskUsage->new;

  $lxs->init;
  $netlxs->init;
  
  sleep(1);
  
  my $stat     = $lxs->get;
  my $netstat  = $netlxs->get;
  my $memstat  = $memlxs->get;
  my $diskstat = $disklxs->get;

  ### CPU and mem / swap
  my $cpu_total     = sprintf("%.0f", $stat->{cpu}->{total});
  my $real_free_per = sprintf("%.0f",$memstat->{realfreeper});
  my $mem_used_per  = 100 - $real_free_per;
  my $swap_used_per = sprintf("%.0f",$memstat->{swapusedper});

  ### Network (eth0 / wlan0)
  my $eth0_in_kbps  = sprintf("%.0f", $netstat->{eth0}->{rxbyt} / 1024);
  my $eth0_out_kbps = sprintf("%.0f", $netstat->{eth0}->{txbyt} / 1024);
  my $wlan0_in_kbps  = sprintf("%.0f", $netstat->{wlan0}->{rxbyt} / 1024);
  my $wlan0_out_kbps = sprintf("%.0f", $netstat->{wlan0}->{txbyt} / 1024);

  ### disks
  my $root_use_per  = $diskstat->{$dsk_root}->{usageper};
  my $dat_use_per   = $diskstat->{$dsk_dat}->{usageper};
  my $boot_use_per  = $diskstat->{$dsk_boot}->{usageper};
  my $win_use_per  = $diskstat->{$dsk_win}->{usageper};
  # print $root_use_per;

  ### MPD
  # my $current = $mpd->current();
  # my $status  = $mpd->status();
  # 
  # my $current_artist = "unknown";
  # my $current_title  = "unknown";
  # if ($current->{artist}) { $current_artist    = $current->{artist}; }
  # if ($current->{title})  { $current_title     = $current->{title}; }
# 
  # my $status_time_sofar = $status->{time}->{sofar}; 
  # my $status_time_total = $status->{time}->{total};
  

  system("echo 0 widget_tell sb_system tb_date text $time | awesome-client");
  
  system("echo 0 widget_tell sb_system tb_net_up text ETH_U: $eth0_out_kbps KB/s | awesome-client");
  system("echo 0 widget_tell sb_system gr_net_out data d_net_out  $eth0_out_kbps | awesome-client");

  system("echo 0 widget_tell sb_system tb_net_down text ETH_D: $eth0_in_kbps KB/s | awesome-client");
  system("echo 0 widget_tell sb_system gr_net_in data d_net_in $eth0_in_kbps | awesome-client");
 
  system("echo 0 widget_tell sb_system tb_net_up_wlan0 text WLN_U: $wlan0_out_kbps KB/s | awesome-client");
  system("echo 0 widget_tell sb_system gr_net_out_wlan0 data d_net_out_wlan0 $wlan0_out_kbps | awesome-client");

  system("echo 0 widget_tell sb_system tb_net_down_wlan0 text WLN_D: $wlan0_in_kbps KB/s | awesome-client");
  system("echo 0 widget_tell sb_system gr_net_in_wlan0 data d_net_in_wlan0 $wlan0_in_kbps | awesome-client");


  system("echo 0 widget_tell sb_system tb_cpu text CPU: $cpu_total% | awesome-client");
  system("echo 0 widget_tell sb_system gr_cpu data d_cpu $cpu_total | awesome-client");


  system("echo 0 widget_tell sb_system tb_mem text MEM: $mem_used_per% | awesome-client");
  # system("echo 0 widget_tell sb_system gr_mem data d_mem $mem_used_per% | awesome-client");


  system("echo 0 widget_tell sb_system tb_swap text SWP: $swap_used_per% | awesome-client");
  # system("echo 0 widget_tell sb_system gr_swap data d_swap $swap_used_per% | awesome-client");

  # system("echo 0 widget_tell sb_system gr_swap data d_swap $swap_used_per% | awesome-client");

  system("echo 0 widget_tell sb_system pb_root data d_root $root_use_per% | awesome-client");
  system("echo 0 widget_tell sb_system pb_root data d_win $win_use_per% | awesome-client");
  system("echo 0 widget_tell sb_system pb_dat data d_dat $dat_use_per% | awesome-client");
  system("echo 0 widget_tell sb_system pb_dat data d_boot $boot_use_per% | awesome-client");

  # system("echo 0 widget_tell sb_system tb_mail text $unread_email_count | awesome-client");
  system("echo 0 widget_tell sb_system tb_weather text $current_weather_temp - $current_weather_condition | awesome-client");

  my $temper = `cat /proc/acpi/thermal_zone/THM/temperature`;
  $temper = substr($temper,25,2) . "oC";
  system("echo 0 widget_tell sb_system tb_tmp text TMP: $temper | awesome-client");

#  print "disk usage: $diskstat->{$root_disk}->{usageper} %\n";

  # if ($status->{state} !~ /stop/) {
	# system("echo 0 widget_tell sb_status tb_mpd text \"$current_artist\" - \"$current_title\" \"\($status_time_sofar/$status_time_total\)\"  | awesome-client");
  # } else {
	# system("echo 0 widget_tell sb_status tb_mpd text STOPPED  | awesome-client");
  # }
  $weather_renew++;
}
