# Ikoko

Simple Read-Only interface to the AWS Secrets Manager

[![CI](https://github.com/jonathanstowe/Ikoko/actions/workflows/main.yml/badge.svg)](https://github.com/jonathanstowe/Ikoko/actions/workflows/main.yml)

## Synopsis

```raku
use Ikoko;
use Kivuli;

# Using Kivuli to get session credentials for a role in EC2
# The access-key-id and secret-access-key could come from configuration
my $k = Kivuli.new;

my $ikoko = Ikoko.new(region => 'eu-west-2', access-key-id => $k.access-key-id, secret-access-key => $k.secret-access-key, token => $k.token );

say $ikoko.get-secret-value("db-user").secret-string;
```

## Description

This provides a simple interface to the [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/index.html). The secrets manager enables an application to retrieve a secret credential (for, say, an RDS database ) at run time without having to save it in your application configuration.

If used with [Kivuli](https://docs.aws.amazon.com/secretsmanager/index.html) in an EC2 or Elasticbeanstalk instance you can avoid having all credentials in the configuration or application code. When used with the temporary credentials as supplied by Kivuli the `token` must be provided.  If you are using a permanent access key for
an account then the `token` is optional.

For this to work the account or IAM role must have permission to retrieve the secrets, which is described [here](https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access.html).

Currently this only implements `GetSecretValue` as this is most useful for an application.

## Installation

Assuming you have a working installation of rakudo you should be able to install this with *zef* :

     zef install Ikoko

## Support

This currently only implements the bare essentials for my needs, if you need some other features or have other suggestions or patches please raise an issue on [Github](https://github.com/jonathanstowe/Ikoko/issues) and I'll see what I can do.

Although the unit tests are rather thin, rest assured that I have tested this manually and is being used in the project I wrote it for.

## Licence & Copyright.

This is free software. Please see the [LICENCE](LICENCE) in the distribution for details.

© Jonathan Stowe 2021
