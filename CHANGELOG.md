## [0.0.11] - 2023-10-12

- Add a tree output for a new command `jcf services NAME` that will show all the offerings and instances for that broker. In a tree. Because trees are cool.

## [0.0.10] - 2023-10-03

- Added the template parsing options to metrics command
  This allows you to specify the AWS instance name with a template, and
  then supply the values to fill in the template with the --values flag.
  This makes metrics available to everyone, maybe.

## [0.0.9] - 2023-10-02

- Automatically increase table width for wide tables

## [0.0.8] - 2023-10-02

- Add --org filter to service_offerings command
- Add --org filter to service_plans command
- Add --org filter to service_instances command
- Add --space filter to service_instances command
- Add --org filter to spaces command

## [0.0.7] - 2023-10-02

- Add missing gems and tidy up

## [0.0.6] - 2023-10-02

- Add missing "english" gem to dependencies
- Add extra platforms to Gemfile.lock

## [0.0.5] - 2023-10-02

- Searching for objects now returns all matches, not just the first

## [0.0.4] - 2023-10-02

- Add service_offerings command

## [0.0.3] - 2023-10-02

- Relationships output is now more readable
- Partial lookups for all classes when searching
## [0.0.2] - 2023-09-28

- Default to text output instead of json

## [0.0.1] - 2023-08-29

- Initial release
- Query RDS metrics
- Query S3 metrics
