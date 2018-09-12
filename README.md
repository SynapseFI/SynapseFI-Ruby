# SynapsePayRest-Ruby

Native API library for SynapsePay REST v3.x

Not all API endpoints are supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'synapse_pay_rest'
```

And then execute:

```bash
$ bundle
```

Or install it yourself by executing:

```bash
$ gem install synapse_pay_rest
```

## Documentation

- [Samples demonstrating common operations](samples.md)
- [synapse_pay_rest gem docs](http://www.rubydoc.info/github/synapsepay/SynapsePayRest-Ruby)
- [API docs](http://docs.synapsefi.com/v3.1)

## Contributing

For minor issues, please open a pull request. For larger changes or features, please email hello@synapsepay.com. Please document and test any public constants/methods.

## Running the Test Suite

If you haven't already, run `cp .env.sample .env` and set the `TEST_CLIENT_ID` and `TEST_CLIENT_SECRET` environment variables.

To run all tests, execute:

```bash
rake
```

To run a specific file or test run:

```bash
m path/to/file:line_number
```

## License

[MIT License](LICENSE)
