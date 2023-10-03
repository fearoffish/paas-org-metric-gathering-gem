![tests](https://github.com/fearoffish/paas-org-metric-gathering-gem/actions/workflows/main.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/jcf.svg)](https://badge.fury.io/rb/jcf)

# Jcf

## Installation

```sh
gem install jcf
```

A convenience rake task has been included to do this locally:

```sh
rake install
```

Or you can just build it instead:

```sh
rake build
```

## Usage

Make sure you're logged into the CloudFoundry you want to query. You can then run the `jcf` command to see the available commands:

```
$ jcf
Commands:
  jcf metrics ENV TYPE
  jcf organizations [NAME]
  jcf service_brokers [NAME]
  jcf service_instances [NAME]
  jcf service_offerings [NAME]
  jcf service_plans [NAME]
  jcf spaces [NAME]
  jcf users [NAME]
  jcf version                                 # Print JCF app version
```

Each command has a `--help` option to show the available options. They also have aliases for the short and long form of the command. For example:

```sh
jcf organizations
jcf orgs
jcf o

jcf service_brokers
jcf sb
```

### Examples

Ignoring `metrics`, all other types can list all or filter based on a given name.

#### List all

```sh
jcf organizations
```

#### Filter by name

```sh
jcf organizations my-org
```

#### Metrics

Metrics queries AWS for backend CloudWatch metrics. It will output a table of the metrics for each service instance.

Because CF doesn't give access to the underlying AWS details for us to query, we have to make some assumptions:

- You need to be logged into the AWS account that the CF is using
- The AWS account has the correct permissions to query the metrics

We need a `template` for the instance names on AWS. This is a regex that will be used to match the instance names. For example, the `rds-broker` service has instances with names like `rdsbroker-GUID1`, `rdsbroker-GUID2`, etc. The template for this would be `rdsbroker-{guid}`.

Examples for the template, note that guid is a special value that is filled automatically with the instance guid from CF:

- `rdsbroker-{guid}`
- `s3broker-{guid}`
- `s3broker-{guid}-bucket-{name}`

When you supply a template token that is _not_ `guid`, you need to supply a `--values` flag to fill in the value. For example:

```sh
jcf metrics OFFERING \
  --org=my-org \
  --template='rdsbroker-{guid}-{name}' \
  --values='name=foobar'
```

`jcf` will use the template to determine the AWS guid to query for metrics.

### Formatting

The default format is a table. You can also format as JSON or CSV. For example:

```sh
# as json
jcf organizations --format json
```

```sh
# as csv
jcf organizations --format csv
```

When querying metrics, you probably want the output to a file. You can use the `--output` flag for this. Progress will be output to STDERR. For example:

```sh
jcf metrics production rds-broker \
  --org=my-org \
  --format csv \
  --output rds-broker-metrics.json
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fearoffish/jcf. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fearoffish/paas-org-metric-gathering-gem/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jcf project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fearoffish/paas-org-metric-gathering-gem/blob/main/CODE_OF_CONDUCT.md).
