#!/usr/bin/env raku

use Test;
use Ikoko;

my $token = 'cNRWYYtjoGxqPbNCzuL83b2Ld+PbVaAaTFgs4oExZFjbsoYPdGw64WEK9HBjMhCZdkjtqHsImcANQCRe9wZY3m+EbQ9WGSxa6nQMr1ATIEKDNfp9mAnFdtXJmvJVEBQgtbn3Gb1xsKG8JnUQhkWA1mAMi50JDk3VT/+u74c0f6uAb+Nvme9umi16RlYxoCSCOZHdKA77Jo7s9Ng9jEzTwrhTR/mFyCKiJpPMi0TS7epk6+7itJjEQCLorcFzwlAcXDofpP90hrU+e4q5agHF0M4yBW2tEQKtQpN22VHEEmjsCEiDUSe4tyyq1Nx8df02nWNwO+TtBMk5rMqMtfUefcAomk2rei26LZ9uxAZvZ1CdS3xAjuORUCXkEv75f7mpNEAJ/KVk5e6M+uOBh4ki1gqEPXuaVGsYSPnOpCHH/wrHxZqs18MFYpBwutcQkxdov8ZaPbfIG2251lC7yB0q/XVpeDyYxLcWDxqtl1ylUa5v0vB1JrSL6y7pCDIshGiXRnxj+9pYQKbsihZm2x0MKUSN7D6AsIBpyc/k69hbHRi4sLFz/eF8z/z9gOUeGObVBptRXlkT1yaO/D66EiKYhNQ8mSudXMnlt0bMJsdIElx/wvuMVnPbPQPMeEOUAJYC4vE9Iestb4AM/ABt9lwD9nvKG/GRYLB21+iLwqzulO9QOXU+lhlItujEBBhyAm8Uh4eA6QNcpWgziIr57zUXObDUjD833Y/7MNGp2zhoPA6FiandE/GB8tMsXaPAp4Z9gcsXEn7D0sG93g8lk6+WKEc45ez0BB134A0qZJWBITYEY/ArD7RuPEF3hbZW6PWTBk4u0gZh2IN6uPmlJOQ03JzmJcQVJTpJmBbJazpO/t51TrzjGnk/OtfE3IP0gCA+H++8GpJXj1wfT1li263Y1+z3YYtT2uw/Vbl/xDL30IGn60Jy2TYijSBhNExG/lyAI+LbSufavHfS8K63PkPlogH4QqnYox3jfIBjAdCOs/cl8LjIWQ9Tlg8aZM6AffjMiOX0VF9fGjfVtlP2792YQ4KkKX6Nk==';

my Ikoko $ikoko;

lives-ok { $ikoko = Ikoko.new(region => 'eu-west-2', secret-access-key => 'Nli5e5+WIiz6IWKLj7TbCy+8gwESGVBDKkzZU2F9', access-key-id => 'SJXI2XTKWLOP4I6ZAA4T' ) }, "new";

is $ikoko.host, 'secretsmanager.eu-west-2.amazonaws.com', 'got the right host';
is $ikoko.uri, 'https://secretsmanager.eu-west-2.amazonaws.com/', 'got the right uri';

my %headers;

lives-ok { %headers = $ikoko.headers('secretsmanager.GetSecretValue') }, "headers";

is %headers<Host>, 'secretsmanager.eu-west-2.amazonaws.com', "got right host header";
is %headers<Content-Type>, 'application/x-amz-json-1.1', 'correct content-type';
is %headers<X-Amz-Target>, 'secretsmanager.GetSecretValue', 'correct target';
like %headers<X-Amz-Date>, /<[0 .. 9]> ** 8 T <[0 .. 9]> ** 6 Z/, "X-Amz-Date";
nok %headers<x-amz-security-token>:exists, 'no token';

my $req = Ikoko::SecretRequest.new(secret-id => 'foo');

my $auth;

lives-ok { $auth = $ikoko.auth-header($req.to-json, %headers) }, 'auth-header';

like $auth, /^'AWS4-HMAC-SHA256 Credential='/, 'reasonable looking';

lives-ok { $ikoko = Ikoko.new(region => 'eu-west-2', token => $token, secret-access-key => 'Nli5e5+WIiz6IWKLj7TbCy+8gwESGVBDKkzZU2F9', access-key-id => 'SJXI2XTKWLOP4I6ZAA4T' ) }, "new with token";

is $ikoko.headers('secretsmanager.GetSecretValue')<x-amz-security-token>,$token, 'got token in header';

done-testing;
# vim: ft=raku
