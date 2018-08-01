# Aion

Aion is a gem which was created for our need to keep versions of some records in our Rails application at [Studio Raketa](https://github.com/studioraketa). We checked the existing solutions like [paper_trail](https://github.com/paper-trail-gem/paper_trail), [audited](https://github.com/collectiveidea/audited) and [logidze](https://github.com/palkan/logidze) and used them for inspiration! Thanks to the authors and contributes of those gems! Our use case required almost the same functionality as the already existing gems but we also had some additional requirements and we decided to create Aion to server that purpose.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aion', git: 'git@github.com:studioraketa/aion.git'
```

or for HTTPS

```ruby
gem 'aion', git: 'https://github.com/studioraketa/aion.git'
```

And then execute:

    $ bundle


## Usage

### Setting up the table for tracking versions
```sh
rails generate aion:install
bin/rails db:migrate
```

### Tracking changes for a given model
Given you have a `Post` model this is how to track its changes:
```ruby
class Post < ApplicationRecord
  aion_track_changes
end
```

`aion_track_changes` does not add an association between the model and the table with `changesets`. Check the `Options: identifier` section for more info on how both records are related.
An instance method `#versions` will be added to Post. The method returns an `ActiveRecord_Relation` object. Once having the relation it is easy to filter or order it by whatever you need.
There are a few predefined scopes like `for_locale(requested_locale)`, `after(datetime)`, 'before(datetime)'.

#### Options: only
It is possible to specify which fields exactly should be tracked. It is done like so:
```ruby
class Post < ApplicationRecord
  aion_track_changes only: [:title, :author_name]
end
```
For a single field:
```ruby
class Post < ApplicationRecord
  aion_track_changes only: :title
end
```

#### Options: except
You can also specify which fields to ignore:
```ruby
class Post < ApplicationRecord
  aion_track_changes except: [:title, :author_name]
end
```
For a single field:
```ruby
class Post < ApplicationRecord
  aion_track_changes except: :title
end
```

#### Options: identifier
By default in an Aion::Changeset the tracked model class is stored in the `versionable_type` column and the id in the `versionable_identifier` column.
In the cases where you need to use a different column than the id of a record you can do so like this:
```ruby
class Post < ApplicationRecord
  aion_track_changes identifier: :uuid
end
```
You should only use columns with unique values which cannot be changed in the lifetime of the record.

#### Options: custom_changes_class
By default Aion uses the `#changes` method coming from `ActiveRecord`. If you are using gems which alter this behaviour you should supply a custom class which can extract the changes to be recorded. Here is an example where we needed to version records translated with the [globalize](https://github.com/globalize/globalize) gem.

```ruby
class Post < ApplicationRecord
  translates :title, :body

  aion_track_changes custom_changes_class: RecordChanges::Globalized
end
```

This is how the custom class for collecting the changes looks like:
```ruby
module RecordChanges
  class Globalized
    def initialize(record, locale)
      @record = record
      @locale = locale
    end

    def extract
      record.changes
        .except(*translated_attributes)
        .merge(translated_attributes_changes)
    end

    private

    attr_reader :record, :locale

    def translated_attributes
      @translated_attributes ||= record.attributes.keys.select { |attr| record.translated? attr }
    end

    def translated_attributes_changes
      record.globalize.dirty.each_with_object({}) do |key_value, memo|
        key, value = key_value

        # Even if a translated field did not change it is inside the
        # globalize.dirty
        next if value[locale] == record.public_send(key)

        memo[key] = [
          value[locale], # Old value of the translated field
          record.public_send(key) # New value of the translated field
        ]
      end
    end
  end
end
```

It should respond to `#extract` and be initialized with the record and the locale for which to get the changes.
The returned result should be a Hash with the attribute names for keys and an array with the old and new values for these
attributes.
```ruby
{
  "attribute" => ["old_value", "new_value"]
}
```
It is very important that the record responds to the `#attribute=` method since it is needed for reverting versions.

If the returned Hash is empty no version will be recorded!

### Collecting data from a request

In the controllers for which you would like to collect information related to the changes of
a record you should add an `around_action` and pass in `Aion.request_info_collector`. Also the
`aion_info` method should be present on the controller. By default the collected information
is `request_uuid` and `operator`. Both are string fields.
```ruby
class ApplicationController < ActionController::Base
  around_action Aion.request_info_collector

  def aion_info
    { operator: current_user.name, request_uuid: request.request_id }
  end
end
```

In the case you need to add more statistics, let's assume you need to store the request IP address, you
could do the following:

1. Add an initializer config/initializers/aion.rb
```ruby
Aion.config do |config|
  config.controller_statistics = %i[request_uuid operator remote_ip]
end
```
If you do not want to collect the `request_uid` or `operator` just do not add then to the `controller_statistics`

2. You would also need a migration to add the new columns to the `aion_changesets` table. It could be
something like:
```ruby
class AddRemoteIpToAionChangesets < ActiveRecord::Migration[5.2]
  def change
    add_column :aion_changesets, :remote_ip, :string, null: false, default: ''
  end
end
```

3. In the `aion_info` method add the new parameter. Every parameter which you omit here will default to an empty string.
```ruby
class ApplicationController < ActionController::Base
  around_action Aion.request_info_collector

  def aion_info
    {
      operator: current_user.name,
      request_uuid: request.request_id,
      remote_ip: request.ip
    }
  end
end
```

## Development

TDB.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aion. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Aion project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/aion/blob/master/CODE_OF_CONDUCT.md).

## TODOs
- Add documentation
- Add tests!
