#! /usr/bin/perl -X
#use strict; use warnings;

#========== FRSR V3 ===============================================================
#Call: ./InterpFrsrPacket.pl 

$strin=sprintf "%s",`cat /tmp/pkt`;
$ix = index($strin,'*');
$strin=substr($strin,0,$ix+3);

# HIGH PACKET
#$strin = '$FSR03,H,83B3,MNEN,PRKR,R6D0[0O1J1K2I9,R6D0[0O1K1K2K9,_9T1,R6R6T6V6X6W6U6I6c5F361W0m0l2T5F6V6X6W6U6S6S600,0000000000G0D0C0E0K0F000D0B0C0@0C0C0D0C0E0G0@0,\0[0^0]0[0\0[0Y0Q0=0400080J0Y0\0[0\0\0Z0[0\000,P1O1P1P1P1O1O1L1D1^0B000<0Z0B1L1P1P1Q1P1P1O100,J1K1K1K1L1K1J1J1@1[0<020;0X0>1G1K1K1M1K1K1K100,K2M2K2L2M2M2K2H282=1H0>0F0;162G2M2M2L2L2L2K200,I9J9L9O9R9Q9M9A9K865_1n0H174f769N9S9Q9N9K9K900,*66';

# 83B3, temp T1 T2
# MNEN, pitch p1 p2
# PRKR, roll r1 r2
# R6D0[0O1J1K2I9, G11,G21--G71
# R6D0[0O1K1K2K9, G12,G22,--G72
# _9T1,  shadow/limit
# R6R6T6V6X6W6U6I6c5F361W0m0l2T5F6V6X6W6U6S6S600,
# 0000000000G0D0C0E0K0F000D0B0C0@0C0C0D0C0E0G0@0,
# \0[0^0]0[0\0[0Y0Q0=0400080J0Y0\0[0\0\0Z0[0\000,
# P1O1P1P1P1O1O1L1D1^0B000<0Z0B1L1P1P1Q1P1P1O100,
# J1K1K1K1L1K1J1J1@1[0<020;0X0>1G1K1K1M1K1K1K100,
# K2M2K2L2M2M2K2H282=1H0>0F0;162G2M2M2L2L2L2K200,
# I9J9L9O9R9Q9M9A9K865_1n0H174f769N9S9Q9N9K9K900,
# *66';

# or
# HIGH-NOSHADOW or LOW PACKET
# Rad(0) 8.0/200 cm 1823656  1833563N 6.21 PhS PH   4.9/10
# $FSR03,T,83B3,CN?N,ORJR,801000000010<0,900050000010=0,*3B
# $strin='$FSR03,L,83B3,>N<N,bReR,00000000000000,00000000000010,00X?,*11';

# $FSR03,L,
# 83B3,
# >N<N,
# bReR,
# 00000000000000,
# 00000000000010,
# 00X?, shadow/limit, if Low mode shadow is set to 00
# *11


# $strin=shift();
print"strin = $strin\n";


# TEST LENGTH
my ($pktlen,$cc,$packetid,$mode,$shadow,$shadowthreshold,$ix);
my (@g1,@g2,@sw);
$pktlen=length($strin);
$#sw = 23 * 7;

## CHKSUM TEST
$cc = NmeaChecksum( substr($strin,0,-2) );
printf"chksum=%s\n",substr($strin,-2);
printf"computed chksum=%s\n", $cc;
if ($cc ne substr($strin,-2)) {
	print"Checksum fails, skip\n";
} else {
	$ichar=1;
	# Header
	$packetid = substr($strin,$ichar,5);
	print"ID = $packetid\n";
	$ichar+=6;
	# Mode
	$mode=substr($strin,$ichar,1);
	print"Mode = $mode\n";
	$ichar+=2;
	# T1,T2
	$T1 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10-20;
	$ichar+=2;
	$T2 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10-20;
	$ichar+=3;
	printf"T1 = %.1f   T2 = %.1f\n",$T1,$T2;
	# pitch1, pitch2
	$pitch1 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/100-20;
	$ichar+=2;
	$pitch2 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/100-20;
	$ichar+=3;
	printf"pitch1 = %.2f   pitch2 = %.2f\n",$pitch1,$pitch2;
	# roll1, roll2
	$roll1 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/100-20;
	$ichar+=2;
	$roll2 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/100-20;
	$ichar+=3;
	printf"roll1 = %.2f   roll2 = %.2f\n",$roll1,$roll2;
	# global 1
	$ix=$ichar;
	for($i=0; $i<7; $i++){
		push(@g1,DecodePsuedoAscii2( substr($strin,$ix,2) ) );
		$ix+=2;
	}
	for($i=0; $i<7; $i++){
		print"$g1[$i]  ";
	}
	print"\n";
	# global 2
	$ichar+=15;
	$ix=$ichar;
	for($i=0; $i<7; $i++){
		push(@g2,DecodePsuedoAscii2( substr($strin,$ix,2) ) );
		$ix+=2;
	}
	for($i=0; $i<7; $i++){
		print"$g2[$i]  ";
	}
	print"\n";
	# shadow, limit
	$ichar+=15;
	$shadow = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10;
	$ichar+=2;
	$shadowthreshold = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10;
	$ichar+=3;
	printf"shadow = %.1f   shadowthreshold = %.1f\n",$shadow,$shadowthreshold;
	# HIGH - SHADOW
	if($pktlen>300){
		# Sweep chan 0
		$ix=$ichar; # first character
		for($ia=0; $ia<7; $ia++){
			for($ib=0; $ib<23; $ib++){
				$ic = $ia*23 + $ib; # array index
				$sw[$ic] = DecodePsuedoAscii2( substr($strin,$ix,2) );
				$ix+=2;
			}
			$ix++; # skip the comma
		}
		# print out sweeps
		for($ia=0; $ia<7; $ia++){
			for($ib=0; $ib<23; $ib++){
				$ic = $ia*23 + $ib; # array index
				print"$sw[$ic] ";
			}
			print"\n";
		}
}

# 
print"end\n";
exit 0;

#=========================================================
#$GPRMC,190824,A,4737.0000,S,12300.0000,W,002.1,202.0,210210,019.0,W*62
sub NmeaChecksum
# $cc = NmeaChecksum($str) where $str is the NMEA string that starts with '$' and ends with '*'.
{
    my ($line) = @_;
    my $csum = 0;
    $csum ^= unpack("C",(substr($line,$_,1))) for(1..length($line)-2);
    return (sprintf("%2.2X",$csum));
}
#==========================================================================
sub DecodePsuedoAscii2
# input = 2 p.a. chars   output = decimal number
{
	my ($strin,$c1,$c2,$b1,$b2,$x);
	$strin=shift();
	#printf"In string = $strin  ";
	$c1 = substr($strin,0,1);
	$c2 = substr($strin,1,1);
	$b1 = ord( $c1 ) - 48;
	$b2 = ord($c2) - 48;
	$x = $b2*64+$b1;
	#print"  decode = $x\n";
	return $x;
}
