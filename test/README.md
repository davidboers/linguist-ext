# `test_user.rb`

Note that this test requires the user to link to different repos hosted on their computer. To ensure security, I've hidden the `myrepos.rb` file from git. To replicate, create a file that looks something like this:

```ruby
module Linguist
    @@myrepos = [] # Insert paths to repos here.

    def self.myrepos
        @@myrepos
    end
end
```

The `@@myrepos` should be a list of repos on your computer.
