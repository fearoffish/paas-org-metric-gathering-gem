# Jcf

## Installation

Currently this gem is not available on rubygems.org so you will need to build it yourself. A convenience rake task has been included:

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

> **_NOTE:_** Metrics are a little different. They are specific to the gov.uk PaaS. Plans to make this more generic are in the works.

You need to specify the environment and the service type you want to query.

Query the `production` environment, `rds-broker` service for the organization `my-org`:

```sh
jcf metrics production rds-broker --org=my-org
```

Query the `staging` environment, `aws-s3-bucket-broker` service for the organizations `my-org` and `my-org2`:
```sh
jcf metrics staging aws-s3-bucket-broker --org=my-org,my-org2
```

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
