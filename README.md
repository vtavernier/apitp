# APITP Project management solution

[![libraries.io](https://img.shields.io/librariesio/github/vtavernier/apitp.svg)](https://libraries.io/github/vtavernier/apitp) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

APITP is a web application to manage school projects. Administrators (teachers)
can create groups of students, imported from school listings, and assign
projects to those groups. These projects are completed by the student by
uploading their work as a file for the project before the due date. E-mail
notifications remind the site users of approaching due dates.

## Technology

This website has been developed with `Rails 5.1` on `Ruby 2.3.3`. PostgreSQL has
been chosen as the only supported database for simplicity, and to support
`Que` as an ActiveJob back-end. ActiveAdmin is used for generating most of the
administrative interface.

## Deployment

See [provision](provision/), requires Ansible, and Vagrant for testing.

## Running the test suite

```bash
bundle exec rake spec
```

## Author

Vincent Tavernier <vince.tavernier@gmail.com>

## License

This work is licensed under the [GPL v3](LICENSE).
