active_record-shadow
--------------------

  - [![Quality](http://img.shields.io/codeclimate/github/laurelandwolf/active_record-shadow.gem.svg?style=flat-square)](https://codeclimate.com/github/laurelandwolf/active_record-shadow.gem)
  - [![Coverage](http://img.shields.io/codeclimate/coverage/github/laurelandwolf/active_record-shadow.gem.svg?style=flat-square)](https://codeclimate.com/github/laurelandwolf/active_record-shadow.gem)
  - [![Build](http://img.shields.io/travis-ci/laurelandwolf/active_record-shadow.gem.svg?style=flat-square)](https://travis-ci.org/laurelandwolf/active_record-shadow.gem)
  - [![Dependencies](http://img.shields.io/gemnasium/laurelandwolf/active_record-shadow.gem.svg?style=flat-square)](https://gemnasium.com/laurelandwolf/active_record-shadow.gem)
  - [![Downloads](http://img.shields.io/gem/dtv/shadow.svg?style=flat-square)](https://rubygems.org/gems/shadow)
  - [![Tags](http://img.shields.io/github/tag/laurelandwolf/active_record-shadow.gem.svg?style=flat-square)](http://github.com/laurelandwolf/active_record-shadow.gem/tags)
  - [![Releases](http://img.shields.io/github/release/laurelandwolf/active_record-shadow.gem.svg?style=flat-square)](http://github.com/laurelandwolf/active_record-shadow.gem/releases)
  - [![Issues](http://img.shields.io/github/issues/laurelandwolf/active_record-shadow.gem.svg?style=flat-square)](http://github.com/laurelandwolf/active_record-shadow.gem/issues)
  - [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT)
  - [![Version](http://img.shields.io/gem/v/active_record-shadow.svg?style=flat-square)](https://rubygems.org/gems/active_record-shadow)


This gem allows you to soft apply changes to an object graph and then hard apply those changes, even across deep relationships.

This becomes highly useful for viewing persisted non-realized changes like a promotion code service. Consider the following scenario:

  - A consumer comes to the website and picks out two jackets they want to purchase.
  - The consumer received an email with two coupon codes:
    - Buy 1 jacket and get 1 jacket free.
    - Get $100 in credit.
  - They get ready to checkout and they enter the coupon code.
  - The server receives the code and soft applies the changes: The second item is 100% off.
  - The server handles this by giving the `Item` a `discount_cents` of equal value to `total_cents`.
  - The client receives a `Cart` response body containing the related `Item` data reflecting the change.
  - The consumer sees both items, but the second jacket is now 100% off!
  - The consumer refreshes the page and the jacket is still 100% off.
  - The consumer then changes their mind and decides to get the credit.
  - The server takes the new code and soft applies the new code.
  - The client receives a new `Cart` response body with `Item` data that has no `discount_cents`.
  - The consumer checks out, is charged for two jackets, and receives a $100 credit on their `Profile` record.

If the developer had written this with hard application logic the second code would have to trigger a reversal of the `discount_cents` change. This pattern is commonly known as `Open/closed principle`. Consider the following example:


``` ruby
public def apply(coupon, cart)
  modify(coupon, cart, "up")
end

public def unapply(coupon, cart)
  modify(coupon, cart, "down")
end

private def modify(coupon, cart, direction)
  case direction
  # ...

  when "up" && coupon.code == "B1G1F" then
    item = cart.items.last
    item.update(discount_cents: item.total_cents)
  when "down" && coupon.code == "B1G1F" then
    item = cart.items.last
    item.update(discount_cents: 0)

  # ...
  end
end
```

Not only is this verbose, prone to error (what if the consumer adds an item between the two jackets?), and not very fault tolerant, but it also has a performance impact due to the persisted nature.

Instead we can use shadow.


Using
=====

Before we start soft applying we need to create the `ActiveRecord::Shadow` objects.

``` ruby
# ./app/shadows/cart_shadow.rb
# This class represents a singular record
class CartShadow < ActiveRecord::Shadow::Member

  shadow Cart

  # This tells Shadow that these values are nodes on the graph
  related :items, ItemsShadow
  related :consumer, ConsumerShadow

  # This tells Shadow to copy the value on cloning
  static :tax_cents

  # This tells Shadow to "implement" to run the method in the context of the shadow
  # This is useful for methods that require other shadowed values
  dynamic :subtotal_cents
  dynamic :total_cents

  # These properties will be blackholes for changes, even relationships
  ignore :shipping_cents
  ignore :card
end

# ./app/shadows/items_shadow.rb
# This class represents a collection of records
class ItemsShadow < ActiveRecord::Shadow::Collection

  shadow Item

  # Filter properties are layers over scopes or singleton methods
  # In ActiveRecord this prevents unintelligently destroying the in memory representation
  filter :default, ItemShadow
  filter :on_sale, ItemShadow
end

# ./app/shadows/item_shadow.rb
class ItemShadow < ActiveRecord::Shadow::Member

  shadow Item

  relation :cart, CartShadow

  # Linked properties get overwritten when the source object changes, like in the case of migrations
  linked :total_cents
  static :discount_cents
end
```

Now we need to soft apply the change:

``` ruby
cart = Cart.find(cart_id)
shadow = CartShadow.new(cart)

cart.items.first.price_cents # => 0
shadow.items.first.price_cents # => 0

cart.items.first.price_cents = 100

cart.items.first.price_cents # => 100
shadow.items.first.price_cents # => 100

shadow.items.first.price_cents = 50

cart.items.first.price_cents # => 100
shadow.items.first.price_cents # => 50

cart.total_cents # => 100
shadow.total_cents # => 50
```

Notice how the cart is unchanged during the entire process unless *we explicitly change it*.

We still have to apply this change:

``` ruby
shadow.sync

cart.total_cents # => 50
shadow.total_cents # => 50
Cart.find(cart_id).total_cents # => 0

shadow.save

cart.total_cents # => 50
shadow.total_cents # => 50
Cart.find(cart_id).total_cents # => 50
```


Installing
==========

Add this line to your application's Gemfile:

    gem "active_record-shadow", "~> 1.0"

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install active_record-shadow


Contributing
============

  1. Read the [Code of Conduct](/CONDUCT.md)
  2. Fork it
  3. Create your feature branch (`git checkout -b my-new-feature`)
  4. Commit your changes (`git commit -am 'Add some feature'`)
  5. Push to the branch (`git push origin my-new-feature`)
  6. Create new Pull Request


License
=======

Copyright (c) 2014, 2015 Kurtis Rainbolt-Greene

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
