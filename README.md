# upnp_content_explorer
A convenience wrapper around an [easy_upnp](https://github.com/sidoh/easy_upnp) service to access content.

## Installing

`upnp_content_explorer` is available on [Rubygems](https://rubygems.org). You can install it with:

```
$ gem install upnp_content_explorer
```

You can also add it to your Gemfile:

```
gem 'upnp_content_explorer'
```

## What's this for?

This gem makes it easy to explore and navigate content provided by a UPnP media server implementing the `urn:schemas-upnp-org:service:ContentDirectory:1` service. At the moment, it relies on [`easy_upnp`](https://github.com/sidoh/easy_upnp) to interface with the UPnP server.

## Example usage

Given an `easy_upnp` server identified by `service`, you can construct a content explorer as follows:

```ruby
require 'upnp_content_explorer'

explorer = UpnpContentExplorer::Explorer.new(service)
```

You can then do the following:

### Get the contents of a directory

```ruby
node = explorer.node_at('/Movies')

node.children.map(&:title)
# => ["Comedy", "Horror", "Suspense"]

node.items.map(&:title)
# => ["Inside Out (2015).mkv"]
```

### List the children of a directory
```ruby
children = explorer.children_of('/Movies')

children.map(&:title)
# => ["Comedy", "Horror", "Suspense"]
```

### List the files inside of a directory
```ruby
items = explorer.items_of('/Movies')

items.map(&:title)
# => ["Inside Out (2015).mkv"]
```

### Recursively scrape all content of a directory
```ruby
movies = explorer.scrape('/Movies')

items.map(&:title)
# => ["Inside Out (2015).mkv", "Exorcist, The (1973).mkv", "Seven (1995).mkv", "Airplane (1980).mkv"]
```

## Extracting metadata

To extract DIDL Lite metadata for an item, you should generally call `Browse` with the `BrowseFlag` parameter equal to `'BrowseMetadata'`, passing the `ObjectID` of the item in question. For example:

```ruby
# Choose a random movie
movie = explorer.scrape('/Movies').sample

movie.title
# => "Airplane (1980).mkv"

# Get movie metadata
movie_metadata = service.Browse(
    ObjectID: movie.id, 
    BrowseFlag: 
    'BrowseMetadata', Filter: '*'
)[:Result]
# => ... (Raw DIDL Lite metadata) ...
```
