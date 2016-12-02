# SynapsePayRest-Ruby

Native API library for SynapsePay REST v3.x

Originally developed as a simple wrapper to handle the headers and endpoint URLs for each API request, as of v2.0.0 it now handles creation of User, Node, Transaction and related objects to remove the necessity of dealing with raw payload and response JSON.

Not all API endpoints are supported.

**Pre-2.0.0 users**

There are significant changes but backwards compatibility has been mostly maintained by building on top of the base API wrapper. You can still use the previous classes but note the following changes:

- `ArgumentError` will be raised for missing payloads or other required arguments, where `RuntimeError` was raised previously. 
- `development_mode` now defaults to true (gem previously defaulted to production).
- KYC 1.0 methods for uploading documents have been deprecated. Please contact SynapsePay if you need to update to KYC 2.0.
- API errors will now raise `SynapsePayRest::Error`s instead returning a JSON hash (and sometimes obfuscating the API error message).

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
- [API docs](http://docs.synapsepay.com/v3.1)

## Contributing

Just open a pull request. Please document and test any public constants/methods. Open an issue or email steven@synapsepay.com if you have any questions.

## Running the Test Suite

Make sure these values are set as enviroment variables (using [dotenv](https://github.com/bkeepers/dotenv) for example):

```
CLIENT_ID=your_sandbox_client_id
CLIENT_SECRET=your_sandbox_client_secret
```

To run all tests, execute:

```bash
rake
```

To run a specific file or test, install the [m](https://github.com/qrush/m) gem and execute:

```bash
m path/to/file:line_number
```

## Todos

- Smartly update the existing instances with response data instead of re-instantiating for every response. I started with this approach but it gets pretty complicated with the interconnected models of User/BaseDocument/Document. Also, certain values are only known if the user created an object, but not when the object is built from API response data. This is solveable but requires more dev time and testing.
- Various factory helper methods should be private but are public. Would be good to refactor in a way that they can be private.
- `User`/`Node`/`Transaction` have similar REST methods that could probably be factored into a superclass or module.
- Use mixins instead of inheritance for the shared behavior of `Node`s and `Document`s. The parent classes are never instantiated anyways.
- Refactor the redundant code in each `Node` type's version of `#payload_for_create`.
- Better way to handle bank MFA nodes? Virtual doc KBA?
- Add an option for logging responses in addition to requests.
- Organize tests better.
- Use mocked responses whenever possible in tests.
- More examples.
- More Error types (bad MFA answer, for example).
- Add some methods to BaseDocument to return doc by type (e.g. `base_document.ssn_doc`).

Specific todos are marked throughout in this format:

```ruby
# @todo Description of todo.
```

## License

[MIT License](LICENSE)
