*WIP*
# Hotwire Chat app
A realtime Ruby on Rails Chat application built with Hotwire (Turbo and Stimulus)

### Core dependencies

1. Rails
2. PostgreSQL
3. turbo-rails
4. stimulus-rails
5. tailwind-css
6. Devise 
7. omniauth-google-oauth2
8. debounce

# Architecture

This will be an overview of how the models/controllers/views work.

**Models**

1. User

Generated through devise
`rails g devise user`

Check db/schema.rb for the complete user's table columns 

2. Friendship

Columns:
```ruby
:recipient_id
:requestor_id
:status
:messages
```

3. Message

Columns:
```ruby
:sender_id
:receiver_id
:friendship_id
```

**Associations**

1. User

```ruby
has_many :sent_friendships, class_name: "Friendship", foreign_key: "requestor_id"
has_many :received_friendship, class_name: "Friendship", foreign_key: "recipient_id"
```
