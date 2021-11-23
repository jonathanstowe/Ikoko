
class Ikoko {
    use Cro::HTTP::Client;
    use WebService::AWS::Auth::V4;
    use JSON::Class;
    use Cro::HTTP::BodySerializers;
    use Cro::BodyParser;
    use JSON::Name;

    has Str $.region            is required;
    has Str $.secret-access-key is required;
    has Str $.access-key-id     is required;
    has Str $.token;

    has Str $.host;

    method host(--> Str ) {
        $!host //= ('secretsmanager', $!region, 'amazonaws.com').join('.');
    }

    has Str $.uri;

    method uri( --> Str ) {
        $!uri //= "https://{ $.host }/";
    }

    class SecretResponse does JSON::Class {
        has Str $.arn is json-name('ARN');
        has DateTime $.created-date is json-name('CreatedDate') is unmarshalled-by( -> $e { DateTime.new($e) });
        has Str      $.name is json-name('Name');
        has Str      $.secret-string is json-name('SecretString');
        has Str      $.version-id    is json-name('VersionId');
        has          @.version-stages is json-name('VersionStages');
    }

    class BodyParser does Cro::BodyParser {
        method is-applicable(Cro::HTTP::Message $message --> Bool) {
        True;
        }

        method parse(Cro::HTTP::Message $message --> Promise) {
            Promise(supply {
                my $payload = Blob.new;
                whenever $message.body-byte-stream -> $blob {
                    $payload ~= $blob;
                    LAST emit SecretResponse.from-json($payload.decode('utf-8'));
                }
            })
        }
    }

    class BodySerializer does Cro::HTTP::BodySerializer {
        method is-applicable(Cro::HTTP::Message $message, $body --> Bool) {
            True
        }

        method serialize(Cro::HTTP::Message $message, $body --> Supply) {
            my $encoded = $body.encode;
            self!set-content-length($message, $encoded.bytes);
            supply { emit $encoded }
        }
    }

    has Cro::HTTP::Client $.ua;

    method ua( --> Cro::HTTP::Client )  handles <request> {
        $!ua //= Cro::HTTP::Client.new( body-serializers => [ BodySerializer ], body-parsers => [ BodyParser ]);
    }

    class SecretRequest does JSON::Class {
        has Str $.secret-id is json-name('SecretId');
    }

    method headers( Str $target --> Associative ) {
        my %headers =   Host            => $.host,
	                    X-Amz-Target    => $target,
                        ( x-amz-security-token => $_ with $!token ),
                        X-Amz-Date      => amz-date-formatter(DateTime.now),
                        Content-Type    => 'application/x-amz-json-1.1';
    }

    method auth-header(Str $body, %headers --> Str ) {
        my Str @headers = %headers.kv.map( -> $k, $v { "$k:$v" });

        my $v4 = WebService::AWS::Auth::V4.new(
                :method<POST>, :$body, :$.uri, :@headers, :$!region, :service<secretsmanager>,
                :access_key($!access-key-id), :secret($!secret-access-key)
            );

        $v4.signing-header.substr("Authorization: ".chars);
    }

    method make-request(Str $target, Str $body --> Promise ) {
        my %headers = $.headers( $target );
        %headers<Authorization> = $.auth-header($body, %headers);
        $.request('POST', $.uri, :%headers, :$body);
    }

    method get-secret-value(Str $secret-id --> SecretResponse ) {
        my $request = SecretRequest.new(:$secret-id);
        my $r = await $.make-request('secretsmanager.GetSecretValue', $request.to-json);
        await $r.body;
    }
}
